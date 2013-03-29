#!/usr/bin/perl -w

use utf8;
use POSIX;
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
open(RANK, ">>$prefixQuery"."_$rankFile") or die $!;
open(HTML, ">>$prefixQuery"."_$htmlFile.html") or die $!;
open(FC, "$prefix"."_FC") or die $!;
open(VO, "$prefix"."_VO") or die $!;
open(PO, "$prefix"."_PO") or die $!;

#Global Variables
%Vocabulary = ();
%Similarity = ();
@vocabularyTemp = <VO>;
@weightFile = <PO>;
@freqFile = <FC>;
@queryTerms = [];
$nDocuments = @weightFile;

#Start
commandSearch();


sub commandSearch{
	if($mod eq 'vec'){
		loadVocabulary();
		getTerms();
		searchVect();
		printRanking();
	}

	elsif($mod eq 'min'){
		searchMin();
	}
	else{
		print "Modality not found!";
	}
}

#load Vocabulary to hash
sub loadVocabulary{
	for $term (@vocabularyTemp){
		$_ = $term;
		m/([a-z0-9_]+),([0-9]+)/;
		$Vocabulary{$1} = $2;
	}
}

#get terms from query
sub getTerms{
	$_ = $query;
	@queryTerms = m/\b[a-z0-9_]+\b/g;
}

#Prints the result ranking
sub printRanking{
	$pos = 0;
	foreach $sim (sort {$Similarity{$b} cmp $Similarity{$a}} keys %Similarity){
		last if($pos++ >= $end);
		if($pos >= $begin){
			#File Information
			$creation = POSIX::strftime("%d/%m/%y", localtime((stat "./$sim")[9]));
			$fileSize = (stat "./$sim")[7];
			open(FILE, "./$sim");
			@file = <FILE>;
			$lines = @file;
			
			#Print to file
			print HTML "<li>$pos: <a href=\"$sim\">$sim</a>\n";
			print HTML "<ul>Similaridad: $Similarity{$sim}</ul>\n";
			print HTML "<ul>Fecha Creación: $creation</ul>";
			print HTML "<ul>Tamaño: $fileSize bytes</ul>";
			print HTML "<ul>Lineas: $lines</ul>";
			print HTML "<ul>Primeros 200 caracteres:\n</ul>";
			print HTML "<span>abcd...</span>";
			print HTML "<\li>\n";
		}
	}
}

sub searchVect{
	print "Searching using vectorial model...\n";
	$QueryNormVect = 0;
	%queryTermFreq = ();
	%weights = ();
	
	#Calculates weights for query terms
	for $term (sort @queryTerms){
		$queryTermFreq{$term}++;
	}
	
	for $term (sort keys %queryTermFreq){
		$freq = $queryTermFreq{$term};
		if(exists $Vocabulary{$term}){
			$weights{$term} = ((1+log2($freq))*log2($nDocuments/$Vocabulary{$term}));
		}
	}
	
	foreach $term (sort keys %weights){
		$QueryNormVect += ($weights{$term}*$weights{$term});
	}		
	
	#round to 2 decimals
	$rounded = sprintf("%.2f", sqrt($QueryNormVect));
	
	foreach $file (@weightFile){
		#resets acum
		$acummulator = 0;
		#get filepath
		$_ = $file;
		m/(.+)\|[0-9]+\|[0-9.]+/;
		$path = $1;
		#get norm of file
		$_ = $file;
		m/.+\|[0-9]+\|([0-9.]+)/;
		$Norm = $1;
		foreach $term (sort keys %weights){
			#get weight from PO file
			$_ = $file;
			if(m/$term,([0-9.]+)/){
				$weight = $1;
				$acummulator += $weight * $weights{$term};
			}
			else{
				$weight = 0;
			}
		}
		if($Norm*$rounded != 0){
			$Similarity{$path} = $acummulator/($Norm*$rounded);
		}
		else{
			$Similarity{$path} = 0;
		}
	}
}


sub searchMin{
	print "Searching using minimum model\n";
}
