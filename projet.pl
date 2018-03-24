#!/bin/env perl

use strict;
use warnings;
use DBI;
use DateTime;

my $file = "Hotels1.csv";



sub initialisation{
my $dbh = DBI -> connect("DBI:Pg:dbname=sgoncal1;host=dbserver","sgoncal1","ANST4-case4",{'RaiseError' => 1});

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
Hotel text PRIMARY KEY,
Gerant text,
Etoiles integer);

CREATE TABLE Reservation(
NumResa integer PRIMARY KEY,
DebutResa text,
FinResa text,
NumChambre integer,
Hotel text,
NomClient text);


CREATE TABLE Client(
NomClient text PRIMARY KEY,
PhoneClient text);


CREATE TABLE Chambre(
NumChambre text,
Hotel text,
Typecouchage text,
PrixBasseSaison integer,
PrixHauteSaison integer,
PRIMARY KEY(NumChambre,Hotel));
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
From inittable
GROUP BY hotel,gerant,etoiles );
");

my $initResa = $dbh->prepare("
INSERT INTO Reservation(
SELECT NumResa, DebutResa, FinResa, NumChambre, Hotel, NomClient
FROM InitTable
GROUP BY NumResa, DebutResa, FinResa, NumChambre, Hotel, NomClient );
");

my $initClient = $dbh->prepare("
INSERT INTO Client(
SELECT NomClient, PhoneClient
FROM InitTable
GROUP BY NomClient,PhoneClient);
");

my $initChambre = $dbh->prepare("
INSERT INTO Chambre(
SELECT NumChambre, Hotel, TypeCouchage, PrixBasseSaison, PrixHauteSaison
FROM InitTable
GROUP BY NumChambre, Hotel, TypeCouchage, PrixBasseSaison, PrixHauteSaison);
");

$initHotel->execute();
$initResa->execute();
$initClient->execute();
$initChambre->execute();

close(HOTEL);
$dbh -> disconnect();

} #Fin de la fonction initialisation


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

sub modifier_gerant {


# UPDATE tablehotel
# SET gerant = 'Martial'
# WHERE gerant= 'dupont'


}

# ===================STATISTIQUES===================

# ===================MENU===================

sub menu{
    print "=========================MENU========================= \n";
    print "\t [1] Interrogation \n";
    print "\t [2] Mise à jour \n";
    print "\t [2] Statistiques \n" 
}


sub menu_interrogation{
    print "=========================MENU========================= \n";
    print "\t [1] Afficher les nom des gérants \n";
    print "\t [2] Afficher le nombre des gérants \n";
    print "\t [3] Afficher les personnes qui gèrent au moins deux hôtels \n";
    print "\t [4] Afficher les hôtels où il y a au moins une chambre de libre \n";    
}

sub menu_maj{
    print "=========================MENU========================= \n";
    print "\t [1] Ajouter une chambre à un hôtel\n";    
    print "\t [2] Modifier le nom du gérant d'un hôtel\n";    
    print "\t [3] Annuler une réservation\n";    
    print "\t [4] Ajouter une réservation\n";        
}

sub menu_stats{
    print "=========================MENU========================= \n";
    print "\t [1] Afficher le taux d'occupation d'un hôtel (7 derniers jours)\n";    
    print "\t [1] Afficher le taux d'occupation de tous les hôtels (7 derniers jours)\n";    
    print "\t [1] Afficher les ou les hôtels qui ont le plus grand taux d'occupation (7 derniers jours)\n";        
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




