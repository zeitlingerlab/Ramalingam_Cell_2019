# File: MemeWebUtils.pm
# Project: Website CGI
# Description: MemeWebUtils.pm made from MemeWebUtils.pm.in by make. Helper functions for CGI pages.

package MemeWebUtils;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(is_safe_name add_status_msg update_status 
    loggable_date write_invocation_log eps_to_png find_in_dir
    dir_listing_set dir_listing added_files create_tar report_start report_status);

use Cwd qw(getcwd realpath abs_path);
use Fcntl qw(O_APPEND O_CREAT O_WRONLY O_TRUNC);
use File::Spec::Functions qw(catfile splitdir splitpath tmpdir abs2rel no_upwards);
use HTML::Template;
use Sys::Hostname;
use Time::HiRes qw(gettimeofday tv_interval);

use lib qw(/home/ubuntu/meme/lib/meme-5.0.5/perl);
use ExecUtils qw(invoke stringify_args);

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

my $service_invocation_log_dir = '/home/ubuntu/meme/var/meme-5.0.5/LOGS';
my $tmpdir = '';
# use the perl default if none is supplied or the replace fails
$tmpdir = &tmpdir() if ($tmpdir eq '' || $tmpdir =~ m/^\@TMP[_]DIR\@$/);
my @gs_version_nums = ();
my $GHOSTSCRIPT = '/usr/bin/gs';
my $CONVERT = '/usr/bin/convert';
##############################################################################
#          Functions
##############################################################################

sub log_and_die {
  if ($logger) {
    $Log::Log4perl::caller_depth++;
    $logger->logdie(@_);
  } else {
    die(@_);
  }
}

my $SAFE_NAME_CHARACTERS = 'a-zA-Z0-9:_\.\-';

# Checks that a file name has only whitelisted characters in it and does
# not have a leading dash
sub is_safe_name {
  $logger->trace('call is_safe_name') if $logger;
  my ($name) = @_;
  if ($name =~ /^[$SAFE_NAME_CHARACTERS]*$/ && $name !~ /^-/) {
    return 1;
  }
  return 0;
}

#
# add_status_msg
#
# Adds a message to the message list
# and returns the list. For use with
# update_status.
#
sub add_status_msg {
  $logger->trace('call add_status_msg') if $logger;
  my ($msg, $msg_list) = @_;
  push(@$msg_list, {msg => $msg});
  return $msg_list;
}

#
# update_status
#
# Creates or updates the specified status file to contain the
# file list only showing each of the files if they exist and
# the message list.
#
sub update_status {
  $logger->trace('call update_status') if $logger;
  my ($output_file, $program, $refresh, $files_list, $msg_list, $status) = @_;

  my @found_files = ();
  foreach my $entry (@$files_list) {
    my $file = $entry->{'file'};
    push(@found_files, $entry) if (defined($file) && -e $file && -s $file);
  }

  my $fh;
  sysopen($fh, $output_file, O_CREAT | O_WRONLY | O_TRUNC) or log_and_die("Failed to open \"$output_file\".");
  my $template = HTML::Template->new(filename => '/home/ubuntu/meme/share/meme-5.0.5/job_status.tmpl');
  $template->param(program => $program, files => \@found_files, msgs => $msg_list, status => $status);
  print $fh $template->output;
  close($fh) or log_and_die("Failed to close \"$output_file\".");
}

#
# loggable_date
#
# Creates a date string that is suitable for putting in the service invocation log.
#
sub loggable_date {
  $logger->trace('call loggable_date') if $logger;
  my $timestamp = shift;
  $timestamp = time() unless defined($timestamp);
  # old method 
  # return `date -u '+%d/%m/%y %H:%M:%S'`;
  # new method that doesn't require forking a new process
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($timestamp);
  return sprintf('%02d/%02d/%02d %02d:%02d:%02d', $mday, $mon + 1, $year % 100, $hour, $min, $sec);
}

