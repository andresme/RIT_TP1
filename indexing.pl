#!usr/bin/perl

use utf8;

#Arguments
$stopwords = @ARGV[0];
$fileDir = @ARGV[1];
$filePattern = @ARGV[2];
$prefix = @ARGV[3];

#Files
open(FREQFILE, ">>$prefix"."_FC") or die "$!";
open(STOPWORDS, "./$stopwords") or die "$!";
open(VOCFILE, ">>$prefix"."_VO") or die "$!";

#Global variables
%Vocabulary = ();

#Setup stopwords from file

@stopwords = <STOPWORDS>;
chop(@stopwords);

#Start
main();

sub main{
	opendir(DIR, "./$fileDir") or die "$!";
	@directories = grep /\w.*/, readdir DIR;
	foreach $folder (sort @directories) {
		opendir(DIR, "./$fileDir/$folder") or die "$!";
		@files = grep /$filePattern/, readdir DIR;
		foreach $file (sort @files){
			print "generating index for file: $file...\n";
			analyzeFile("$fileDir/$folder/$file");
		}
	}
	vocabularyFile();
}


sub analyzeFile{
	$file = $_[0];
	freqFile($file);
	weightFile($file);
}


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
	
	foreach $term (@file){
		#Quita las tildes!!
		$term =~ s/[Áá]/a/g;
		$term =~ s/[Éé]/e/g;
		$term =~ s/[Íí]/i/g;
		$term =~ s/[Óó]/o/g;
		$term =~ s/[Úú]/u/g;
		
		#Quita los numeros!!
		$term =~ s/\b[0-9]+\b//g;
		
		#Pone todo en minuscula!
		$term = lc($term);
		
		#Quita los stopwords!!
		foreach $stopword (@stopwords){
			$term =~ s/\b$stopword\b//g;
		}
		
		#Saca las palabras [a-z0-9_]!!
		$_ = $term;
		@words = m/(\b\w+\b)/g;
		foreach $term (@words){
			$fileVocabulary{$term}++;
		}
		
	}
	@keys = keys %fileVocabulary;
	$number = @keys;
	
	print FREQFILE "$file | $number | ";
	$number = 0;
	
	foreach $key (sort keys %fileVocabulary){
		$numberTerm = $fileVocabulary{$key};
		if($number < $numberTerm){
			$number = $numberTerm;
		}
	}
	
	print FREQFILE "$number | ";
	
	foreach $key (sort keys %fileVocabulary){
		$word = $key;
		$cant = $fileVocabulary{$key};
		$Vocabulary{$key}++;
		print FREQFILE "($word, $cant) ";
	}
	
	
	print FREQFILE "\n"
	
}

sub weightFile{
	
}

sub vocabularyFile{
	print "Writing vocabulary file: $prefix"."_VO\n";
	foreach $key (sort keys %Vocabulary){
		print VOCFILE "$key , $Vocabulary{$key}\n";
	}
}
