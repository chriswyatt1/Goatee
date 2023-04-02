#!/usr/bin/perl
use warnings;
use strict;


print "Please be in folder with the *expansion.txt files\n\n";

#Find out all the names of GO terms found within our dataset.
my $ALL_go_terms=`cat *.txt | cut -f 1 | sort | uniq`;

#Download the GO iD to name hash:
`download_go_names.R > output`;

#Put go id to name infor into a hash.
my %ID_to_name;
my $input="GO_to_name";
open(my $goin, "<", $input)   or die "Could not open $input\n";
while (my $lineH=<$goin>){
	chomp $lineH;
	my @split=split("\t", $lineH);
	$ID_to_name{$split[1]}=$split[2];
	#print "$split[1] $split[2]\n";
}

#Read in file and infer species from file name
my @in_gofile=`ls *expansions.txt`;

my %species_go_hash;
foreach my $species_files (@in_gofile){
	chomp $species_files;
	my @name=split(/\./, $species_files);
	my $species=$name[0];
	open(my $filein, "<", $species_files)   or die "Could not open $species_files\n";
	while (my $line=<$filein>){
    	chomp $line;
    	my @split=split("\t", $line);
    	$species_go_hash{$species}{$split[0]}=$split[1];
	}
	close $filein;
}

#Set the output name
my $out="GO_table_counts.tsv";
open(my $fileout, ">", $out)   or die "Could not open $out\n";


#Print header:
print $fileout "Desc\tFamily ID";
foreach my $species (keys %species_go_hash){
	print $fileout "\t$species";
}
print $fileout "\n";

#Print table contents
foreach my $GO_terms (keys %ID_to_name){
	print $fileout "$ID_to_name{$GO_terms}\t$GO_terms";

	#Now for each species fill in the number of genes associated with each term.
	foreach my $species (keys %species_go_hash){
		if (exists $species_go_hash{$species}{$GO_terms}){
			print $fileout "\t$species_go_hash{$species}{$GO_terms}";
		}
		else{
			print $fileout "\t0";
		}
	}

	print $fileout "\n";
}

print "Script complete\n\n";