#
#
# write_invocation_log 
#
# Writes the date and time of a service's invocation to a log file
#
sub write_invocation_log {
  $logger->trace('call write_invocation_log') if $logger;
  my ($file, $start_time, $args) = @_;
  # the host
  my $host = hostname;
  # the current directory without path
  my $jobid = (splitdir(getcwd()))[-1];
  # the submission time if it is avaliable but use the start time as a default
  my $submit_time = $start_time;
  if (-e 'submit_time_file') {
    $submit_time = `cat submit_time_file`;
    unlink 'submit_time_file';
  }
  # the end time (now)
  my $end_time = loggable_date();
  # the unique user identifier (aka universally unique identifier)
  my $uuid = 'no_uuid_specified';
  if (-e 'uuid') {
    $uuid = `cat uuid`;
    unlink 'uuid';
  }

  my $logfile = catfile($service_invocation_log_dir, $file);
  my $logfh;
  sysopen($logfh, $logfile, O_CREAT | O_APPEND | O_WRONLY) or log_and_die("Unable to open invocation log for appending ($logfile).");
  print $logfh "$host $jobid submit: $submit_time start: $start_time end: $end_time $args $uuid\n"; 
  close($logfh);

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
  my $dir_abs = realpath($dir);
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

sub dir_listing_set {
  my ($dir) = @_;
  my @list = &dir_listing($dir);
  my %set = ();
  foreach my $file (@list) {
    $set{$file} = 1;
  }
  return \%set;
}

sub dir_listing {
  my ($dir) = @_;
  my @list = ();
  my $dirh;
  opendir($dirh, $dir);
  while (1) {
    my $fname = readdir($dirh);
    last unless defined($fname);
    next if ($fname eq '.' || $fname eq '..');
    my $file = catfile($dir, $fname);
    if (-d $file) {
      unless (-l $file) { # skip symlinks
        push(@list, &dir_listing($file));
      }
    } else {
      push(@list, $file);
    }
  }
  closedir($dirh);
  return @list;
}

sub added_files {
  my ($before, $after) = @_;
  my @list = ();
  foreach my $file (keys %{$after}) {
    push(@list, $file) unless ($before->{$file});
  }
  return @list;
}

sub create_tar {
  my ($report, $msg_list, $page, $program, $refresh, $file_list, @tar_files) = @_;
  my ($folder, $folder_dir, $tarname, $t0, $t1, $time, $status);
  # we want to tar including the containing directory
  # find the real name of the containing directory
  $folder = (splitdir(abs_path()))[-1];
  $folder_dir = abs_path('..');
  # append the folder to the tar_files
  for (my $i = 0; $i < scalar(@tar_files); $i++) {
    $tar_files[$i] = abs2rel(abs_path($tar_files[$i]), $folder_dir);
  }
  $tarname = $folder . ".tar.gz";
  my @args = ('-czf', $tarname, '-C', $folder_dir, @tar_files);
  &report_start('Tar', 'tar', $msg_list, $page, $program, $refresh, $file_list, @args) if ($report);
  $t0 = [&gettimeofday()];
  # run tar
  $status = system('tar', @args);
  $t1 = [&gettimeofday()];
  $time = &tv_interval($t0, $t1);
  &report_status('Tar', $status, $time) if ($report);
  return $tarname;
}

sub report_start {
  my ($name, $prog, $msg_list, $page, $main_program, $refresh, $file_list, @args) = @_;
  add_status_msg('Starting <b>'.$name.'</b><br><code>' . stringify_args($prog, @args) . '</code>', $msg_list);
  update_status($page, $main_program, $refresh, $file_list, $msg_list, "Running");
}

sub report_status {
  my ($name, $status_code, $time, $msg_list, $page, $program, $file_list, $log_file, $log_date, $log_args) = @_;

  my $status_msg;
  if ($status_code != 0) {
    if ($status_code == -1) {
      $status_msg = $name . " failed to run";
    } elsif ($status_code & 127) {
      $status_msg = '<b>' . $name . "</b> process exited with signal " . ($status_code & 127);
    } else {
      $status_msg = '<b>' . $name . "</b> exited with error code " . ($status_code >> 8);
    }
    $status_msg = '<span style="color: #800000">'.$status_msg.'</span>';
  } else {
    $status_msg = '<span style="color: #008000"><b>'. $name . '</b> ran successfully in <b>' . 
        (int($time * 100 + 0.5) / 100) . '</b> seconds</span>';
  }
  add_status_msg($status_msg, $msg_list);

  update_status($page, $program, 0, $file_list, $msg_list, 
      ($status_code ? "Error" : ""));

  if ($status_code) {
    write_invocation_log($log_file, $log_date, $log_args);
    exit(1);
  }
}

#
# eps_to_png
#
# Converts an EPS file into a png file
#
sub eps_to_png {
  $logger->trace('call eps_to_png') if $logger;
  my ($eps_filename, $png_filename, $messages) = @_;
  my @gs_args = ('-q', '-r100', '-dSAFER', '-dBATCH', '-dNOPAUSE', 
    '-dDOINTERPOLATE', '-sDEVICE=pngalpha', '-dBackgroundColor=16#FFFFFF', 
    '-dTextAlphaBits=4', '-dGraphicsAlphaBits=4', '-dEPSCrop', 
    '-sOutputFile='. $png_filename, $eps_filename);
  my @convert_args = ('eps:'.$eps_filename, 'png:'.$png_filename);
  my $status = -1;
  if (&_gs_ok()) {
    $status = invoke(
      PROG => $GHOSTSCRIPT,
      ARGS => \@gs_args,
      ALL_VAR => $messages
    );
  } elsif (&_im_ok()) {
    $status = invoke(
      PROG => $CONVERT,
      ARGS => \@convert_args,
      ALL_VAR => $messages
    );
    return system($CONVERT, @convert_args);
  } else {
    return 1;
  }
}

#
# Private Function
#
# Gets the version of ghostscript installed
#
sub _gs_version {
  return @gs_version_nums if (@gs_version_nums);
  @gs_version_nums = (-1); # default to failure 
  if (-e $GHOSTSCRIPT && -x $GHOSTSCRIPT) {
    my @nums = map(int, split(/\./, `$GHOSTSCRIPT --version`));
    if (@nums) {
      @gs_version_nums = @nums;
    }  
  }
  return @gs_version_nums;
}

#
# Private Function
#
# Returns true if ghostscript is ok to use
#
sub _gs_ok {
  my @ver = _gs_version();
  return $ver[0] >= 8;
}

#
# Private Function
#
# Returns true if image magicks convert is ok to use
#
sub _im_ok {
  return -e $CONVERT && -x $CONVERT;
}


1; #modules must return true
