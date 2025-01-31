#!/usr/bin/python3

import json, sys, string, copy, time
from math import log, pow, floor, exp

# MEME Suite libraries
sys.path.append('/home/ubuntu/meme/lib/meme-5.0.5/python')
import alphabet_py3 as alphabet
import sequence_py3 as sequence
from hypergeometric_py3 import getLogFETPvalue

# Format for printing very small numbers; used by sprint_logx
_pv_format = "%4.1fe%+04.0f"
_log10 = log(10)


# print very large or small numbers
def sprint_logx(logx, prec, format):
    """ Print x with given format given logx.  Handles very large
    and small numbers with prec digits after the decimal.
    Returns the string to print."""
    log10x = logx/_log10
    e = floor(log10x)
    m = pow(10, (log10x - e))
    if ( m + (.5*pow(10,-prec)) >= 10):
        m = 1
        e += 1
    str = format % (m, e)
    return str

def get_rc(word, alph):
    rcword = []
    for sym in reversed(word):
        rcword.append(alph.getComplement(sym))
    return "".join(rcword)

def get_strings_from_seqs(seqs):
    """ Extract strings from FASTA sequence records.
    """
    strings = []
    for s in seqs:
        strings.append(s.getString())
    return strings

def get_min_hamming_dists(seqs, word, alph, given_only):
    """
    Return a list of the number of sequences whose minimum
    Hamming distance to the given word or its reverse complement
    is X, for X in [0..w].

    Also returns a list with the best distance for each sequence.

    Also returns a list with the offset (1-relative) of the leftmost
    match to the word in each sequence. (Matches to reverse
    complement of the word have negative offsets.)

    Returns: counts, dists, offsets
    """
    use_rc = not given_only
    w = len(word)
    alen = alph.getLen()
    # encode the word into sets of indexes
    eword_given = [alph.getComprisingIndexes(sym) for sym in word]
    # get the encoded reverse complement of the word
    eword_rc = [alph.getComprisingIndexes(sym) for sym in get_rc(word, alph)] if use_rc else None
    # get minimum distances
    counts = [0 for _ in range(w+1)]
    dists = []
    offsets = []
    for seq in seqs:
        s = alph.encodeString(seq)
        # loop over all words in current sequence to get minimum distance
        min_dist = w
        best_offset = 0                 # no site in sequence
        for i in range(0, len(s)-w+1):
            # loop over strands
            for strand in [1, -1]:
                eword = eword_given if strand == 1 else eword_rc
                dist = 0
                # loop over position in words
                for j in range(w):
                    esyms = eword[j]
                    esym = s[i+j]
                    # don't allow ambiguous characters in match
                    if esym >= alen:
                        dist = w+1;
                        break
                    if esym not in esyms:
                        dist += 1
                        if dist >= min_dist:
                            break
                if dist < min_dist:
                    min_dist = dist
                    best_offset = strand * (i + 1)
                    # exit loop early if we've already found a perfect match
                    if min_dist == 0:
                        break
                # optionally skip negative strand
                if not use_rc:
                    break
            # exit loop early if we've already found a perfect match
            if min_dist == 0:
                break
        # update status
        counts[min_dist] += 1
        dists.append(min_dist) # best distance for sequence
        offsets.append(best_offset) # best offset in sequence
    # results
    return counts, dists, offsets


def get_best_hamming_enrichment(word, pos_seqs, neg_seqs, alph, given_only, print_dists):
    """
    Find the most enriched Hamming distance for given word.
    Returns (best_dist, best_log_pvalue, pos_dists, pos_offsets, best_p, best_n)
    Pos_dists[s] is best distance for sequence s.
    Pos_offsets[s] is offset to the leftmost best match in sequence s.
    Offsets are 1-relative; match on reverse complement has negative offset.
    """

    # compute Hamming distance from input word
    # print >> sys.stderr, "Computing Hamming distances..."
    (pos_counts, pos_dists, pos_offsets) = get_min_hamming_dists(pos_seqs, word, alph, given_only)
    (neg_counts, neg_dists, neg_offsets) = get_min_hamming_dists(neg_seqs, word, alph, given_only)

    (best_dist, best_log_pvalue, best_p, best_n) = \
            get_best_hamming_enrichment_from_counts(len(word), len(pos_seqs), len(neg_seqs), \
                    pos_counts, neg_counts)

    return best_dist, best_log_pvalue, pos_dists, pos_offsets, best_p, best_n


