#!usr/bin/perl

use utf8;

open(STOPWORDS, "./stopwords.txt") or die "$!";
@stopwords = <STOPWORDS>;
chop(@stopwords);
main();

sub main{
	opendir(DIR, "./man.es") or die "$!";
	@directories = grep /\w.*/, readdir DIR;
	foreach $folder (sort @directories) {
		opendir(DIR, "./man.es/$folder") or die "$!";
		@files = grep /.*\.txt/, readdir DIR;
		foreach $file (sort @files){
			print "$file\n";
			analyzeFile("man.es/$folder/$file");
		}
	}
}


sub analyzeFile{
	$file = $_[0];
	freqFile($file);
	weightFile($file);
	vocabularyFile($file);
}


sub freqFile{
	$file = $_[0];
	$number = 0;
	$lastword = "";
	@file = ();
	@terms = ();
	%fileVocabulary = ();
	
	open(FREQFILE, ">>freqFile.txt") or die "$!";
	open(FILE, "./$file") or die "$!";

	@file = <FILE>;
	chop(@file);
	
	print FREQFILE @terms;
	
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
		print FREQFILE "($word, $cant) ";
	}
	
	
	print FREQFILE "\n"
	
}

sub weightFile{
	
}

sub vocabularyFile{
	
}
