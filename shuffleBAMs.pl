#!/usr/bin/perl
#shuffled reads between two BAM files with equal probability. NOTE: assumes BAMs were aligned to same genome, as header will be duplicated across shuffled BAMs

use warnings;
use strict;

unless ($#ARGV == 3) {
	print "arguments: bam_input1 bam_input2 shuffled_bam_output1 shuffled_bam_output2\n";
	exit;		
}

my $bam_fn1 = shift or die;
my $bam_fn2 = shift or die;
my $bam_out1 = shift or die;
my $bam_out2 = shift or die;
my $temp_sam1 = $bam_out1;
my $temp_sam2 = $bam_out2;
$temp_sam1 =~ s/bam$/sam/;
$temp_sam2 =~ s/bam$/sam/;


open BAM1,"samtools view -h $bam_fn1 |";
open BAM2,"samtools view -h $bam_fn2 |";
open SAM1, ">$temp_sam1" || die "Unable to intitialize output file $temp_sam1 for writing: $!";
open SAM2, ">$temp_sam2" || die "Unable to intitialize output file $temp_sam2 for writing: $!";	


# randomly mix alignments from sample and control
while (my $line = <BAM1>) {
	if ($line =~ /^@/) {
		print SAM1 "$line"; #print header of BAM1 to shuffled BAM1 and BAM2
		print SAM2 "$line";
		next;
	}
	else {
		if (int(rand(2)) == 1) {
			print SAM1 "$line";
		}
		else {
			print SAM2 "$line";
		}
	}
}

while (my $line = <BAM2>) {
	if ($line =~ /^@/) {
		next;
	}
	else {
		if (int(rand(2)) == 1) {
			print SAM1 "$line";
		}
		else {
			print SAM2 "$line";
		}
	}
}


#convert temp sams to bams
system("samtools view -bS $temp_sam1 > $bam_out1");
system("samtools view -bS $temp_sam2 > $bam_out2");

#remove temp files
unlink($temp_sam1, $temp_sam2);

