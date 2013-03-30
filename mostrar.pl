#!/usr/bin/perl -w

#########################################################
#File: mostrar.pl                                        #
#                                                        #
#Description: Displays information about                 #
#created files by this set of tools.                    #
#                                                        #
#Andres Morales Esquivel - 201016752                    #
#RIT I-2013                                                #
#########################################################

use utf8;

#Arguments
$mod = $ARGV[0];
$file = $ARGV[1];

#File Handlers
open(FILE, "./Results/$file") or die $!;

#Global Variables
@file = <FILE>;

#Start
if($mod eq 'frec'){
    showFreqFile();
}
elsif($mod eq 'pesos'){
    showWeightFile();
}
elsif($mod eq 'vocab'){
    showVocabFile();
}
elsif($mod eq 'esca'){
    $begin = $ARGV[2];
    $end = $ARGV[3];
}
else{
    print "Modality not found";
}

sub showFreqFile{
    $pathFile = $ARGV[2];
    foreach $line (@file){
        $_ = $line;
        if(m/^($pathFile)\|([0-9]+)\|([0-9]+)/){
            $path = $1;
            $number = $2;
            $maxFreq = $3;
            $_ = $line;
            @terms = m/[a-z0-9_]+,[0-9]+/g;
            print "Path: $path\n";
            print "Number of terms: $number\n";
            print "Max Frequency: $maxFreq\n";
            print "Terms (term, freq):\n";
            foreach $term (@terms){
                print "$term\n";
            }
        }
    }
}

sub showWeightFile{
    $pathFile = $ARGV[2];
    foreach $line (@file){
        $_ = $line;
        if(m/^($pathFile)\|([0-9]+)\|([0-9.]+)/){
            $path = $1;
            $number = $2;
            $norm = $3;
            $_ = $line;
            @terms = m/[a-z0-9_]+,[0-9.]+/g;
            print "Path: $path\n";
            print "Number of terms: $number\n";
            print "Norm of File: $norm\n";
            print "Terms (term, weight):\n";
            foreach $term (@terms){
                print "$term\n";
            }
        }
    }
}

sub showVocabFile{
    $begin = $ARGV[2];
    $end = $ARGV[3];
    $print = 0;
    print "Vocabulary from $begin to $end inclusive:\n";
    foreach $line (@file){
        $_ = $line;
        @term = m/^[a-z0-9_]+/g;
        if($term[0] eq $begin){
            $print = 1;
        }
        if($print){
            print $line;
        }
        if($term[0] eq $end){
            $print = 0;
        }
    }
}

sub showRankFile{
    $begin = $ARGV[2];
    $end = $ARGV[3];

}
