#!usr/bin/perl

use utf8;

#Arguments
$stopwords = @ARGV[0];
$fileDir = @ARGV[1];
$filePattern = @ARGV[2];
$prefix = @ARGV[3];

#Files Handlers
open(STOPWORDS, "./$stopwords") or die "$!";
open(FREQFILE, ">>$prefix"."_FC") or die "$!";
open(VOCFILE, ">>$prefix"."_VO") or die "$!";
open(WEIGHTFILE, ">>$prefix"."_PO") or die "$!";

#Global variables
%Vocabulary = ();
@stopwords = ();

#Start
main();

sub main{
	#Setup stopwords from file
	@stopwords = <STOPWORDS>;
	chop(@stopwords);
	opendir(DIR, "./$fileDir") or die "$!";
	#search all subfolders
	@directories = grep /\w.*/, readdir DIR;
	foreach $folder (sort @directories) {
		opendir(DIR, "./$fileDir/$folder") or die "$!";
		#search for all files with pattern in subfolder
		@files = grep /$filePattern/, readdir DIR;
		foreach $file (sort @files){
			freqFile("$fileDir/$folder/$file");
		}
	}
	close(FREQFILE);
	open(FREQFILE, "$prefix"."_FC") or die "$!";
	vocabularyFile();
	close(VOCFILE);
	open(VOCFILE, "$prefix"."_VO") or die "$!";
	weightFile();
	
}

#Generate the frequency file
#Format:
#relative path|total terms|most repetitions|(term,frequency)
sub freqFile{
	$file = $_[0];
	$number = 0;
	$lastword = "";
	@file = ();
	@terms = ();
	%fileVocabulary = ();
	
	open(FILE, "./$file") or die "$!";
	
	@file = <FILE>;
	chop(@file);
	
	print "Generating index for file: $file...\n";
	
	foreach $term (@file){
		#Clean accents from file
		$term =~ s/[Áá]/a/g;
		$term =~ s/[Éé]/e/g;
		$term =~ s/[Íí]/i/g;
		$term =~ s/[Óó]/o/g;
		$term =~ s/[Úú]/u/g;
		
		#remove numbers (not words)
		$term =~ s/\b[0-9]+\b//g;
		
		#lower case everything
		$term = lc($term);
		
		#removes stopwords
		foreach $stopword (@stopwords){
			$term =~ s/\b$stopword\b//g;
		}
		
		#get the words (patter: [a-z0-9_]).
		$_ = $term;
		@words = m/(\b[a-z0-9_]+\b)/g;
		foreach $term (@words){
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
	
	#new line for next document
	print FREQFILE "\n"
	
}

#Generate the weight file
#Format:
#relative path|total terms|Norm of vector|(term,weight)
sub weightFile{
	@freqs = <FREQFILE>;
	
	
	#Total documents
	$nDocuments = @freqs;
	
	foreach $freqLine (@freqs){
		#weight hash:
		%weights = ();
		#Norm of the vector 
		$NormVect = 0;
		#Get the filename and total terms.
		$_ = $freqLine;
		m/(^.+\.txt)\|([0-9]+)/g;
		$file = $1;
		$maxTerms = $2;
		print "Generating weight for file: $file\n";
		print WEIGHTFILE "$file|$maxTerms|";
		
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
			$weights{$term} = ((1+log2($freq))*log2($nDocuments/$Vocabulary{$term}));
		}
		
		#Calculates the norm of the vector
		#square root of the sum of the weights
		foreach $term (sort keys %weights){
			$NormVect += pow2($weights{$term});
		}
		
		#round to 2 decimals
		$rounded = sprintf("%.2f", sqrt($NormVect));
		print WEIGHTFILE $rounded."|";
		
		#prints to file pair (term, weight)
		foreach $term (sort keys %weights){
			#round to 2 decimals
			$rounded = sprintf("%.2f", $weights{$term});
			print WEIGHTFILE "(".$term.",".$rounded.")";
		}
		
		print WEIGHTFILE "\n";
	}
	
}

#Generate the vocabulary file
#Format:
#Term,number of documents that contain that term.
sub vocabularyFile{
	print "Writing vocabulary file: $prefix"."_VO\n";
	foreach $key (sort keys %Vocabulary){
		print VOCFILE "$key,$Vocabulary{$key}\n";
	}
}

#power of n^2
sub pow2{
	$number = $_[0];
	return $number*$number;
}

#Log base two
sub log2 {
	$number = $_[0];
	return log($number)/log(2);
}
