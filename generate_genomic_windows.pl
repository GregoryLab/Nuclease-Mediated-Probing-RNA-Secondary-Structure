#! /usr/bin/perl
use warnings;
use strict;

###create genomic windows of equal length on both plus and minus strand
unless (scalar @ARGV == 2) {
print "usage: perl generate_genomic_windows.pl chromosome_lengths.txt window_size > output.bed\n";
exit;		
}

my $chromosome_lengths_file = shift or die;
my $window_size = shift or die;
#check that window_size is integer 
unless ($window_size =~ m/^\d+$/) {die "Window size $window_size must be an integer";}

#run bedtools makewindows and output temp file
my $tempfile = "temp.".int(rand(100000));

system("bedtools makewindows -g $chromosome_lengths_file -w $window_size > $tempfile");

open (TEMP, "<$tempfile") or die "Unable to open file $tempfile for reading: $!";
my $i=0;
while (my $line = <TEMP>) {
	$i++;
	chomp $line;
	$line = $line."\tbin_$i\t.\t+\n";
	print STDOUT "$line";
}

open (TEMP, "<$tempfile") or die "Unable to open file $tempfile for reading: $!";
while (my $line = <TEMP>) {
	$i++;
	chomp $line;
	$line = $line."\tbin_$i\t.\t-\n";
	print STDOUT "$line";
}

unlink $tempfile;
