#!/usr/bin/perl
use warnings;
use strict;
use POSIX;
use File::Basename;
my $warnings;

###determine significance thresholds, per base, for a directory of shuffled structure scores.  NOTE: this program relies on numerical sorting and is hence RAM-intensive

unless (scalar @ARGV == 6) {
	print "arguments: sequence_file, coverage_directory, structure_score_tag, constraint_tag, paired_threshold, unpaired_threshold\n";
	exit;		
}

my $sequence_file = shift or die;
my $input_dir = shift or die;
$input_dir =~ s/\/$//; #remove trailing slash
my $score_tag = shift or die;
$score_tag =~ s/^\.//; #remove leading . so script can work with either tag or .tag input
#my $sequence_tag = shift or die;
#$sequence_tag =~ s/^\.//; #remove leading . so script can work with either tag or .tag input
my $constraint_tag = shift or die;
$constraint_tag =~ s/^\.//; #remove leading . so script can work with either tag or .tag input
my $paired_threshold = shift or die;
my $unpaired_threshold = shift or die;

#glob for all structure score files in input_dir
my @files = <$input_dir/*>; 
my @score_files = grep(/$score_tag/, @files);

#open each score file, match to a sequence file, and output a corresponding constraint file
foreach my $file (@score_files) {
	my (@scores, @constraints, $constraints, $sequence);
	my $name = basename($file);
	$name =~ s/\.$score_tag//;
	print "generating constraints for file $file\n";
	#generate constraints
	open (SCORES, "<$file") or die "Unable to open file $file for reading: $!";
	while (my $score = <SCORES>) {
		chomp($score);
		push(@scores, $score);
		if ($score eq "NA") {
			push (@constraints, ".");
		}
		elsif ($score > $paired_threshold) {
			push (@constraints, "|");
		}
		elsif ($score < $unpaired_threshold) {
			push (@constraints, "x");
		}
		else {
			push (@constraints, ".");
		}
	}
	$constraints = join("", @constraints);
	#load sequence
	my $sequence_line = `grep $name $sequence_file`;
	chomp($sequence_line);
	($name, $sequence) = split(/\t/, $sequence_line);
	#output constraint file
	$warnings = "";
	if (length($sequence) != length($constraints)) {$warnings = $warnings."sequence length ".length($sequence)." does not match score length ".length($constraints)." for file $file\n"}
	my $outfile = $file;
	$outfile =~ s/$score_tag/$constraint_tag/;
	open (OUT, ">$outfile") or die "Unable to initialize file $outfile for writing: $!";
	print OUT "$sequence\n$constraints\n";
}

if (length($warnings) > 0) {
	print "###WARNINGS###\n$warnings\n";
}
