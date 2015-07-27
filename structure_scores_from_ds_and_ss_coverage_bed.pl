#!/usr/bin/perl
use warnings;
use strict;

unless ($#ARGV == 2) {
	print "arguments: ds_bed ss_bed output_bed\n";
	exit;		
}

my $ds_bed = shift or die;
my $ss_bed = shift or die;
my $output_bed = shift or die;

open (DS, "<$ds_bed") or die "Unable to open file $ds_bed for reading: $!";
open (SS, "<$ss_bed") or die "Unable to open file $ss_bed for reading: $!";


my ($chr, $start, $stop, $id, $score, $strand, $norm_ds, $norm_ss);
my (%ds_cov, %ss_cov, %chr, %start, %stop, %id, %strand, %structure_score);

while (my $line = <DS>) {
	chomp $line;
	($chr, $start, $stop, $id, $score, $strand) = split(/\t/, $line);
	$chr{$id} = $chr;
	$start{$id} = $start;
	$stop{$id} = $stop;
	$strand{$id} = $strand;
	$ds_cov{$id} = $score;
}

while (my $line = <SS>) {
	chomp $line;
	($chr, $start, $stop, $id, $score, $strand) = split(/\t/, $line);
	if (($chr{$id} ne $chr) || ($start{$id} != $start) || ($stop{$id} != $stop) || ($strand{$id} ne $strand)) {
		die "coordinates for id $id do not match across ds and ss beds";
	}
	$ss_cov{$id} = $score;
}

use List::Util 'sum';
my $ds_total_count = sum values %ds_cov;
my $ss_total_count = sum values %ss_cov;

if ($ds_total_count > $ss_total_count) {
        $norm_ds = 1.0;
        $norm_ss = $ds_total_count / $ss_total_count;
}
else {
        $norm_ds = $ss_total_count / $ds_total_count;
        $norm_ss = 1.0;
}

open (OUTPUT, ">$output_bed") or die "Unable to initialize file $output_bed for writing: $!";

foreach my $id (keys %ds_cov) {
	my $ds_norm = $ds_cov{$id}*$norm_ds;
	my $ss_norm = $ss_cov{$id}*$norm_ss;
	#ignore uninformative positions
	if (($ds_norm == 0) && ($ss_norm == 0)) {
		$structure_score{$id} = "NA";
	}
	else {
		$structure_score{$id} = log(sqrt($ds_norm^2+1)+$ds_norm) - log(sqrt($ss_norm+1)+$ss_norm);
	}
	print OUTPUT "$chr{$id}\t$start{$id}\t$stop{$id}\t$id\t$structure_score{$id}\t$strand{$id}\n";
}

close OUTPUT;

#sort output bed file since hash order is usually scrambled
my $tempfile = "temp.".int(rand(100000));
system("bedtools sort -i $output_bed > $tempfile && mv $tempfile $output_bed");


