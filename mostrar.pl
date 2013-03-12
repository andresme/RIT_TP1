#!/usr/bin/perl -w

use utf8;

#Arguments
$mod = $ARGV[0];
$file = $ARGV[1];
$pathFile = $ARGV[2];
$begin = $ARGV[3];
$end = $ARGV[0];

#File Handlers
open(FILE, "$file");

#Start
commandSearch();

sub commandSearch{
	if($mod eq 'frec'){
		
	}
	elsif($mod eq 'pesos'){
		
	}
	elsif($mod eq 'vocab'){
		
	}
	elsif($mod eq 'esca'){
		
	}
	else{
		print "Modality not found";
	}
}
