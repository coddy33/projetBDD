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


#Fonction qui permet l'affichage des gerants de l'hotel.

# ===================INTEGRATION===================


sub afficher_gerant{
my $dbh = DBI -> connect("DBI:Pg:dbname=fjung;host=dbserver","fjung","idiot21",{'RaiseError' => 1});
my $requete = "SELECT gerant,hotel  FROM tablehotel";
my $prep = $dbh->prepare($requete);
$prep->execute;
    #or die 'Impossible d\'exécuter la requête : '.$prep->errstr;
while (my($gerant,$hotel) = $prep->fetchrow_array ) {

      print "$hotel -> $gerant\n";
    #  print "Le gerant de l'hotel $hotel est monsieur $gerant\n";
    }
}

# ===================MISE A JOUR===================

sub ajouter_chambre{
    my $dbh = DBI -> connect("DBI:Pg:dbname=fjung;host=dbserver","fjung","idiot21",{'RaiseError' => 1});
    print "Pour quel hotel voulez vous ajouter une chambre ? \n";
    my $requete = "SELECT hotel FROM Chambre GROUP BY hotel";
    my $prep = $dbh->prepare($requete);
    $prep->execute;
    while (my($hotel) = $prep->fetchrow_array ) {
          print "$hotel \n";
    }
    my $rep_hotel = <>;
    print "Quel est le numéro de la chambre ?";
    my $rep_numChambre = <>;
    print "Quel est le type de couchage ? (Simple/Double) \n";
    my $rep_couchage = <>;
    print "Quel est le prix basse saison ?  \n";
    my $rep_basseSaison = <>;
    print "Quel est le haute basse saison ?  \n";
    my $rep_hauteSaison = <>;
# ================================
    my $insert_chambre = $dbh->prepare("INSERT INTO Chambre VALUES(?,?,?,?,?)");
    $insert_chambre->execute($rep_numChambre,$rep_hotel,$rep_couchage,$rep_basseSaison,$rep_hauteSaison);

}

sub modifier_gerant{

# UPDATE hotel
# SET gerant = "?"
# WHERE gerant

UPDATE tablehotel
SET gerant = 'Martial'
WHERE gerant= 'dupont'


}


# ===================MENU===================

sub menu{
    print "=========================MENU========================= \n";
    print "[1] Afficher \n";
    print " 2 inserer chambre"
}


my $boucle = 1; 
initialisation();
while ($boucle == 1){
    menu;
    my $rep = <>;
    if ($rep == 1){
        afficher_gerant();
    }
    if ($rep == 2){
        ajouter_chambre();
    }
}




