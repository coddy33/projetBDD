#!/bin/env perl

use strict;
use warnings;
use DBI;


my $file = "Hotels1.csv";


sub initialisation{
my $dbh = DBI -> connect("DBI:Pg:dbname=fjung;host=dbserver","fjung","idiot21",{'RaiseError' => 1});

$dbh -> do ("drop table if exists initTable cascade");

my $sth = $dbh->prepare("

create table initTable(
Hotel text,
Gerant text,
Etoiles integer,
NumChambre integer,
TypeCouchage text,
PrixBasseSaison integer,
PrixHauteSaison integer,
NumResa integer,
DebutResa text,
FinResa text,
NomClient text,
PhoneClient text);     
");
$sth->execute();

my $x = 1;
open(HOTEL,$file) or die("$file inexistant \n");
my $remplissage = $dbh -> prepare("insert into initTable values (?,?,?,?,?,?,?,?,?,?,?,?)");
while (<HOTEL>){
    if ($x != 1){
    chomp($_);
    my @fields = split(',',$_);   
    $remplissage -> execute($fields[0],$fields[1],int($fields[2]),int($fields[3]),$fields[4],int($fields[5]),int($fields[6]),int($fields[7]),$fields[8],$fields[9],$fields[10],$fields[11]);
}
    $x = $x -1;
}
close(HOTEL);

$dbh -> disconnect();
}

sub menu{
    print "=========================MENU========================= \n";
    print "[1] Afficher la Table d'initialisation \n";
}

menu();