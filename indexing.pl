#!usr/bin/perl


open(STOPWORDS, "./stopwords.txt") or die "$!";
@stopwords = <STOPWORDS>;
chop(@stopwords);


sub main{
	opendir(DIR, "./man.es") or die "$!";
	@directories = grep /.*/, readdir DIR;
	foreach $folder (sort @directories) {
		opendir(DIR, "./man.es/$folder") or die "$!";
		@files = grep /.*\.txt/, readdir DIR;
		foreach $file (sort @files){
			#print "$file\n";
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
	@terms = ();
	%fileVocabulary = ();
	
	open(FREQFILE, ">>freqFile.txt") or die "$!";
	open(FILE, "./$file") or die "$!";

	@terms = <FILE>;
	chop(@terms);
	
	foreach $stopword (@stopwords){
		foreach $term (@terms){
			$terms =~ s/$stopword//gi;
		}
	}
	
	
	$number = @terms;
	print FREQFILE "$file | $number |";
	
	
	print FREQFILE "\n"
	#%TermFreq = ();
	
}

sub weightFile{
	
}

sub vocabularyFile{
	
}
