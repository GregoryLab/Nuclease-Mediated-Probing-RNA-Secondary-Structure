#!/usr/bin/perl
use warnings;
use strict;

my $totalcov=0;
my ($chr, $start, $stop, $id, $score, $strand, $relpos, $cov);
my ($curchr, $curstart, $curstop, $curid, $curscore, $curstrand, $currelpos, $curcov); #also keep the previous bed entry in buffer so can print when new id is reached
$curid = "NA";

#print out results for each entry.  Will miss final entry.
while (my $line = <STDIN>) {
	chomp $line;
	($chr, $start, $stop, $id, $score, $strand, $relpos, $cov) = split(/\t/, $line);
	unless ($curid eq $id) {
		#print out results when new id hit.  Ignore first case where current id is NA
		unless ($curid eq "NA") {
			print STDOUT "$curchr\t$curstart\t$curstop\t$curid\t$totalcov\t$curstrand\n";
		}
		$totalcov = 0;
		($curchr, $curstart, $curstop, $curid, $curscore, $curstrand, $currelpos, $curcov) = ($chr, $start, $stop, $id, $score, $strand, $relpos, $cov)
	}
	$totalcov = $totalcov + $cov;
}


#print out final entry .
print STDOUT "$curchr\t$curstart\t$curstop\t$curid\t$totalcov\t$curstrand\n";
