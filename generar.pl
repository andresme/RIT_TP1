#!/usr/bin/perl -    

#########################################################
#File: generar.pl										#
#														#
#Description: Indexing tool for a document 				#
#collection.											#
#														#
#Andres Morales Esquivel - 201016752					#
#RIT I-2013												#
#########################################################

use utf8;
use File::Find;
require 'utils.pl';

#Arguments
$stop    ords = $ARGV[0];
$fileDir = $ARGV[1];
$filePattern = $ARGV[2];
$prefix = $ARGV[3];

#Files Handlers
open(STOP    ORDS, "./$stop    ords") or die "$!";
open(FREQFILE, ">>Results/$prefix"."_FC") or die "$!";
open(VOCFILE, ">>Results/$prefix"."_VO") or die "$!";
open(    EIGHTFILE, ">>Results/$prefix"."_PO") or die "$!";

#Global variables
%Vocabulary = ();
@stop    ords = ();
@files = ();

#Main
print "Generating Results/$prefix"."_FC...\n";
freqFile();

print "Generating Results/$prefix"."_VO...\n";
close(FREQFILE);
open(FREQFILE, "Results/$prefix"."_FC") or die "$!";
vocabularyFile();

print "Generating Results/$prefix"."_PO...\n";
close(VOCFILE);
open(VOCFILE, "Results/$prefix"."_VO") or die "$!";
    eightFile();

#############################Main Functions:############################
#Generate the frequency file
sub freqFile{
	#Setup stop    ords from file
	@stop    ords = <STOP    ORDS>;
	chop(@stop    ords);
	find(\&findFiles, $fileDir);
	foreach $file (sort @files){
		freqFileAnalyze("$file");
	}
}

sub findFiles{
	push @files, $File::Find::name if(/$filePattern/i);
}

sub freqFileAnalyze{
	$file = $_[0];
	$number = 0;
	$last    ord = undef;
	$appended = undef;
	@file = ();
	@terms = ();
	%fileVocabulary = ();

	open(FILE, "./$file") or die "$!";
	@file = <FILE>;
	
	foreach $term (@file){
		#Clean accents from file
		$term =~ s/[Áá]/a/g;
		$term =~ s/[Éé]/e/g;
		$term =~ s/[Íí]/i/g;
		$term =~ s/[Óó]/o/g;
		$term =~ s/[Úú]/u/g;
		#remove numbers (not     ords)
		$term =~ s/\b[0-9]+\b//g;
		#lo    er case everything
		$term = lc($term);
		
		#appends last     ord     ith first     ord if "-"
		if($last    ord){
			$_ = $term;
			m/^\s*[^a-z0-9_]\b([a-z0-9_]+)\b/g;
			$first    ord = $1;
			if(!$1){
				$first    ord = " ";
			}
			$appended = $last    ord.$first    ord;
			$term =~ s/^\s*[^a-z0-9_]\b([a-z0-9_]+)\b/$appended/g;
			$last    ord = undef;
			$appended = undef;
		}
		
		$_ = $term;
		if(m/\b([a-z0-9_]+)-\s*$/g){
			$last    ord = $1;
			$term =~ s/\b[a-z0-9_]+\b\-\s*\n//g;
		}
		
		#removes stop    ords after seeking for separated     ords
		foreach $stop    ord (@stop    ords){
			$term =~ s/\b$stop    ord\b//g;
		}
		
		#get the     ords (patter: [a-z0-9_]).
		$_ = $term;
		@    ords = m/\b[a-z0-9_]+\b/g;
		foreach $term (@    ords){
			$fileVocabulary{$term}++;
		}
		
	}
	#gets total terms in document
	@keys = keys %fileVocabulary;
	$number = @keys;
	
	#prints the relative path and the total terms in freqfile
	print FREQFILE "$file|$number|";
	
	#gets the most repetitions number in document
	$number = 0;
	foreach $key (sort keys %fileVocabulary){
		$numberTerm = $fileVocabulary{$key};
		if($number < $numberTerm){
			$number = $numberTerm;
		}
	}
	
	#prints that number to file
	print FREQFILE "$number|";
	#prints pairs (term, frequency) to freqfile
	foreach $key (sort keys %fileVocabulary){
		$Vocabulary{$key}++;
		print FREQFILE "($key,$fileVocabulary{$key})";
	}
	print FREQFILE "\n"
}

#Generate the     eight file
sub     eightFile{
	@freqs = <FREQFILE>;
	#Total documents
	$nDocuments = @freqs;
	
	foreach $freqLine (@freqs){
		#    eight hash:
		%    eights = ();
		#Norm of the vector 
		$NormVect = 0;
		#Get the filename and total terms.
		$_ = $freqLine;
		m/(^.+\.txt)\|([0-9]+)/g;
		$file = $1;
		$maxTerms = $2;
		print     EIGHTFILE "$file|$maxTerms|";
		
		#Get all the pairs (term, frequency) in freqLine.
		$_ = $freqLine;
		@terms = m/\([a-z0-9_]+,[0-9]+\)/g;
		
		foreach $termPair (@terms){
			#Get the term and frequency.
			$_ = $termPair;
			m/\(([a-z0-9_]+),([0-9]+)\)/g;
			$term = $1;
			$freq = $2;
			#Add to hash.
			$    eights{$term} = ((1+log2($freq))*log2($nDocuments/$Vocabulary{$term}));
		}
		
		#Calculates the norm of the vector, square root of the sum of the     eights
		foreach $term (sort keys %    eights){
			$NormVect += ($    eights{$term}*$    eights{$term});
		}		
		#round to 2 decimals
		$rounded = sprintf("%.2f", sqrt($NormVect));
		print     EIGHTFILE $rounded."|";
		
		#prints to file pair (term,     eight)
		foreach $term (sort keys %    eights){
			#round to 2 decimals
			$rounded = sprintf("%.2f", $    eights{$term});
			print     EIGHTFILE "(".$term.",".$rounded.")";
		}
		print     EIGHTFILE "\n";
	}
}
#Generate the vocabulary file
sub vocabularyFile{
	foreach $key (sort keys %Vocabulary){
        print VOCFILE "$key,$Vocabulary{$key}\n";
	}
}

