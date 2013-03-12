#!/usr/bin/perl -w

use utf8;

#Arguments
$mod = $ARGV[0];
$begin = $ARGV[1];
$end = $ARGV[2];
$prefix = $ARGV[3];
$prefixQuery = $ARGV[4];
$rankFile = $ARGV[5];
$htmlFile = $ARGV[6];
$query = $ARGV[7];

#File Handlers; File creation
open(RANK, ">>$prefixQuery_"."$rankFile");
open(HTML, ">>$prefixQuery_"."$htmlFile");
open(FC, "$prefix"."_FC");
open(VO, "$prefix"."_VO");
open(PO, "$prefix"."_PO");

#Start
commandSearch();

sub commandSearch{
	if($mod eq 'vec'){
		searchVect();
	}

	elsif($mod eq 'min'){
		searchMin();
	}
	else{
		print "Modality not found!";
	}
}



sub searchVect{
	print "Searching using vectorial model\n";
}


sub searchMin{
	print "Searching using minimum model\n";
}
