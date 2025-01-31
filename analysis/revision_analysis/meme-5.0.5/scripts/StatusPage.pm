package StatusPage;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw(
  arg_checks arg_end
  parse_uploaded opt_uploaded
  parse_db opt_db
  parse_db_or_uploaded opt_db_or_uploaded
  parse_choice opt_choice
  parse_encoded opt_encoded
  parse_integer opt_integer
  parse_number opt_number
  parse_evalue opt_evalue
  parse_safe opt_safe
);

use Carp qw(croak);
use Cwd qw(getcwd);
use Encode qw(decode);
use Fcntl qw(O_APPEND O_CREAT O_WRONLY O_TRUNC);
use File::Basename qw(fileparse);
use File::Spec::Functions qw(catfile splitdir splitpath tmpdir);
use HTML::Template;
use Sys::Hostname;
use Time::HiRes;

use lib qw(/home/ubuntu/meme/lib/meme-5.0.5/perl);
use Alphabet qw(dna rna protein);
use ExecUtils qw(invoke stringify_args stringify_args_noesc);
use Globals;

# Setup logging
my $logger = undef;
eval {
  require Log::Log4perl;
  Log::Log4perl->import();
};
unless ($@) {
  Log::Log4perl::init('/home/ubuntu/meme/share/meme-5.0.5/logging.conf');
  $logger = Log::Log4perl->get_logger('meme.service.utils');
}

my $tmp_dir = '';
$tmp_dir = &tmpdir() if ($tmp_dir eq '' || $tmp_dir =~ m/^\@TMP[_]DIR\@$/);

# Checks that a file name has only whitelisted characters in it and does
# not have a leading dash
sub is_safe_name {
  $logger->trace('call is_safe_name') if $logger;
  my ($name) = @_;
  if ($name =~ /^[a-zA-Z0-9_\.\-]+$/ && $name !~ /^-/ && $name ne '.' && $name ne '..') {
    return 1;
  }
  return 0;
}

sub _no_up_dirs {
  my ($path) = @_;
  my ($vol, $dir_path, $file_name) = splitpath($path);
  my @dirs = splitdir($dir_path);
  return 0 == grep { $_ eq '..' || $_ eq '.' } @dirs;
}

sub _prepend_link_name {
  my ($path, $link_name) = @_;
  my ($vol, $dir_path, $file_name) = splitpath($path);
  my @dirs = splitdir($dir_path);
  return catfile($link_name, @dirs, $file_name);
}

sub find_in_dir {
  my ($dir, $pattern, $link_name) = @_;
  # record the current directory so we can return to it
  my $working_dir = getcwd();
  # change to the specified directory so we can use the glob command
  chdir($dir);
  # use the glob command to find the files
  my @files = glob($pattern);
  # eliminate any files that are above the given directory
  @files = grep { _no_up_dirs($_) } @files;
  # change the working directory back to the original value
  chdir($working_dir);
  # return the files (relative to the directory given)
  if (defined($link_name)) {
    @files = map { _prepend_link_name($_, $link_name) } @files;
  }
  return @files;
}

#
# arg_checks
# Check untagged arguments.
#
sub arg_checks {
  my @arg_fns = @_;
  my $index = 0;
  my $check_fn = sub {
    my ($arg) = @_;
    my $fn = ($index < scalar(@arg_fns) ? $arg_fns[$index] : $arg_fns[-1]);
    $fn->($index, $arg);
    $index += 1;
  }
}

#
# arg_end
# Tag the ending of the arguments.
#
sub arg_end {
  my $check_fn = sub {
    my ($opt, $arg) = @_;
    my $desc = &_opt_desc($opt);
    die("Value \"$arg\" ($desc) is surplus to requirements\n");
  };
  return $check_fn;
}