def get_best_hamming_enrichment_from_counts(w, P, N, pos_counts, neg_counts, print_dists=False):
    """
    Find the most enriched Hamming distance for given counts.
    Returns (best_dist, best_log_pvalue, best_p, best_n)
    """

    # get cumulative counts
    cum_pos_counts = copy.copy(pos_counts)
    cum_neg_counts = copy.copy(neg_counts)
    for i in range(1, len(pos_counts)):
        cum_pos_counts[i] += cum_pos_counts[i-1]
        cum_neg_counts[i] += cum_neg_counts[i-1]

    # compute hypergeometric enrichment at each distance and save best
    best_dist = w
    best_log_pvalue = 1     # infinity
    best_p = 0
    best_n = 0
    for i in range(len(pos_counts)):
        p = cum_pos_counts[i]
        n = cum_neg_counts[i]
        log_pvalue = getLogFETPvalue(p, P, n, N, best_log_pvalue)
        if log_pvalue < best_log_pvalue:
            best_log_pvalue = log_pvalue
            best_dist = i
            best_p = p
            best_n = n
        if print_dists:
            pv_string = sprint_logx(log_pvalue, 1, _pv_format)
            print("d %d : %d %d %d %d %s" % (i, p, P, n, N, pv_string))

    return best_dist, best_log_pvalue, best_p, best_n


def get_enrichment_and_neighbors(word, min_log_pvalue, pos_seqs, neg_seqs, alph, given_only):
    """
    Find the Hamming enrichment of the given word.
    If pvalue under given pvalue, estimate the Hamming
    enrichment for each distance-1 neighbor of the given word.
    Returns word_pvalue_record, neighbor_pvalue_records (dict).
    pvalue_record = [p, P, n, N, log_pvalue, dist]
    """

    # compute Hamming distance from input word
    #print >> sys.stderr, "Getting Hamming counts, distances and offsets in positive sequences..."
    (pos_counts, pos_dists, pos_offsets) = get_min_hamming_dists(pos_seqs, word, alph, given_only)
    #print >> sys.stderr, "Getting Hamming counts, distances and offsets in negative sequences..."
    (neg_counts, neg_dists, neg_offsets) = get_min_hamming_dists(neg_seqs, word, alph, given_only)

    P = len(pos_seqs)
    N = len(neg_seqs)
    w = len(word)
    #print >> sys.stderr, "Getting Hamming enrichment for consensus", word, "from counts"
    (dist, log_pvalue, p, n) = get_best_hamming_enrichment_from_counts(w, P, N, pos_counts, neg_counts)

    # create p-value record
    pvalue_record = [p, P, n, N, log_pvalue, dist]
    neighbors = {}
    print("Exact p-value of", word, "is", sprint_logx(log_pvalue, 1, _pv_format), pvalue_record, file=sys.stderr)

    # short-circuit
    if log_pvalue >= min_log_pvalue:
        return pvalue_record, neighbors

    # get PWM and nsites arrays for each exact Hamming distance
    (pos_freqs, pos_nsites) = get_freqs_and_nsites(w, pos_dists, pos_offsets, pos_seqs, alph)
    (neg_freqs, neg_nsites) = get_freqs_and_nsites(w, neg_dists, neg_offsets, neg_seqs, alph)

    # get estimated counts of sequences at each Hamming distance for each possible Hamming-1 move.
    print("Estimating Hamming distance counts in positive sequences...", file=sys.stderr)
    pos_neighbor_counts = estimate_new_hamming_counts(word, alph, pos_counts, pos_freqs, pos_nsites)
    print("Estimating Hamming distance counts in negative sequences...", file=sys.stderr)
    neg_neighbor_counts = estimate_new_hamming_counts(word, alph, neg_counts, neg_freqs, neg_nsites)

    # compute the estimated enrichment p-value for each Hamming-1 move
    print("Finding best neighbors...", file=sys.stderr)
    alen = alph.getFullLen()
    for col in range(w):
        for let in range(alen):
            if let == alph.getIndex(word[col]):
                continue
            new_word = word[:col] + alph.getSymbol(let) + word[col+1:]
            p_counts = pos_neighbor_counts[col][let]
            n_counts = neg_neighbor_counts[col][let]
            (dist, log_pvalue, p, n) = get_best_hamming_enrichment_from_counts(w, P, N, p_counts, n_counts)
            new_pvalue_record = [p, P, n, N, log_pvalue, dist]
            neighbors[new_word] = new_pvalue_record

    return(pvalue_record, neighbors)


