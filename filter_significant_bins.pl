#!/usr/bin/perl
use warnings;
use strict;
use POSIX;

###Filters out significantly high/low structure bins from a bed file of bin structure scores.

unless (scalar @ARGV == 5) {
	print "arguments: structure_scores.bed, paired_threshold, unpaired_threshold, structure_peak_output, structure_valley_output\n";
	exit;		
}

my $input = shift or die;
my $upper = shift or die;
my $lower = shift or die;
my $peaks = shift or die;
my $valleys = shift or die;


#open structure scores bed and print out to structure peaks/valleys if magnitude of theshold exceeded
open (INPUT, "<$input") or die "Unable to open file $input for reading: $!";
open (PEAKS, ">$peaks") or die "Unable to initialize file $peaks for writing: $!";
open (VALLEYS, ">$valleys") or die "Unable to initialize file $valleys for writing: $!";

while (my $line = <INPUT>) {
	chomp $line;
	my ($chr, $start, $stop, $id, $score, $strand) = split(/\t/, $line);
	next if ($score eq "NA");
	if ($score >= $upper) {
		print PEAKS "$line\n";
	}
	elsif ($score <= $lower) {
		print VALLEYS "$line\n";
	}
	else{}
}

close PEAKS;
close VALLEYS;