#!/usr/bin/perl -w

#########################################################
#File: utils.pl                                         #
#                                                       #
#Description: Utilities used by other tools in perl     #
#                                                       #
#Andres Morales Esquivel - 201016752                    #
#RIT I-2013                                             #
#########################################################



#Log base two
sub log2 {
    $number = $_[0];
    return log($number)/log(2);
}

sub cleanTerm{
	$term = $_[0];
	#Clean accents
	$term =~ s/[Áá]/a/g;
	$term =~ s/[Éé]/e/g;
	$term =~ s/[Íí]/i/g;
	$term =~ s/[Óó]/o/g;
	$term =~ s/[Úú]/u/g;
	#lower case everything
	$term = lc($term);
	return $term;
}

sub cleanStopWords{
	$term = $_[0];
	$stopwordsFile = $_[1];
	open(STOPWORDS, "./$stopwords") or die "$!";
	#Setup stopwords from file
	@stopwords = <STOPWORDS>;
	chop(@stopwords);
	
	#removes stopwords
	foreach $stopword (@stopwords){
		$term =~ s/\b$stopword\b//g;
	}
	return $term;
	
}

sub cleanNumbers{
	$term = $_[0];
	#remove numbers (not words)
	$term =~ s/\b[0-9]+\b//g;
	return $term;
}

#Opens browser
sub open_default_browser {
    my $url = shift;
    my $platform = $^O;
    my $cmd;
    if    ($platform eq 'darwin')  { $cmd = "open \"$url\"";          } # Mac OS X
    elsif ($platform eq 'linux')   { $cmd = "x-www-browser \"$url\""; } # Linux
    elsif ($platform eq 'MSWin32') { $cmd = "start $url";             } # Win95..Win7
    if (defined $cmd) {
        system($cmd);
    } else {
        die "Can't locate default browser";
    }
}

1;
