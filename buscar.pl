#!/usr/bin/perl -w

use utf8;
require 'utils.pl';

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
open(RANK, ">>$prefixQuery"."_$rankFile");
open(HTML, ">>$prefixQuery"."_$htmlFile");
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
	print "Searching using vectorial model...\n";
	%Vocabulary = ();
	%Similarity = ();
	@vocabularyTemp = <VO>;
	@weightFile = <PO>;
	$nDocuments = @weightFile;
	$QueryNormVect = 0;
	%queryTermFreq = ();
	%weights = ();
	
	#get vocabulary to hash
	for $term (@vocabularyTemp){
		$_ = $term;
		m/([a-z0-9_]+),([0-9]+)/;
		$Vocabulary{$1} = $2;
	}
	
	#get terms from query
	$_ = $query;
	@terms = m/\b[a-z0-9_]+\b/g;
	
	#Calculates weights for query terms
	for $term (sort @terms){
		$queryTermFreq{$term}++;
	}
	
	for $term (sort keys %queryTermFreq){
		$freq = $queryTermFreq{$term};
		$weights{$term} = ((1+log2($freq))*log2($nDocuments/$Vocabulary{$term}));
	}
	
	foreach $term (sort keys %weights){
		$QueryNormVect += ($weights{$term}*$weights{$term});
	}		
	#round to 2 decimals
	$rounded = sprintf("%.2f", sqrt($QueryNormVect));
	
	foreach $file (@weightFile){
		#get filepath
		$_ = $file;
		m/(.+)\|[0-9]+\|[0-9.]+/;
		$path = $1;
		#get norm of file
		$_ = $file;
		m/.+\|[0-9]+\|([0-9.]+)/;
		$Norm = $1;
		#resets acum
		$acummulator = 0;
		foreach $term (sort keys %weights){
			#get weight from PO file
			$_ = $file;
			if(m/$term,([0-9.]+)/){
				$weight = $1;
				#sum wij*wiq
				$acummulator += $weight * $weights{$term};
			}
			
			#print $term.":".$weight.",".$weights{$term}."\n";
		}
		if($Norm*$rounded != 0){
			$Similarity{$path} = $acummulator/($Norm*$rounded);
		}
	}
	
	foreach $sim (sort {$Similarity{$b} cmp $Similarity{$a}} keys %Similarity){
			print RANK $sim." ".$Similarity{$sim}."\n";
		}
	
}


sub searchMin{
	print "Searching using minimum model\n";
}
