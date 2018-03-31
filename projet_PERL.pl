#!/bin/env perl
use strict; # A REMETTRE !!!!!!!!!!!!!!!!!!!
use warnings;
use Data::Dumper;

sub test_Perl {
    my($file) = @_;
    my $test = 1;
    my %table;
    open(HOTEL,$file) or die ("Fichier inexistant\n");
    while(<HOTEL>) {
        if($test != 1) {
            chomp($_);
            my @fields = split(",",$_);
            $table{$fields[0]} = {} if not(exists $table{$fields[0]});
            $table{$fields[0]}{$fields[3]} = 1 if not(exists $table{$fields[0]}{$fields[3]});
        }
        $test -= 1;
    }
    print "Nombre de chambres :\n";
    foreach my $x(keys(%table)) {
        my $size = keys %{$table{$x}};
        print "$x -> $size\n";
    }
    #print Dumper(\%table);
}

#============== MAIN =================

my $file = "Hotels1.csv";
test_Perl($file);

