#!/usr/bin/perl -w

#########################################################
#File: buscar.pl                                        #
#                                                       #
#Description: Searching tool for documents              #
#in this collection.                                    #
#                                                       #
#Andres Morales Esquivel - 201016752                    #
#Sebastian Ramirez Rodriguez - 201052816				#
#RIT I-2013                                             #
#########################################################

use utf8;
use POSIX;
use File::Spec;
require 'utils.pl';

#Arguments
$stopwords = $ARGV[0];
$mod = $ARGV[1];
$begin = $ARGV[2];
$end = $ARGV[3];
$prefix = $ARGV[4];
$prefixQuery = $ARGV[5];
$rankFile = $ARGV[6];
$htmlFile = $ARGV[7];
$query = $ARGV[8];



#File Handlers; File creation
open(RANK, ">>Results/$prefixQuery"."_$rankFile") or die $!;
open(HTML, ">>Results/$prefixQuery"."_$htmlFile.html") or die $!;
open(FC, "Results/$prefix"."_FC") or die $!;
open(VO, "Results/$prefix"."_VO") or die $!;
open(PO, "Results/$prefix"."_PO") or die $!;

#Global Variables
%Vocabulary = ();
%Similarity = ();
@vocabularyTemp = <VO>;
@weightFile = <PO>;
@freqFile = <FC>;
@queryTerms = [];
$nDocuments = @weightFile;
$min = 0;
#Start
loadVocabulary();
getTerms();
if($mod eq 'vec'){
    searchVect();
}
elsif($mod eq 'min'){
    searchMin();
}
else{
    print "Modality not found!";
}
printRanking();

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
	$query = cleanTerm($query);
	$query = cleanStopWords($query, $stopwords);
    $_ = $query;
    if($mod eq 'vec'){
		$query = cleanNumbers($query);
		$_ = $query;
		@queryTerms = m/\b[a-z0-9_]+\b/g;
	}
	elsif($mod eq 'min'){
		$_ = $query;
		@queryTerms = m/\b[a-z0-9_]+\b/g;
		$min = $queryTerms[0];
		$query = cleanNumbers($query);
		$_ = $query;
		@queryTerms = m/\b[a-z0-9_]+\b/g;
	}
    
}

#Prints the result ranking
sub printRanking{
    $pos = 0;
    open(HEADER, "./Templates/header_html") or die $!;
    open(FOOTER, "./Templates/footer_html") or die $!;
    @header = <HEADER>;
    @footer = <FOOTER>;
    foreach $line (@header){
        print HTML $line;
    }
    foreach $sim (sort {$Similarity{$b} cmp $Similarity{$a}} keys %Similarity){
        if($pos++ >= $begin && $pos <= $end){
            #File Information
            $creation = POSIX::strftime("%d/%m/%y", localtime((stat "./$sim")[9]));
            $fileSize = (stat "./$sim")[7];
            open(FILE, "./$sim");
            @file = <FILE>;
            $lines = @file;
            $terms = 0;
            foreach $line (@freqFile){
                $_ = $line;
                if(m/$sim\|([0-9]+)\|[0-9]+/){
                    $terms = $1;
                }
            }
            #gets file loaded into string
            $document = do {
                local $/ = undef;
                open my $FILE, "<", $sim or die "could not open $sim: $!";
                <$FILE>;
            };
            #delets tabs and spaces, prints just one space instead
            $document =~ s/[ \t]+/ /g;
            #removes newlines and add three whitespaces
            $document =~ s/[\n\r]+/   /g;
            #gets 200 chars
            $document = substr($document, 0, 200);
            
            #Print to file
            print HTML "<li>$pos: $sim \n";
            print HTML "    <ul>";
            print HTML "        <li>Link: <a href=\"".File::Spec->rel2abs($sim)."\">Click para abrir el archivo</a></li>\n";
            print HTML "        <li>Similaridad: $Similarity{$sim}</li>\n";
            print HTML "        <li>Fecha Creacion: $creation</li>\n";
            print HTML "        <li>Tamano: $fileSize bytes</li>\n";
            print HTML "        <li>Lineas: $lines</li>\n";
            print HTML "        <li>Palabras diferentes: $terms</li>\n";
            print HTML "        <li>Primeros 200 caracteres:\n";
            print HTML "        <ul><li>\n";
            print HTML "            <PRE><span><small>$document</small></span></PRE>\n";
            print HTML "        </li></ul>\n";
            print HTML "    </li>\n";
            print HTML "</ul></li>\n";
            
        }
        print RANK "$pos: $sim\n";
        print RANK "Similaridad: $Similarity{$sim}</li>\n";
        print RANK "Fecha Creacion: $creation</li>\n";
        print RANK "Tamano: $fileSize bytes</li>\n";
        print RANK "Lineas: $lines\n";
        print RANK "Palabras diferentes: $terms\n";
        print RANK "====================================================\n"
    }
    foreach $line (@footer){
        print HTML $line;
    }
    open_default_browser("Results/$prefixQuery"."_$htmlFile.html");
}

#Vectorial Search Algorithm
sub searchVect{
    print "Searching using vectorial model...\n";
    $QueryNormVect = 0;
    %queryTermFreq = ();
    %weights = ();
    
    #Calculates weights for query terms
    for $term (sort @queryTerms){
        $queryTermFreq{$term}++;
    }
    
    #ordenar de mayor a menor
    for $term (sort keys %queryTermFreq){
		#asignar la frecuencia actual a la variable
        $freq = $queryTermFreq{$term};
        #si existe entonces hace la formula
        if(exists $Vocabulary{$term}){
            $weights{$term} = ((1+log2($freq))*log2($nDocuments/$Vocabulary{$term}));
        }
    }
    
    #ordena por pesos
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

#Min search Algorithm
sub searchMin{
    print "Searching using minimum model...\n";
    %freqQuery = ();
    $nTerms = 0;
    #freq(i,j) del query
    foreach $term (sort @queryTerms){
		$freqQuery{$term}++;
	}
	foreach $line (@freqFile){
		$nTerms = 0;
		$accumArriba = 0;
		$accumAbajo = 0;
		#get filepath
        $_ = $line;
        m/(.+)\|[0-9]+\|[0-9]+/;
        $path = $1;
        foreach $term (sort keys %freqQuery){
			$_ = $line;
			#search for terms in query in freq document
			if(m/$term,([0-9]+)/){ 
				#if match then start sum and count one match for min
				$accumArriba += $freqQuery{$term};
				$accumAbajo += $1;
				$nTerms++;
			}
		}
		#if matches are $min or more do the math
		if($nTerms >= $min){
			$Similarity{$path} = $accumArriba/log($accumAbajo);
		}
		else{
            $Similarity{$path} = 0;
        }
	}
}
