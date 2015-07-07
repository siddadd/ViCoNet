#!/usr/bin/perl
use strict;

open(FP, $ARGV[0]) or die "$ARGV[0] open error";

my $aisle = "";
my $tag = "";
my @HMAX;
my @ESVM;
my $groundtruth;

while(my $line = <FP>){
    chomp($line);
    if($line=~/<Aisle>(.*)<\/Aisle>/){
	$aisle = $1;	
    }
    elsif($line=~/<Object\ +Tag=\"(.*)\"/){
	$tag = $1;
	($aisle ne "") or "<object> should be exist before <aisle>";
    }	
	elsif($line=~/<Truth\ +Index=\"(.*)\"/) {
	$groundtruth = $1;	
	}
    elsif($line=~/RLS.*Class="([^"]+)".*Response="([^"]+)"/){
#	printf("$aisle $tag hmax $line: $1 $2\n");
	push(@HMAX, "$1, $2\n");
    }
    elsif($line=~/ESVM.*Class="([^"]+)".*Response="([^"]+)"/){
#	printf("$aisle $tag esgm $line: $1 $2\n");
	push(@ESVM, "$1, $2\n");
    }
    elsif($line=~/<\/Object>/){
	my $fname_hmax = "data/${aisle}_hmax_${tag}.txt";
	my $fname_esvm = "data/${aisle}_esvm_${tag}.txt";
	my $fname_gt = "data/${aisle}_gt_${tag}.txt";
	
	open(HMAX_FP, "> $fname_hmax") or die "$fname_hmax open error";
	open(ESVM_FP, "> $fname_esvm") or die "$fname_esvm open error";	
	open(GT_FP, "> $fname_gt") or die "$fname_gt open error";	
	
	foreach my $l ( @HMAX) {
	    printf(HMAX_FP $l);
	}

	foreach my $l ( @ESVM) {
	    printf(ESVM_FP $l);
	}
	
	printf(GT_FP $groundtruth);
	
	close(HMAX_FP);
	close(ESVM_FP);
	close(GT_FP);
	
	@HMAX = ();
	@ESVM = ();
	$groundtruth = -1;
	
	printf("$fname_hmax  & $fname_esvm  & $fname_gt dumped\n");
	$tag = "";
    }
    elsif($line=~/<\/Scene>/){
	$aisle = "";
    }
}

close(FP);