#
# parse_uploaded
# Parses an uploaded file to ensure it exists and fits the allowed naming scheme
#
sub parse_uploaded {
  my ($opt, $filepath, $out_ref, $validate_fn) = @_;
  my $desc = &_opt_desc($opt);
  # uploaded files are dropped directly in the working directory so we remove all path
  my $filename = fileparse($filepath);
  if ($filename eq "--uniform--" || $filename eq "--motif--") {
    $filename = "\'$filename\'";
  } elsif (not &is_safe_name($filename)) {
    die("Value \"$filename\" invalid for $desc (does not fit allowed file name pattern)\n");
  } elsif (not -e $filename) {
    die("Value \"$filename\" invalid for $desc (file does not exist)\n");
  }
  if (defined($validate_fn)) {
    my $err = $validate_fn->($filename);
    die("Value \"$filename\" invalid for $desc ($err)\n") if ($err);
  }
  if (ref($out_ref) eq 'ARRAY') {
    push(@{$out_ref}, $filename);
  } else {
    $$out_ref = $filename;
  }
}

#
# opt_uploaded
# Returns a checker for use with Getopt::Long GetOptions method.
# Checker ensures that the file exists and does not contain odd characters
# that could mess with command line construction.
#
sub opt_uploaded {
  my ($out_ref, $validate_fn) = @_;
  my $check_fn = sub {
    my ($opt, $filepath) = @_;
    &parse_uploaded($opt, $filepath, $out_ref, $validate_fn);
  };
  return $check_fn;
}

#
# parse_uploaded
# Parses an database name to ensure it exists.
#
sub parse_db {
  my ($opt, $file_pattern, $out_ref, $db_dir, $db_link) = @_;
  my $desc = &_opt_desc($opt);
  my @files = &find_in_dir($db_dir, $file_pattern, $db_link);
  unless (@files) {
    die("Value \"$file_pattern\" invalid for $desc (does not match any files)\n");
  }
  if (ref($out_ref) eq 'ARRAY') {
    push(@{$out_ref}, @files);
  } else {
    if (scalar(@files) > 1) {
      die("Value \"$file_pattern\" invalid for $desc (matches multiple files when only one was expected)\n");
    }
    $$out_ref = $files[0];
  }
}

#
# opt_db
# Returns a checker for use with Getopt::Long GetOptions method.
# Checker ensures that the file exists within the db directory.
#
sub opt_db {
  my ($out_ref, $db_dir, $db_link) = @_;
  my $check_fn = sub {
    my ($opt, $file_pattern) = @_;
    &parse_db($opt, $file_pattern, $out_ref, $db_dir, $db_link);
  };
  return $check_fn;
}

#
# parse_db_or_uploaded
# Parses a file name pattern that could be a db.
# Looks for 'db/' to indicate that it is a database but
# otherwise requires that it is a file in the current directory.
#
sub parse_db_or_uploaded {
  my ($opt, $file_pattern, $out_ref, $db_dir, $db_link) = @_;
  my $desc = &_opt_desc($opt);
  my @files;
  if ($file_pattern =~ m/^db\//) {
    @files = &find_in_dir($db_dir, substr($file_pattern, 3), $db_link);
    unless (@files) {
      die("Value \"$file_pattern\" invalid for $desc (does not match any files)\n");
    }
  } else {
    my $filename = fileparse($file_pattern);
    if (not &is_safe_name($filename)) {
      die("Value \"$filename\" invalid for $desc (does not fit allowed file name pattern)\n");
    } elsif (not -e $filename) {
      die("Value \"$filename\" invalid for $desc (file does not exist)\n");
    }
    @files = ($filename);
  }
  if (ref($out_ref) eq 'ARRAY') {
    push(@{$out_ref}, @files);
  } else {
    if (scalar(@files) > 1) {
      die("Value \"$file_pattern\" invalid for $desc (matches multiple files when only one was expected)\n");
    }
    $$out_ref = $files[0];
  }
}

#
# opt_db_or_uploaded
# Returns a checker for use with Getopt::Long GetOptions method.
# Checker ensures that the file exists within the db directory.
#
sub opt_db_or_uploaded {
  my ($out_ref, $db_dir, $db_link) = @_;
  my $check_fn = sub {
    my ($opt, $file_pattern) = @_;
    &parse_db_or_uploaded($opt, $file_pattern, $out_ref, $db_dir, $db_link);
  };
  return $check_fn;
}