def get_freqs_and_nsites(w, dists, offsets, seqs, alph):
    """
    Get PWMs and numbers of sites for each exact Hamming distance.
    Returns (freqs[d], nsites[d]).
    """

    freqs = []
    nsites = []
    # iterate over hamming distances
    for d in range(w+1):
        # get alignments for a hamming distance == d
        aln = get_aln_from_dists_and_offsets(w, d, d, dists, offsets, seqs, alph)
        # make frequency matrix
        pwm = sequence.PWM(alph)
        pwm.setFromAlignment(aln)
        freqs.append(pwm.getFreq())
        nsites.append(len(aln))
        #print "getting freqs for d", d

    return freqs, nsites


def estimate_new_hamming_counts(word, alph, counts, freqs, nsites):
    """
    Return neighbor_counts[col][let][dist] list estimated if old_let
    were replaced by let.  List contains estimated counts of sequences
    containing the neighboring word.
    """

    # estimate counts for each Hamming-1 neighbor of given word
    w = len(word)
    # [col][let] = counts
    neighbor_counts = []
    # column to change
    for col in range(w):
        neighbor_counts.append([])
        old_comprise = alph.getComprisingIndexes(word[col])
        # new letter index
        for symi in range(alph.getFullLen()):
            new_comprise = alph.getComprisingIndexes(symi)
            neighbor_counts[col].append(
                estimate_new_hamming_counts_col_let(
                    counts, freqs, nsites, w, col, old_comprise, new_comprise))
    return neighbor_counts


def estimate_new_hamming_counts_col_let(counts, freqs, nsites, max_dist, col, old_comprise, new_comprise):
    """
    Return counts[dist] list estimated if old_comprise were replaced by new_comprise
    in column col.
FIXME: could add columns on either side of freqs array so we can do "lengthen" and "shift" moves.
    freqs[d][col] is the frequency column of the alignment of nsites[d] sites with
    Hamming distance d (PWM of sites at Hamming distance d).
    old/new_comprise are the sets of the indexes of the comprising core symbols
    so for example DNA's N is frozenset([0,1,2,3]) and DNA's S is frozenset([1,2]) .
    """

    # initialize the counts
    new_counts = copy.copy(counts)

    # done if same letter
    if old_comprise == new_comprise:
        return new_counts

    for d in range(max_dist+1):
        up = down = 0
        n = nsites[d]
        # no counts at this distance?
        if len(freqs[d]) == 0:
            continue
        f = freqs[d][col]
        # sites that moved up
        up = int(round(n * sum([f[symi] for symi in new_comprise.difference(old_comprise)])))
        # sites that moved down
        down = int(round(n * sum([f[symi] for symi in old_comprise.difference(new_comprise)])))
        # update the counts at this distance
        new_counts[d] -= up + down
        # update the counts at distances above and below this one
        if d > 0:
            new_counts[d-1] += up
        if d < max_dist:
            new_counts[d+1] += down

    return new_counts

def get_aln_from_dists_and_offsets(w, d1, d2, dists, offsets, seqs, alph):
    """
    Get an alignment of the leftmost best site in each sequence.
    Site must have d1 <= distance <= d2.
    """

    aln = []
    for i in range(len(seqs)):
        dist = dists[i]
        # only include match if within distance range
        if dist <= d2 and d1 <= dist:
            offset = offsets[i]
            if offset == 0:
                continue
            if offset > 0:
                start = offset-1
            else:
                start = -offset - 1
            match = seqs[i][start : start+w]
            if offset < 0:
                match = get_rc(match, alph)
            aln.append(match)
    return aln

