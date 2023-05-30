#!/usr/bin/perl
use warnings;
use strict;
use Scalar::Util qw(looks_like_number);

print "Please be in folder with N0.tsv, Base/Gamma_change.tab, Base/Gamma_branch_probabilities.tab  and the Go folder\n";

#Set up output name
my $outname1="CAFE_summary.txt";
open(my $out1, ">", $outname1)   or die "Could not open $outname1\n";

#Read in OG hash
my $go="OG_GO_format.tsv";

#Read in Orthofinder file
my $file=`ls N0.ex.tsv`;
chomp $file;
open(my $filein, "<", $file)   or die "Could not open $file\n";
my $header=<$filein>;
my @head_N0=split("\t", $header);
my %HOG_TO_OG;
my %GENE_DATA;
my %OG_DATA;

#Create a background OG list for each species, for GO. See in next section.
my %Background_OGs;

while (my $line = <$filein>){
    chomp $line;
    my @splitl=split("\t", $line);
    my $hog=$splitl[0];
    my $og=$splitl[1];
    $HOG_TO_OG{$hog}=$og;
    my $n=0;
    foreach my $col (@splitl){
        #Save -> Species, HOG, and genes
        $GENE_DATA{$head_N0[$n]}{$hog}=$col;
        $OG_DATA{$head_N0[$n]}{$hog}=$og;

        #Create a background for each species, to show which OGs are present in each species, and hence were tested in each species (Background for GO).
        if ($col){
            if ($Background_OGs{$head_N0[$n]}){
                my $olde=$Background_OGs{$head_N0[$n]};
                $Background_OGs{$head_N0[$n]}="$olde\n$og";
            }
            else{
                $Background_OGs{$head_N0[$n]}=$og;
            }
        }
        $n++;
        #print "<$col>";
    }
    #my $len=scalar(@splitl);
    #print "$hog $n\n";
}

#Read in Pvalue and count file
my %PVALUE_DATA;
my %COUNT_DATA;
my $file2=`ls Out_cafe/Base_branch_probabilities.tab`;
my $file3=`ls Out_cafe/Base_change.tab `;
chomp $file2;
chomp $file3;
open(my $filein2, "<", $file2)   or die "Could not open $file2\n";
open(my $filein3, "<", $file3)   or die "Could not open $file3\n";
my $header2=<$filein2>;
my $header3=<$filein3>;

my @head_pval=split("\t", $header2);
my @head_pval_simp;
foreach my $colh (@head_pval){
    if ($colh =~ m/^</g){
        #print "$colh\n";
        my @spo=split("\>", $colh);
        my @spo2=split("\<", $spo[0]);
        #print "$spo2[1]\n";
        push (@head_pval_simp, $spo2[1]);
    }
    else{
        my @spo=split("\<", $colh);
        push (@head_pval_simp, $spo[0]);
    }
}


while (my $line2 = <$filein2>){
    chomp $line2;
    my @splitl=split("\t", $line2);
    my $hog=$splitl[0];
    my $n=0;
    foreach my $col (@splitl){
        #Save -> Species, HOG, and genes
        my $sp=$head_pval_simp[$n];
        $PVALUE_DATA{$sp}{$hog}=$col;
        $n++;
    }
}

while (my $line_count = <$filein3>){
    chomp $line_count;
    my @splitc=split("\t", $line_count);
    my $hog=$splitc[0];
    my $m=0;
    foreach my $col (@splitc){
        my $sp=$head_pval_simp[$m];
        $COUNT_DATA{$sp}{$hog}=$col;
        $m++;
    }
}

my %SPECIES_TOTAL;
my %SPECIES_EXPANSION;
my %SPECIES_CONTRACTION;

my %SPECIES_EXPANSION_SUM;
my %SPECIES_CONTRACTION_SUM;

foreach my $species (keys %PVALUE_DATA){
    #print "$species\n";
    foreach my $hog (keys %{$PVALUE_DATA{$species}}){
        my $pval=$PVALUE_DATA{$species}{$hog};
        #print "$hog\n";
        if (looks_like_number($pval) ){
            if($pval <= 0.05){
                my $direction=$COUNT_DATA{$species}{$hog};
                #print "HERE $direction\n";
                $SPECIES_TOTAL{$species}++;
                if ($direction eq "\+0"){
                    #Do nothing
                    print "HEY, why is this true:\n$species $hog $PVALUE_DATA{$species}{$hog} has a direction $direction\n";
                }
                elsif ($direction =~ m/\+/g){
                    $SPECIES_EXPANSION{$species}++;
                    $SPECIES_EXPANSION_SUM{$species}+=$direction;
                }
                elsif($direction =~ m/\-/g){
                    $SPECIES_CONTRACTION{$species}++;
                    $SPECIES_CONTRACTION_SUM{$species}+=$direction;
                }
                else{
                    print "WEIRD<<<< What is this $direction\n";
                }
            }
        }
    }
}



#Count the number of HOGs with + or - change, not regarding pvalue.
my %SPECIES_TOTAL_C;
my %SPECIES_EXPANSION_C;
my %SPECIES_CONTRACTION_C;
my %SPECIES_C_OGS;