#
# parse_safe
# Parses a value and checks that it should be fine to use on a command line.
#
sub parse_safe {
  my ($opt, $value, $out_ref) = @_;
  my $desc = &_opt_desc($opt);
  if (not &is_safe_name($value)) {
    die("Value \"$value\" invalid for $desc (does not fit allowed command-line safe pattern)\n");
  }
  if (ref($out_ref) eq 'ARRAY') {
    push(@{$out_ref}, $value);
  } else {
    $$out_ref = $value;
  }
}

#
# opt_safe
# Returns a checker for use with Getopt::Long GetOptions method.
# Checker ensures that the text is a safe name.
#
sub opt_safe {
  my ($out_ref) = @_;
  my $check_fn = sub {
    my ($opt, $value) = @_;
    &parse_safe($opt, $value, $out_ref);
  };
  return $check_fn;
}

#
# parse_choice
# Parses a value and ensures it is one of the allowed choices.
#
sub parse_choice {
  my ($opt, $value, $out_ref, @choices) = @_;
  my $desc = &_opt_desc($opt);
  foreach my $choice (@choices) {
    if ($value eq $choice) {
      if (ref($out_ref) eq 'ARRAY') {
        push(@{$out_ref}, $choice);
      } else {
        $$out_ref = $choice;
      }
      return;
    }
  }
  my $options = (@choices > 1 ? join(', ', @choices[0..-1]) . ' or ' : '') . $choices[-1];
  die("Value \"$value\" invalid for $desc ($options expected)\n");
}

#
# opt_choice
# Returns a checker for use with Getopt::Long GetOptions method.
# Checker ensures that the text is one of the choices
#
sub opt_choice {
  my ($out_ref, @choices) = @_;
  my $check_fn = sub {
    my ($opt, $value) = @_;
    &parse_choice($opt, $value, $out_ref, @choices);
  };
  return $check_fn;
}

sub parse_encoded {
  my ($opt, $value, $out_ref) = @_;
  my $desc = &_opt_desc($opt);
  # copy the value
  my $temp_value = $value;
  # decode modified URL encoding ('_' instead of '%') to UTF-8 bytes
  $temp_value =~ s/_([0-9A-Fa-f]{2})/chr(hex($1))/eg;
  # decode UTF-8 bytes to internal Perl string
  my $decoded_value = decode("utf8", $temp_value);
  # set the output
  if (ref($out_ref) eq 'ARRAY') {
    push(@{$out_ref}, $decoded_value);
  } else {
    $$out_ref = $decoded_value;
  }
}

#
# opt_encoded
# Returns a checker for use with Getopt::Long GetOptions method.
# Checker ensures that the text is one of the choices
#
sub opt_encoded {
  my ($out_ref) = @_;
  my $check_fn = sub {
    my ($opt, $value) = @_;
    &parse_encoded($opt, $value, $out_ref);
  };
  return $check_fn;
}

#
# parse_integer
# Parses an integer, ensures that the integer x is min <= x <= max
#
sub parse_integer {
  my ($opt, $integer, $out_ref, $min, $max) = @_;
  my $desc = &_opt_desc($opt);
  if (defined($min) && $integer < $min) {
    die("Value $integer invalid for $desc (value >= $min expected)\n");
  } elsif (defined($max) && $integer > $max) {
    die("Value $integer invalid for $desc (value <= $max expected)\n");
  }
  if (ref($out_ref) eq 'ARRAY') {
    push(@{$out_ref}, $integer);
  } else {
    $$out_ref = $integer;
  }
}

#
# opt_integer
# Returns a checker for use with Getopt::Long GetOptions method.
# Checker ensures that the integer x is min <= x <= max
#
sub opt_integer {
  my ($out_ref, $min, $max) = @_;
  my $check_fn = sub {
    my ($opt, $integer) = @_;
    &parse_integer($opt, $integer, $out_ref, $min, $max);
  };
  return $check_fn;
}