def erase_word_distance(word, dist, seqs, alph, given_only):
    """
    Erase all non-overlapping matches to word in seqs by changing to 'N'.
    Greedy algorithm erases leftmost site first.
    Site must be within given Hamming distance to be erased.
    """
    (counts, dists, offsets) = get_min_hamming_dists(seqs, word, alph, given_only)
    w = len(word)
    ens = w * alph.getWildcard()
    for i in range(len(seqs)):
        d = dists[i]
        # only erase match if within distance range
        min_offset = 1
        if d == dist:
            offset = offsets[i]
            if offset == 0: continue
            if offset > 0:
                if offset < min_offset: continue
                start = offset-1
            else:
                if -offset < min_offset: continue
                start = -offset - 1
            min_offset = start + w  # enforce non-overlap

            seqs[i] = seqs[i][:start] + ens + seqs[i][start+w:]


def get_aln_from_word(word, d1, d2, seqs, alph, given_only):
    """
    Get an alignment of the leftmost best site in each sequence.
    Site must have d1 <= distance <= d2.
    """
    (counts, dists, offsets) = get_min_hamming_dists(seqs, word, alph, given_only)
    # get the alignment of the best sites
    return get_aln_from_dists_and_offsets(len(word), d1, d2, dists, offsets, seqs, alph)


def get_best_hamming_alignment(word, pos_seqs, neg_seqs, alph, given_only, print_dists=False):
    """
    Find the most enriched Hamming distance to the word.
    Get the alignment of the matching sites (ZOOPS).

    Returns dist, log_pvalue, p, P, n, N, aln
    """

    # get best Hamming enrichment
    (best_dist, best_log_pvalue, dists, offsets, p, n) = get_best_hamming_enrichment(word, pos_seqs, neg_seqs, alph, given_only, print_dists)

    # get the alignment of the best sites
    aln = get_aln_from_dists_and_offsets(len(word), 0, best_dist, dists, offsets, pos_seqs, alph)

    return best_dist, best_log_pvalue, p, len(pos_seqs), n, len(neg_seqs), aln


def print_meme_header(alph):
    sys.stdout.write("\nMEME version 4\n\n")
    if alph == alphabet.getByName("DNA") or alph == alphabet.getByName("Protein"):
        sys.stdout.write("ALPHABET= {}\n\n".format("".join(alph.getSymbols())))
    else:
        sys.stdout.write("ALPHABET {}\n".format(json.dumps(alph.getName())))
        sys.stdout.write(alph.asText())
        sys.stdout.write("END ALPHABET\n\n")
    if alph.isComplementable():
        sys.stdout.write("strands: + -\n\n")
    sys.stdout.write("Background letter frequencies (from uniform background):\n")
    freq = 1.0 / alph.getLen()
    for sym in alph.getSymbols():
        sys.stdout.write("{:s} {:.4f} ".format(sym, freq))
    sys.stdout.write("\n");


def print_meme_motif(word, nsites, ev_string, aln, alph):

    # make the PWM
    pwm = sequence.PWM(alph)
    pwm.setFromAlignment(aln)

    # print PWM in MEME format
    alen = alph.getLen()
    w = len(word)
    print("\nMOTIF %s\nletter-probability matrix: alength= %d w= %d nsites= %d E= %s" % \
            (word, alen, w, nsites, ev_string))
    for row in pwm.pretty():
        print(row)
    print("")

def sorted_re_pvalue_keys(re_pvalues):
    """ Return the keys of a p-value dictionary, sorted by increasing p-value """
    if not re_pvalues: return []
    keys = list(re_pvalues.keys())
    keys.sort( lambda x, y: cmp(re_pvalues[x][4], re_pvalues[y][4]) or cmp(x,y) )
    return keys

def get_best_neighbor(word, min_log_pvalue, pos_seqs, neg_seqs, alph, given_only):
    # returns the log pvalue of the word and the best Hamming distance-1 neighbor

    # estimate the p-values of Hamming distance-1 neighbors
    (pvalue_record, neighbors) = get_enrichment_and_neighbors(word, min_log_pvalue, pos_seqs, neg_seqs, alph, given_only)

    # if the p-value of the word is too large, quit
    if pvalue_record[4] >= min_log_pvalue or not neighbors:
        return pvalue_record[4], ""

    # return the best neighbor (estimated)
    (best_pvalue, best_word) = min([ (neighbors[tmp][4],tmp) for tmp in neighbors] )
    print("original", word, sprint_logx(pvalue_record[4], 1, _pv_format), "best neighbor (estimated)", best_word, sprint_logx(best_pvalue, 1, _pv_format))
    return pvalue_record[4], best_word

