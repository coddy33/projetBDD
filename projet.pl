#!/bin/env perl
#use strict; # A REMETTRE !!!!!!!!!!!!!!!!!!!
use warnings;
use DBI;
use DateTime;
use POSIX qw(strftime);

my $file = "Hotels1.csv";#Chargement du CSV, qui permet l'initialisation de la table si elle n'existe pas.
my $dbh = DBI -> connect("DBI:Pg:dbname=mbodet911e;host=dbserver","mbodet911e","idiot21",{'RaiseError' => 1});#Connection a la base

sub initialisation{
    #Teste l'existance de la table, et si existe, on n'ecrase pas avec les donnée du CSV.
    $dbh -> do ("drop table if exists initTable cascade");
    $dbh -> do ("drop table if exists TableHotel cascade");
    $dbh -> do ("drop table if exists Reservation cascade");
    $dbh -> do ("drop table if exists client cascade");
    $dbh -> do ("drop table if exists chambre cascade");

    #Si elle n'existe pas, on crée la table
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
    NomClient text UNIQUE,
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

    my $test = 1;#Permet de faire un test dans la boucle de lecture du CSV.
    open(HOTEL,$file) or die("$file inexistant \n");#Si le fichier n'existe pas, il retourne "Nom_du_fichier inexistant"
    my $remplissage = $dbh -> prepare("insert into initTable values (?,?,?,?,?,?,?,?,?,?,?,?)");

    while (<HOTEL>){#Boucle qui lit les lignes du fichier CSV.

        if ($test != 1){#Se test permet d'enlever la premiere ligne lors de la creation de la base.
            chomp($_);
            my @fields = split(',',$_);
            $remplissage -> execute($fields[0],$fields[1],int($fields[2]),int($fields[3]),$fields[4],int($fields[5]),int($fields[6]),int($fields[7]),$fields[8],$fields[9],$fields[10],$fields[11]);
            }
        $test = $test -1;
    }

    #Remplissage de la table.
    my $initHotel = $dbh->prepare("

    INSERT into TableHotel(
    SELECT hotel, gerant, etoiles
    FROM inittable
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

    close(HOTEL);#Fermeture du fichier CSV

} #Fin de la fonction initialisation


# ===================INTERROGATION===================
#Fonction qui permet d'afficher les resultats d'une requette SQL.
sub Affiche_interr{
    my $prep = $dbh->prepare(@_);
    $prep->execute;
    while (my $row = $prep->fetchrow_hashref) {
        my @fig = sort(keys(%$row));
        foreach my $fname (@fig) {
        print "$row->{$fname} ";
        }
    print "\n";
    }
}


sub interrogation {
    my $rep = <>;

    if ($rep == 1){
        print "Les gérants se nomment : \n";
        Affiche_interr("SELECT gerant,hotel  FROM tablehotel");
    }
    if ($rep == 2){
        print "Le nombre de gérants est de : \n";
        Affiche_interr("SELECT COUNT(DISTINCT gerant)  FROM tablehotel");
    } if ($rep == 3){
        print "Les gérants qui gérent au moins deux hotels sont : \n";
        Affiche_interr("SELECT gerant  FROM tablehotel GROUP BY gerant HAVING COUNT(*) >=2");
    }if ($rep == 4){
        print"Entrez une date de debut de reservation\n";
        chomp(my $dated=<>);#Demande la date a l'utilisateur
        my @convdated=split("/",$dated);#Split l'entrée de l'utilisateur via '/' et les mets dans des listes
        my $newDated = DateTime->new (day => $convdated[0],
                                      month => $convdated[1],
                                      year => $convdated[2]
                                      );
        print"Entrez une date de fin de reservation\n";
        chomp(my $datef=<>);
        my @convdatef=split("/",$datef);
        my $newDatef = DateTime->new (day => $convdatef[0],
                                      month => $convdatef[1],
                                      year => $convdatef[2]
                                      );

        $newDated=$newDated->dmy('/');#Permet d'avoir la date sous le format JJ/MM/AAAA
        $newDatef=$newDatef->dmy('/');
        print "Les hotels qui ont au moins une chambre de libre sont : \n";
        Affiche_interr("SELECT hotel FROM reservation WHERE ('$newDated' < debutresa AND '$newDatef' <debutresa) OR ('$newDated'>finresa AND '$newDatef'>finresa)");
    }
}
# =================================================


# ===================MISE A JOUR===================
#Fonction qui permet d'ajouter une chambre a la table.
sub ajouter_chambre{

    print "Pour quel hotel voulez vous ajouter une chambre ? \n";
    my $requete = "SELECT hotel FROM Chambre GROUP BY hotel";
    my $prep = $dbh->prepare($requete);
    $prep->execute;

        while (my($hotel) = $prep->fetchrow_array ){
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

    my $insert_chambre = $dbh->prepare("INSERT INTO Chambre VALUES(?,?,?,?,?)");
    $insert_chambre->execute($rep_numChambre,$rep_hotel,$rep_couchage,$rep_basseSaison,$rep_hauteSaison);#Insertion dans la table de la nouvelle chambre

}
#Fonction qui permet de modifier le gérant.
sub modifier_gerant{
        # my $requete = "SELECT hotel FROM Chambre GROUP BY hotel";
        # my $prep = $dbh->prepare($requete);
        # $prep->execute;
# UPDATE tablehotel
# SET gerant = 'Martial'
# WHERE gerant= 'dupont'
}
# ===========================================


# ==================STATISTIQUES=============

sub dateCacl {

my($date) = @_;
my @convDate = split("/",$date);
my $today = DateTime->new ( day => $convDate[0],
                            month =>$convDate[1],
                            year =>$convDate[2]
                            );
my $weekEarly = $today->clone->subtract( weeks => 1);
return ($today,$weekEarly);
}

sub hotel_taux {
    # Date: aujourd'hui et semaine derniere.
    my($today,$weekEarly,$h) = @_;

    my $requete1 = qq(SELECT COUNT(*)  FROM chambre WHERE hotel = '$h'); # Nombre total de chambre
    my $requete2 = qq(SELECT COUNT(*)  FROM reservation WHERE hotel = '$h' AND to_date(debutresa,'DD/MM/YYYY') <='$today' AND to_date(finresa,'DD/MM/YYYY') >= '$weekEarly' GROUP BY numchambre);
    my $prep1 = $dbh->prepare($requete1);
    my $prep2 = $dbh->prepare($requete2);

    $prep1->execute;

    my $taux;

    while (my($lineCount) = $prep1->fetchrow_array) {
        $prep2->execute;
        if ($prep2->rows == 0) {
                return 0;
        }
        while (my($dateCount) = $prep2->fetchrow_array ) {
            $taux = ($dateCount / $lineCount)*100;#Calcul du taux de reservation.
        }
    }
    return $taux;
}
#Taux pour tout les hotels
sub tout_hotel_taux {

    my($today,$weekEarly,$option) = @_;
    my $max = -1;
    my $hotel;
    my $requete1 = qq(SELECT hotel  FROM tablehotel);
    my $prep1 = $dbh->prepare($requete1);
    $prep1->execute;
    while (my($h) = $prep1->fetchrow_array) {
        my $taux = hotel_taux($today,$weekEarly,$h);
        if($option == 2){#Si on veux le taux pour tous les hotels
            print "$h -> $taux% \n";
    }elsif($option == 3){#Ou afficher celui qui a le plus haut taux
            if($taux > $max) {
                $max = $taux;
                $hotel = $h;
            }
        }
    }
    if($option == 3){
        print "Meilleure taux d'occupation : $hotel -> $max% \n";
    }
}


# ===================MENU===================

sub menu {
    print "=========================MENU========================= \n";
    print "\t [1] Interrogation \n";
    print "\t [2] Mise à jour \n";
    print "\t [3] Statistiques \n";
    print "\t [0] Quitter \n";
}

# ===================INTERROGATION===================
sub menu_interrogation {
    print "=========================MENU========================= \n";
    print "\t [1] Afficher les nom des gérants \n";
    print "\t [2] Afficher le nombre des gérants \n";
    print "\t [3] Afficher les personnes qui gèrent au moins deux hôtels \n";
    print "\t [4] Afficher les hôtels où il y a au moins une chambre de libre \n";
}

# ===================MISA A JOUR===================

sub menu_maj{
    print "=========================MENU========================= \n";
    print "\t [1] Ajouter une chambre à un hôtel\n";
    print "\t [2] Modifier le nom du gérant d'un hôtel\n";
    print "\t [3] Annuler une réservation\n";
    print "\t [4] Ajouter une réservation\n";
}

sub maj{
    my $rep = <>;
    if ($rep == 1){
        ajouter_chambre();
    }
    if ($rep == 2){

    }
    if ($rep == 3){
    }
    if ($rep == 4){

    }
}

# ===================STATISTIQUES===================

sub menu_stats{
    print "=========================MENU========================= \n";
    print "\t [1] Afficher le taux d'occupation d'un hôtel (7 derniers jours)\n";
    print "\t [2] Afficher le taux d'occupation de tous les hôtels (7 derniers jours)\n";
    print "\t [3] Afficher les ou les hôtels qui ont le plus grand taux d'occupation (7 derniers jours)\n";
}

sub stats{
print "Quelle date date de référence ? (JJ/02/2018)\n";
        chomp(my $date = <>);
        my($today,$weekEarly) = dateCacl($date);

        my $option = <>;
        my $taux;
        my $h;
        if ($option == 1) {
            print "Quel hôtel voulez-vous consulter ?\n";
            chomp($h = <>);
            $taux = hotel_taux($today,$weekEarly,$h);
            print "$h -> $taux% \n";
        }else {
            tout_hotel_taux($today,$weekEarly,$option);
        }
}

# ===================MAIN===================

my $boucle = 1;
initialisation();#lance l'initialisation de la table.

while ($boucle == 1){
    menu;#Affiche le menu.
    my $rep = <>;
    if ($rep == 1){
        menu_interrogation();
        interrogation();
    }
    if ($rep == 2){
        menu_maj();
        maj();
    }
    if ($rep == 3){
        menu_stats();
        stats();
    }
    if ($rep == 0){
        $dbh -> disconnect();
        exit;
    }
}