#
# parse_number
# Ensures that the number passes all the constraints specified
# as operator + value pairs.
#
sub parse_number {
  my ($opt, $number, $out_ref, @op_vals) = @_;
  my $desc = &_opt_desc($opt);
  for (my $i = 0; ($i + 1) < scalar(@op_vals); $i += 2) {
    my $op = $op_vals[$i];
    my $val = $op_vals[$i + 1];
    my $test = 0;
    if ($op eq '<') {
      $test = $number < $val;
    } elsif ($op eq '<=') {
      $test = $number <= $val;
    } elsif ($op eq '==') {
      $test = $number == $val;
    } elsif ($op eq '>=') {
      $test = $number >= $val;
    } elsif ($op eq '>') {
      $test = $number > $val;
    } else {
      die("Value $number for $desc could not be tested due to unknown operator $op\n");
    }
    die("Value $number invalid for $desc (value $op $val expected)\n") unless $test;
  }
  if (ref($out_ref) eq 'ARRAY') {
    push(@{$out_ref}, $number);
  } else {
    $$out_ref = $number;
  }
}

#
# opt_number
# Returns a checker for use with Getopt::Long GetOptions method.
# Checker ensures that the number passes all the constraints specified
# as operator + value pairs.
#
sub opt_number {
  my ($out_ref, @op_vals) = @_;
  my $check_fn = sub {
    my ($opt, $number) = @_;
    &parse_number($opt, $number, $out_ref, @op_vals);
  };
  return $check_fn;
}

#
# parse_evalue
# Ensures that the evalue is positive.
#
sub parse_evalue {
  my ($opt, $evalue, $out_ref) = @_;
  my $desc = &_opt_desc($opt);
  if ($evalue <= 0) {
    die("Value $evalue invalid for $desc (not a valid e-value)\n");
  }
  if (ref($out_ref) eq 'ARRAY') {
    push(@{$out_ref}, $evalue);
  } else {
    $$out_ref = $evalue;
  }
}

#
# opt_evalue
# Returns a checker for use with Getopt::Long GetOptions method.
# Checker ensures that the evalue is positive.
#
sub opt_evalue {
  my ($out_ref) = @_;
  my $check_fn = sub {
    my ($opt, $evalue) = @_;
    &parse_evalue($opt, $evalue, $out_ref);
  };
  return $check_fn;
}

sub new {
  $logger->trace('call new StatusPage') if $logger;  
  my $classname = shift;
  my $self = {};
  bless($self, $classname);
  $self->_init(@_);
  return $self;
}

sub _init {
  $logger->trace('call StatusPage::_init') if $logger;  
  my $self = shift;
  my ($program, $argv, %opts) = @_;
  my @argv_copy = @{$argv};
  $self->{program} = $program;
  $self->{argv} = \@argv_copy;
  $self->{when} = [&Time::HiRes::gettimeofday()];
  $self->{page} = (defined($opts{PAGE}) ? $opts{PAGE} : 'index.html');
  $self->{log} = (defined($opts{LOG}) ? $opts{LOG} : lc($program) . '-log');
  $self->{output} = (defined($opts{OUTPUT}) ? $opts{OUTPUT} : 'messages.txt');
  $self->{status} = '';
  $self->{files} = [];
  $self->{file_keys} = {};
  $self->{messages} = [];
  $self->{cleanup} = sub {1;};
}

sub set_cleanup {
  my $self = shift;
  my ($cleanup_fn) = @_;
  $self->{cleanup} = $cleanup_fn;
}

sub add_file {
  $logger->trace('call StatusPage::add_file') if $logger;  
  my $self = shift;
  my ($key, $file, $desc, %opts) = @_;
  croak("Duplicate file key \"$key\"") if $self->{file_keys}->{$key};
  my $entry = {key => $key, file => $file, desc => $desc};
  my $target_key = $opts{BEFORE} || $opts{AFTER};
  if ($target_key) {
    my $target_i;
    for ($target_i = 0; $target_i < scalar(@{$self->{files}}); $target_i++) {
      last if ($self->{files}->[$target_i]->{key} eq $target_key);
    }
    splice(@{$self->{files}}, ($opts{BEFORE} ? $target_i : $target_i + 1), 0, $entry);
  } elsif ($opts{INDEX}) {
    splice(@{$self->{files}}, $opts{INDEX}, 0, $entry);
  } else {
    push(@{$self->{files}}, $entry); 
  }
  $self->{file_keys}->{$key} = 1;
}

