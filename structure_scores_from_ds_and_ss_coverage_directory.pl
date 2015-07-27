#!/usr/bin/perl
use warnings;
use strict;

unless ($#ARGV == 5) {
	print "arguments: coverage_directory ds_tag ss_tag, output_tag, Nds, Nss\n";
	exit;		
}

my $input_dir = shift or die;
$input_dir =~ s/\/$//; #remove trailing slash
my $ds_tag = shift or die;
$ds_tag =~ s/^\.//; #remove leading . so script can work with either tag or .tag input
my $ss_tag = shift or die;
$ss_tag =~ s/^\.//; #remove leading . so script can work with either tag or .tag input
my $out_tag = shift or die;
$out_tag =~ s/^\.//; #remove leading . so script can work with either tag or .tag input
my $ds_total_count = shift or die;
my $ss_total_count = shift or die;

#define normalization factors
my ($norm_ds, $norm_ss);
if ($ds_total_count > $ss_total_count) {
        $norm_ds = 1.0;
        $norm_ss = $ds_total_count / $ss_total_count;
}
else {
        $norm_ds = $ss_total_count / $ds_total_count;
        $norm_ss = 1.0;
}

#glob for all ds files in input_dir
my @files = <$input_dir/*>; 
my @ds_files = grep(/$ds_tag/, @files);

#open each ds file as well as the corresponding ss file.  Calculate normalized, generalized log ratio and output to new file with output tag 

foreach my $file (@ds_files) {
	my ($ds_file, $ss_file, $out_file) = ($file) x 3;
	$ss_file =~ s/$ds_tag/$ss_tag/;
	$out_file =~ s/$ds_tag/$out_tag/;
	print "calculating score from $ds_file and $ss_file and outputting to $out_file\n";
	open (DS, "<$ds_file") or die "Unable to open file $ds_file for reading: $!";
	open (SS, "<$ss_file") or die "Unable to open file $ss_file for reading: $!";
	open (OUT, ">$out_file") or die "Unable to initialize file $out_file for writing: $!";
	my @ds_cov = <DS>;
	my @ss_cov = <SS>;
	chomp(@ds_cov, @ss_cov);
	my @ds_norm = @ds_cov;
	my @ss_norm = @ss_cov;
	foreach my $pos (@ds_norm) {
		$pos=$pos*$norm_ds
	}
	foreach my $pos (@ss_norm) {
		$pos=$pos*$norm_ss
	}
	my @score;
	unless ($#ds_norm == $#ss_norm) {die "$ds_file and $ss_file files are of unequal length";}
	# calculate structue score while ignoring uninformative positions
	for (my $i=0; $i <= $#ds_norm; $i++) {
		if (($ds_norm[$i] == 0) && ($ss_norm[$i] == 0)) {
			$score[$i] = "NA";
		}
		else {
			$score[$i] = log(sqrt($ds_norm[$i]^2+1)+$ds_norm[$i]) - log(sqrt($ss_norm[$i]+1)+$ss_norm[$i]);
		}
	}
	print OUT join("\n", @score);
	close OUT;
}
