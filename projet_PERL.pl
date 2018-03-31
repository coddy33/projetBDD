#!/bin/env perl
use strict; # A REMETTRE !!!!!!!!!!!!!!!!!!!
use warnings;
use Data::Dumper;

sub test_Perl { # Fonction avec 3 paramètres : nom du fichier, 2 numéros de colonnes distinctes
    my($file,$column1,$column2) = @_;
    my $test = 1;
    my %table;
    open(HOTEL,$file) or die ("Fichier inexistant\n");
    while(<HOTEL>) {
        if($test != 1) {
            chomp($_);
            my @fields = split(",",$_);
            next if not(defined $fields[$column2]);# éviter les données null du csv
            $table{$fields[$column1]} = {} if not(exists $table{$fields[$column1]});
            $table{$fields[$column1]}{$fields[$column2]} = 1 if not(exists $table{$fields[$column1]}{$fields[$column2]});
        }
        $test -= 1;
    }
    foreach my $x(keys(%table)) {
        my $size = keys %{$table{$x}};
        print "$x -> $size\n";
    }
    #print Dumper(\%table);
}

#============== MAIN =================

my $file = "Hotels1.csv";
print "Nombre de chambres :\n";
test_Perl($file,0,3); # nombre de chambre par hotel
print "\nNombre de réservations :\n";
test_Perl($file,0,7); # nombre de réservation par hotel
print "\nNombre de client :\n";
test_Perl($file,0,10);# nombre de clients par hotel
print "\nNombre d'hotel par nombre d'étoiles :\n";
test_Perl($file,2,0);# nombre d'hôtel par nombre d'étoile
print "\nNombre d'hotel par gérant :\n";
test_Perl($file,1,0);# nombre d'hôtel par gérants