sub update_file {
  $logger->trace('call StatusPage::update_file') if $logger;  
  my $self = shift;
  my ($key, %values) = @_;
  croak("File key \"$key\" does not exist") unless $self->{file_keys}->{$key};
  for (my $i = 0; $i < scalar(@{$self->{files}}); $i++) {
    if ($self->{files}->[$i]->{key} eq $key) {
      my $entry = $self->{files}->[$i];
      $entry->{file} = $values{FILE} if (defined($values{FILE}));
      $entry->{desc} = $values{DESC} if (defined($values{DESC}));
      last;
    }
  }
}

sub remove_file {
  $logger->trace('call StatusPage::remove_file') if $logger;  
  my $self = shift;
  my ($key) = @_;
  return unless $self->{file_keys}->{$key};
  for (my $i = 0; $i < scalar(@{$self->{files}}); $i++) {
    if ($self->{files}->[$i]->{key} eq $key) {
      splice(@{$self->{files}}, $i, 1);
      last;
    }
  }
  delete $self->{file_keys}->{$key};
}

sub add_message {
  $logger->trace('call StatusPage::add_message') if $logger;  
  my $self = shift;
  my ($message) = @_;
  push(@{$self->{messages}}, {msg => $message});
}

sub update {
  $logger->trace('call StatusPage::update') if $logger;  
  my $self = shift;
  my ($status) = @_;
  $status = '' unless defined $status;

  my @found_files = ();
  foreach my $entry (@{$self->{files}}) {
    my $file = $entry->{'file'};
    my $desc = $entry->{'desc'};
    if (defined($file) && -e $file && -s $file) {
      push(@found_files, {file => $file, desc => $desc});
    }
  }

  my $fh;
  sysopen($fh, $self->{page}, O_CREAT | O_WRONLY | O_TRUNC) 
      or _log_and_die("Failed to open \"" . $self->{page} . "\".");
  my $template = HTML::Template->new(filename => '/home/ubuntu/meme/share/meme-5.0.5/job_status.tmpl');
  $template->param(
    program => $self->{program},
    files => \@found_files,
    msgs => $self->{messages},
    status => $status
  );
  print $fh $template->output;
  close($fh) or _log_and_die("Failed to close \"" . $self->{page} . "\".");
}

sub remaining_time {
  $logger->trace('call StatusPage::remaining_time') if $logger;  
  my $self = shift;
  return $Globals::MAXTIME - int(&Time::HiRes::tv_interval($self->{when}, [&Time::HiRes::gettimeofday()]) + 0.5);
}

sub load_alphabet {
  $logger->trace('call StatusPage::load_alphabet') if $logger;  
  my $self = shift;
  my ($type, $file) = @_;
  my $alphabet;
  if (defined($file)) {
    eval { $alphabet = new Alphabet($file); };
    if ($@) {
      my $message = "Failed to load alphabet definition from \"$file\".\n" . $@;
      $self->add_message($message);
      print STDERR $message;
      $self->update("Error");
      $self->write_log();
      exit(1);
    }
  } else {
    $alphabet = ($type eq 'RNA' ? rna() : ($type eq 'DNA' ? dna() : protein()));
  }
  return $alphabet;
}

