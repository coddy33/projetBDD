#!/bin/env perl

use strict;
use warnings;
use DBI;

my $file = "Hotels1.csv";


sub initialisation{
my $dbh = DBI -> connect("DBI:Pg:dbname=fjung;host=dbserver","fjung","idiot21",{'RaiseError' => 1});

$dbh -> do ("drop table if exists initTable cascade");
$dbh -> do ("drop table if exists TableHotel cascade");
$dbh -> do ("drop table if exists Reservation cascade");
$dbh -> do ("drop table if exists client cascade");
$dbh -> do ("drop table if exists chambre cascade");

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

create table TableHotel(
Hotel text,
Gerant text,
Etoiles integer);

CREATE TABLE Reservation(
NumResa integer,
DebutResa text,
FinResa text,
NumChambre integer,
Hotel text,
NomClient text);


CREATE TABLE Client(
NomClient text,
PhoneClient text);


CREATE TABLE Chambre(
NumChambre text,
Hotel text,
Typecouchage text,
PrixBasseSaison integer,
PrixHauteSaison integer);
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

my $initHotel = $dbh->prepare("

insert into TableHotel(
select hotel, gerant, etoiles
From inittable );
");

my $initResa = $dbh->prepare("
INSERT INTO Reservation(
SELECT NumResa, DebutResa, FinResa, NumChambre, Hotel, NomClient
FROM InitTable);
");

my $initClient = $dbh->prepare("
INSERT INTO Client(
SELECT NomClient, PhoneClient
FROM InitTable);
");

my $initChambre = $dbh->prepare("
INSERT INTO Chambre(
SELECT NumChambre, Hotel, TypeCouchage, PrixBasseSaison, PrixHauteSaison
FROM InitTable);
");

$initHotel->execute();
$initResa->execute();
$initClient->execute();
$initChambre->execute();

close(HOTEL);
$dbh -> disconnect();

} #Fin de la fonction initialisation


# ===================MENU===================

sub menu{
    print "=========================MENU========================= \n";
    print "[1] Afficher la Table d'initialisation \n";
}


my $boucle = 1;
initialisation();
while ($boucle == 1){
    menu;
    my $rep = <>;
    if ($rep == 1){
        print "FILS DE PUTE \n";
    }
}
