#!/usr/bin/perl
use warnings;
use strict;
use POSIX;

###determine significance thresholds, per bin, for a bed file of bin structure scores.  NOTE: this program relies on numerical sorting and is hence RAM-intensive

unless (scalar @ARGV == 2) {
	print "arguments: input.bed, FDR\n";
	exit;		
}

my $input = shift or die;
my $fdr = shift or die;

#open each ds file and add scores to a master array if they do not equal "NA"
my @scores;
open (INPUT, "<$input") or die "Unable to open file $input for reading: $!";
while (my $line = <INPUT>) {
	chomp $line;
	my ($chr, $start, $stop, $id, $score, $strand) = split(/\t/, $line);
	unless ($score eq "NA") {
		push (@scores, $score);
	}
}

#sort scores and pull out signficance thresholds

@scores = sort {$a <=> $b} @scores;
my $length = scalar @scores;
my $upper_index = ceil($length*(1-($fdr/2)));
my $lower_index = floor($length*($fdr/2));
print "paired threshold: $scores[$upper_index]\n";
print "unpaired threshold: $scores[$lower_index]\n";