sub run {
  $logger->trace('call StatusPage::run') if $logger;  
  my $self = shift;
  my (%invk_opts) = @_;

  $self->add_file('tidings', $self->{output}, 'Warning Messages') unless $self->{file_keys}->{tidings};

  my $prog = $invk_opts{PROG};
  my @args = @{$invk_opts{ARGS}};

  unless (defined($invk_opts{ALL_FILE}) || defined($invk_opts{ALL_VAR}) || 
    ((defined($invk_opts{OUT_FILE}) || defined($invk_opts{OUT_VAR})) &&
      (defined($invk_opts{ERR_FILE}) || defined($invk_opts{ERR_VAR})))) {
    # we can redirect something!
    if (defined($invk_opts{OUT_FILE}) || defined($invk_opts{OUT_VAR})) {
      # redirect ERR output
      $invk_opts{ERR_FILE} = $self->{output};
      $invk_opts{ERR_TRUNCATE} = 0;
    } elsif (defined($invk_opts{ERR_FILE}) || defined($invk_opts{ERR_VAR})) {
      # redirect OUT output
      $invk_opts{OUT_FILE} = $self->{output};
      $invk_opts{OUT_TRUNCATE} = 0;
    } else {
      # we can redirect everything!
      $invk_opts{ALL_FILE} = $self->{output};
      $invk_opts{TRUNCATE} = 0;
    }
  }

  $self->add_message('Starting '.$prog.'<br><code>' . stringify_args_noesc($prog, @args) . '</code>');
  $self->update("Starting");

  my ($time, $oot, $status_code);
  $oot = 0; # FALSE
  unless (defined($invk_opts{TIMEOUT})) {
    $invk_opts{TIMEOUT} = $self->remaining_time();
  }
  $invk_opts{TIME} = \$time;
  $invk_opts{OOT} = \$oot;
  # run the program
  $status_code = invoke(%invk_opts);
  my $status_msg;
  if ($oot) {
    $status_msg = "Ran out of time! Stopping $prog.";
    $self->add_message($status_msg);
    print STDERR $status_msg, "\n";
  }
  my $err = ($status_code != 0 || $oot);
  if ($err) {
    if ($status_code == -1) {
      $status_msg = $prog . " failed to run";
    } elsif ($status_code & 127) {
      $status_msg = $prog . " process died with signal " . 
          ($status_code & 127) . ", " . 
          (($status_code & 128) ? 'with' : 'without') . " coredump";
    } else {
      $status_msg = $prog . " exited with error code " . ($status_code >> 8);
    }
    print STDERR $status_msg, "\n";
    $self->update_file('tidings', DESC => 'Error Messages');
  } else {
    $status_msg = $prog . ' ran successfully in ' . 
        (int($time * 100 + 0.5) / 100) . ' seconds';
  }
  $self->add_message($status_msg);
  $self->update($err ? "Error" : "");
  if ($err) {
    $self->write_log();
    exit(1);
  }
}

sub write_log {
  $logger->trace('call StatusPage::write_log') if $logger;  
  my $self = shift;
  # the host
  my $host = hostname;
  # the current directory without path
  my $jobid = (splitdir(getcwd()))[-1];
  # the unique user identifier (aka universally unique identifier)
  my $uuid = 'no_uuid_specified';
  if (-e 'uuid') {
    $uuid = `cat uuid`;
    unlink 'uuid';
  }
  # the command line arguments
  my $args = stringify_args(@{$self->{argv}});
  # convert timestamp into start time and end time
  my $start_time = &_format_log_date($self->{when}->[0]);
  # the submission time if it is avaliable but use the start time as a default
  my $submit_time = $start_time;
  if (-e 'submit_time_file') {
    $submit_time = `cat submit_time_file`;
    unlink 'submit_time_file';
  }
  # the end time (now)
  my $end_time = &_format_log_date(&Time::HiRes::gettimeofday());
  # create the path to the log file
  my $logfile = catfile('/home/ubuntu/meme/var/meme-5.0.5/LOGS', $self->{log});
  # open the log file for appending
  my $logfh;
  sysopen($logfh, $logfile, O_CREAT | O_APPEND | O_WRONLY) 
      or &_log_and_die("Unable to open invocation log for appending ($logfile).");
  # write out the invocation log
  print $logfh "$host $jobid submit: $submit_time start: $start_time end: $end_time $args $uuid\n"; 
  # close the log file
  close($logfh);
  # cleanup
  $self->{cleanup}->();
}

sub _opt_desc {
  my ($opt) = @_;
  # this trick should apparently differentiate between "0" and 0
  if (length( do { no warnings "numeric"; $opt & "" } )) {
    my $num = $opt + 1;
    if ($num == 1) {
      return '1st non-option';
    } elsif ($num == 2) {
      return '2nd non-option';
    } elsif ($num == 3) {
      return '3rd non-option';
    } else {
      return $num . 'th non-option';
    }
  } else {
    return 'option ' . $opt;
  }
}

sub _format_log_date {
  $logger->trace('call _format_log_date') if $logger;  
  my ($seconds_since_epoch) = @_;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($seconds_since_epoch);
  return sprintf('%02d/%02d/%02d %02d:%02d:%02d', $mday, $mon + 1, $year % 100, $hour, $min, $sec);  
}

sub _log_and_die {
  if ($logger) {
    $Log::Log4perl::caller_depth++;
    $logger->logdie(@_);
  } else {
    die(@_);
  }
}
