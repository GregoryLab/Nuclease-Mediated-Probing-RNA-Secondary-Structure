#! /usr/bin/perl
use warnings;
use strict;

###parses cDNA fasta.  Assumes gene names are of the following format: 2 letters for species, number of chr followed by "G", and gene ID.transcript ID.  
### For instance "AT1G01010.1" or "OS1G01010.1" for Arabidopsis thaliana and Oryza Sativa, respectively 

unless (scalar @ARGV == 3) {
print "arguments: input_file, output_dir, tag\n";
exit;		
}

my $input_file = shift or die;
my $output_dir = shift or die;
$output_dir =~ s/\/$//; #remove trailing slash if present
my $tag = shift or die;
$tag =~ s/^\.//; #remove leading . so script can work with either tag or .tag input


#create a hash of arrays; keys are transcript ids, arrays are coverage profiles
my $previous_transcript = "NA";
my $sequence;
my $transcript;

#print out results for each transcript.
open (INPUT, "<$input_file") or die "Unable to open file $input_file for reading: $!";
while (my $line = <INPUT>) {
	chomp $line;
	if ($line =~ /(\w\w\wG\d+\.\d+)/) {
		$transcript = $1;
		if ($previous_transcript eq "NA") {
			$previous_transcript = $transcript;
			next;
		}
		my $filename = "$output_dir/$previous_transcript.$tag";
		print "writing sequence for $previous_transcript in $filename\n";
		open (OUTPUT, ">$filename") or die "Unable to initialize file $filename for writing: $!";
		print OUTPUT "$sequence\n";
		$sequence = "";
		close OUTPUT;
		$previous_transcript = $transcript;
	}
	else {
		$sequence = $sequence.$line;
	}
}

#print out results for last transcript
my $filename = "$output_dir/$transcript.$tag";
print "writing sequence for $transcript in $filename\n";
open (OUTPUT, ">$filename") or die "Unable to initialize file $filename for writing: $!";
print OUTPUT $sequence;
close OUTPUT;
