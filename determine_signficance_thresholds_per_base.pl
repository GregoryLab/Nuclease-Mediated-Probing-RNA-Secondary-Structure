#!/usr/bin/perl
use warnings;
use strict;
use POSIX;

###determine significance thresholds, per base, for a directory of shuffled structure scores.  NOTE: this program relies on numerical sorting and is hence RAM-intensive

unless (scalar @ARGV == 3) {
	print "arguments: coverage_directory, structure_score_tag, FDR\n";
	exit;		
}

my $input_dir = shift or die;
$input_dir =~ s/\/$//; #remove trailing slash
my $tag = shift or die;
$tag =~ s/^\.//; #remove leading . so script can work with either tag or .tag input
my $fdr = shift or die;


#glob for all structure score files in input_dir
my @files = <$input_dir/*>; 
my @score_files = grep(/$tag/, @files);

#open each ds file and add scores to a master array if they do not equal "NA"
my @scores;
foreach my $file (@score_files) {
	open (SCORES, "<$file") or die "Unable to open file $file for reading: $!";
	while (my $score = <SCORES>) {
		chomp $score;
		unless ($score eq "NA") {
			push (@scores, $score);
		}
	}
}

#sort scores and pull out signficance thresholds

@scores = sort {$a <=> $b} @scores;
my $length = scalar @scores;
my $upper_index = ceil($length*(1-($fdr/2)));
my $lower_index = floor($length*($fdr/2));
print "paired threshold: $scores[$upper_index]\n";
print "unpaired threshold: $scores[$lower_index]\n";