#Run through the COUNT DATA and count 
foreach my $species3 (keys %COUNT_DATA){
    foreach my $hog (keys %{$COUNT_DATA{$species3}}){
        if ($COUNT_DATA{$species3}{$hog} eq "\+0"){
            #Do nothing
            #print "NO $species3 $hog $COUNT_DATA{$species3}{$hog}\n";
        }
        elsif($COUNT_DATA{$species3}{$hog} =~ m/\+/g){
            #print "X   $species3 $hog $COUNT_DATA{$species3}{$hog}\n";
            $SPECIES_EXPANSION_C{$species3}++;
            $SPECIES_TOTAL_C{$species3}++;
            my $og=$HOG_TO_OG{$hog};
            #print "$species3 $hog\n";
            if ($SPECIES_C_OGS{$species3}{'pos'}){
                my $old=$SPECIES_C_OGS{$species3}{'pos'};
                $SPECIES_C_OGS{$species3}{'pos'}="$old\n$og";
            }
            else{
                $SPECIES_C_OGS{$species3}{'pos'}="$og";
            }
            
        }
        else{
            #print "OORR $species3 $hog $COUNT_DATA{$species3}{$hog}\n";
            $SPECIES_CONTRACTION_C{$species3}++;
            $SPECIES_TOTAL_C{$species3}++;
            my $og=$HOG_TO_OG{$hog};
            #print "$species3 $hog\n";
            if ($SPECIES_C_OGS{$species3}{'neg'}){
                my $old=$SPECIES_C_OGS{$species3}{'neg'};
                $SPECIES_C_OGS{$species3}{'neg'}="$old\n$og";
            }
            else{
                $SPECIES_C_OGS{$species3}{'neg'}="$og";
            }
        }
    }
}


#Print GO_lists
foreach my $species4 (keys %SPECIES_C_OGS){
    if ($species4 eq "#FamilyID"){
        #Do nothing
    }
    else{
        #Set up output name
        my $outna2="$species4\.pos.txt";
        open(my $out2, ">", $outna2)   or die "Could not open $outna2\n";
        my $outna3="$species4\.neg.txt";
        open(my $out3, ">", $outna3)   or die "Could not open $outna3\n";

        print $out2 "$SPECIES_C_OGS{$species4}{'pos'}\n";
        print $out3 "$SPECIES_C_OGS{$species4}{'neg'}\n";

        close $out2;
        close $out3;
    }

}

#Print Background GO lists
foreach my $species6 (keys %Background_OGs){
    my $out_back="$species6\.BK.txt";
    open(my $outb, ">", $out_back)   or die "Could not open $out_back\n";
    print $outb "$Background_OGs{$species6}\n";
    `sort $species6\.BK.txt | uniq > $species6\.BK.txt.uniq`;
}


#Print a summary table:

print $out1 "Total_HOGs_significant\tExpansion_HOGs_significant\tContraction_HOGs_significant\tExpansion_genes_significant\tContraction_genes_significant\tExpansion_HOGs_total\tContraction_HOGs_total\n";

foreach my $species2 (keys %SPECIES_TOTAL){
    print $out1 "$species2\t$SPECIES_TOTAL{$species2}";
    if ($SPECIES_EXPANSION{$species2}){
        print $out1 "\t$SPECIES_EXPANSION{$species2}";
    }
    else{
        print $out1 "\t0";
    }
    if ($SPECIES_CONTRACTION{$species2}){
        print $out1 "\t$SPECIES_CONTRACTION{$species2}";
    }
    else{
        print $out1 "\t0";
    }


    if ($SPECIES_EXPANSION_SUM{$species2}){
        print $out1 "\t$SPECIES_EXPANSION_SUM{$species2}";
    }
    else{
        print $out1 "\t0";
    }
    if ($SPECIES_CONTRACTION_SUM{$species2}){
        print $out1 "\t$SPECIES_CONTRACTION_SUM{$species2}";
    }
    else{
        print $out1 "\t0";
    }

    #Not significant expansions and contractions:
    if ($SPECIES_EXPANSION_C{$species2}){
        print $out1 "\t$SPECIES_EXPANSION_C{$species2}";
    }
    else{
        print $out1 "\t0";
    }
    if ($SPECIES_CONTRACTION_C{$species2}){
        print $out1 "\t$SPECIES_CONTRACTION_C{$species2}";
    }
    else{
        print $out1 "\t0";
    }
    print $out1 "\n";
}



#Now run Chopgo

foreach my $species5 (keys %SPECIES_TOTAL){
    print "Running GO on $species5\n";
    if (looks_like_number($species5)){
	`mv $species5\.pos.txt Node_$species5\.pos.txt`;
	`mv $species5\.neg.txt Node_$species5\.neg.txt`;

	`ChopGO_VTS2.pl -i Node_$species5\.pos.txt --GO_file $go -bg OG_GO_format.tsv`;
	`ChopGO_VTS2.pl -i Node_$species5\.neg.txt --GO_file $go -bg OG_GO_format.tsv`;
    }
    else{
	`ChopGO_VTS2.pl -i $species5\.pos.txt --GO_file $go -bg $species5\.BK.txt.uniq`;
	`ChopGO_VTS2.pl -i $species5\.neg.txt --GO_file $go -bg $species5\.BK.txt.uniq`;
    }
}


close $out1;

print "\nFinished Running\n\n";




