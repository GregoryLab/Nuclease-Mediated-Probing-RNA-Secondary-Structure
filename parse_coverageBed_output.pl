#! /usr/bin/perl
use warnings;
use strict;

### parses coverageBed -s -d output (per base coverage) to generate per-transcript files within a specified directory.

##input example
# chr start stop transcript id score strand relative_pos coverage
#chr1    16774864        16777247        AT1G44110.1     #AT1G44110;lots_of_exons        -       1       0

unless ($#ARGV == 1) {
print "usage: <coverageBed -s -d output from STDIN>, output_dir, tag\n";
exit;		
}

my $output_dir = shift or die;
$output_dir =~ s/\/$//; #remove trailing slash if present
my $tag = shift or die;
$tag =~ s/^\.//; #remove leading . so script can work with either tag or .tag input


#create a hash of arrays; keys are transcript ids, arrays are coverage profiles
my %coverage;
my $current_transcript = "NA";
my @coverage;
my ($chr, $start, $stop, $transcript, $id, $score, $strand, $relative_pos, $coverage);

#print out results for each transcript.  Will miss last transcript.
while (my $line = <STDIN>) {
	chomp $line;
	($chr, $start, $stop, $transcript, $score, $strand, $relative_pos, $coverage) = split(/\t/, $line);
	if ($transcript ne $current_transcript && $relative_pos==1) {
		unless ($current_transcript eq "NA") {
			my $filename = "$output_dir/$current_transcript.$tag";
			print "writing coverage for $current_transcript in $filename\n";
			open (OUTPUT, ">$filename") or die "Unable to initialize file $filename for writing: $!";
			my $output = join("\n", @coverage);
			print OUTPUT $output;
			close OUTPUT;
		}
		$current_transcript = $transcript;
		@coverage = ();
		push (@coverage, $coverage);
	}
	else {
		push (@coverage, $coverage)
	}
}

#print out results for last transcript
my $filename = "$output_dir/$current_transcript.$tag";
print "writing coverage for $current_transcript in $filename\n";
open (OUTPUT, ">$filename") or die "Unable to initialize file $filename for writing: $!";
my $output = join("\n", @coverage);
print OUTPUT $output;
close OUTPUT;
