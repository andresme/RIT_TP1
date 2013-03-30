#!/usr/bin/perl -w

#########################################################
#File: buscar.pl                                        #
#                                                       #
#Description: Searching tool for documents              #
#in this collection.                                    #
#                                                       #
#Andres Morales Esquivel - 201016752                    #
#RIT I-2013                                             #
#########################################################

use utf8;
use POSIX;
use File::Spec;
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
    $_ = $query;
    @queryTerms = m/\b[a-z0-9_]+\b/g;
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
        if($pos++ >= $end){
            print RANK $sim.":".$Similarity{$sim}."\n";
        }
        elsif($pos >= $begin){
            print RANK $sim.":".$Similarity{$sim}."\n";
            #File Information
            $creation = POSIX::strftime("%d/%m/%y", localtime((stat "./$sim")[9]));
            $fileSize = (stat "./$sim")[7];
            open(FILE, "./$sim");
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
    }
    foreach $line (@footer){
        print HTML $line;
    }
    open_default_browser("Results/$prefixQuery"."_$htmlFile.html") or die $!;
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

#Min search Algorithm
sub searchMin{
    print "Searching using minimum model\n";
    
}