def refine_consensus(word, pos_seqs, neg_seqs, alph, given_only):

    best_log_pvalue = 1
    best_word = word
    while 1:
        (log_pvalue, neighbor) = get_best_neighbor(word, best_log_pvalue, pos_seqs, neg_seqs, alph, given_only)
        if log_pvalue >= best_log_pvalue:               # didn't improve
            break
        else:                                           # improved
            best_word = word
            best_log_pvalue = log_pvalue
            word = neighbor

    return(best_word, best_log_pvalue)

def main():

    pos_seq_file_name = None        # no positive sequence file specified
    neg_seq_file_name = None        # no negative sequence file specified
    alphabet_file_name = None
    refine = False
    given_only = False

    #
    # get command line arguments
    #
    usage = """USAGE:
    %s [options]

    -w <word>               word (required)
    -p <file_name>          positive sequences FASTA file name (required)
    -n <file_name>          negative sequences FASTA file name (required)
    -a <file_name>          alphabet definition file
    -r                      refine consensus by branching search
                            (distance 1 steps; beam size = 1).
    -h                      print this usage message

    Compute the Hamming distance from <word> to each FASTA sequence
    in the positive and negative files.  Apply Fisher's Exact test to
    each distance.
    <word> may contain ambiguous characters.

    """ % (sys.argv[0])

    # no arguments: print usage
    if len(sys.argv) == 1:
        print(usage, file=sys.stderr); sys.exit(1)

    # parse command line
    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]
        if (arg == "-w"):
            i += 1
            try: word = sys.argv[i]
            except: print(usage, file=sys.stderr); sys.exit(1)
        elif (arg == "-p"):
            i += 1
            try: pos_seq_file_name = sys.argv[i]
            except: print(usage, file=sys.stderr); sys.exit(1)
        elif (arg == "-n"):
            i += 1
            try: neg_seq_file_name = sys.argv[i]
            except: print(usage, file=sys.stderr); sys.exit(1)
        elif (arg == "-a"):
            i += 1
            try: alphabet_file_name = sys.argv[i]
            except: print(usage, file=sys.stderr); sys.exit(1)
        elif (arg == "-r"):
            try: refine = True
            except: print(usage, file=sys.stderr); sys.exit(1)
        elif (arg == "-h"):
            print(usage, file=sys.stderr); sys.exit(1)
        else:
            print(usage, file=sys.stderr); sys.exit(1)
        i += 1

    # check that required arguments given
    if (pos_seq_file_name == None or neg_seq_file_name == None):
        print(usage, file=sys.stderr); sys.exit(1)

    # keep track of time
    start_time = time.time()

    # read alphabet
    alph = None
    if alphabet_file_name != None:
        alph = alphabet.loadFromFile(alphabet_file_name)
    else:
        alph = alphabet.dna()

    # read sequences
    print("Reading sequences...", file=sys.stderr)
    pos_seqs = get_strings_from_seqs(sequence.readFASTA(pos_seq_file_name, alph))
    neg_seqs = get_strings_from_seqs(sequence.readFASTA(neg_seq_file_name, alph))

    #print >> sys.stderr, "Computing Hamming enrichment..."
    #(dist, log_pvalue, p, P, n, N, aln) = get_best_hamming_alignment(word, pos_seqs, neg_seqs, alph, given_only)

    if refine:
        (best_word, best_log_pvalue) = refine_consensus(word, pos_seqs, neg_seqs, alph, given_only)
    else:
        best_word = word

    print("Computing Hamming alignment...", file=sys.stderr)
    (dist, log_pvalue, p, P, n, N, aln) = get_best_hamming_alignment(best_word, pos_seqs, neg_seqs, alph, given_only)
    pv_string = sprint_logx(log_pvalue, 1, _pv_format)
    nsites = len(aln)
    print("[", p, P, n, N, dist, "]", file=sys.stderr)
    print("Best ZOOPs alignment has %d sites / %d at distance %d with p-value %s" % (nsites, P, dist, pv_string), file=sys.stderr)
    print_meme_header(alph)
    print_meme_motif(best_word, nsites, pv_string, aln, alph)

    # print elapsed time
    end_time = time.time()
    elapsed = end_time - start_time
    print("elapsed time: %.2f seconds" % elapsed, file=sys.stderr)
    print("#elapsed time: %.2f seconds" % elapsed, file=sys.stdout)


if __name__=='__main__': main()
