#!/bin/env perl
use strict;
use warnings;
use DBI;
use DateTime;

my $file = "Hotels1.csv";#Chargement du CSV, qui permet l'initialisation de la table si elle n'existe pas.
my $dbh = DBI -> connect("DBI:Pg:dbname=mbodet911e;host=dbserver","mbodet911e","idiot21",{'RaiseError' => 1});#Connection a la base
$dbh-> do( "SET datestyle = ISO, DMY" );#Permet de definir le type d'heure (dd/mm/aaaa)

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
    DebutResa date,
    FinResa date,
    NomClient text,
    PhoneClient text);

    create table TableHotel(
    Hotel text PRIMARY KEY,
    Gerant text,
    Etoiles integer);

    CREATE TABLE Reservation(
    NumResa integer PRIMARY KEY,
    DebutResa date,
    FinResa date,
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


# ============================SAUVEGARDER DANS UN FICHIER================
sub save_html{
    #
    # Cette fonction prend en argument le nom que le souhaite donner à la table
    # et une requête. Elle enregistre dans un fichier html le résultat de la requete présenté
    # sous forme de tableau.
    #
    # Prend 2 arguments :
    #   -$requete : premier argument, entrer la requete
    #   -$nom_table : deuxieme argument, donner le nom de la table
    #
    my($requete,$nom_table) = @_;
    print "Quel nom voulez-vous donner à votre fichier ?\n";
    my $nom_fichier = <>;
    my $table = "tableHotel";
    open (FICHIER, "> $nom_fichier ") || die ("Vous ne pouvez pas créer le fichier \"fichier.txt\"");
    print FICHIER "<!DOCTYPE html> \n
    <html><head>
    <meta http-equiv='content-type' content='text/html; charset=windows-1252'>
    <meta charset='UTF-8'>
    <title>$nom_table</title>
    </head>
    <body>
    <table border='1'>
    <caption> $nom_table    </caption>
    <tbody><tr> ";

    my $prep = $dbh->prepare($requete);
    $prep->execute;
    while (my $row = $prep->fetchrow_hashref) {
        my @fig = sort(keys(%$row));
        print FICHIER "<tr>";
        foreach my $fname (@fig) {
            print FICHIER"<td> $row->{$fname} </td>";
            }
    print FICHIER "</tr> \n";
    }
    print FICHIER "</tbody></table>
    </body></html>";
    # print FICHIER "coucou";
    close (FICHIER);
}

# =========================GERSTION D'ERREUR========================
sub gestion_erreur_date{
    while(1){
        chomp(my$date = <>);
        if ($date=~ /(\d{2})\/(\d{2})\/(\d{4})/){
            if ($1 <= 31 && $2 <= 12 && $3>1990){
                return $date;
            }else{
                print"Valeur trop grande, recommmencez ! \n";
            }
        }else{
            print"Mauvais valeur ! (JJ/MM/AAAA)\n";
        }
    }
}
# =========================FIN GERSTION D'ERREUR========================


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
        rafraichir_ecran();
        print "Les gérants se nomment : \n";
        Affiche_interr("SELECT gerant,hotel  FROM tablehotel");
    }
    if ($rep == 2){
        rafraichir_ecran();
        print "Le nombre de gérants est de : \n";
        Affiche_interr("SELECT COUNT(DISTINCT gerant)  FROM tablehotel");
        print "Voulez-vous sauvegarder ? (o/n)\n";
        chomp(my $save=<>);
        if($save eq "o"){
            save_html("SELECT COUNT(DISTINCT gerant)  FROM tablehotel", "Nombre de gerants :");
        }
    } if ($rep == 3){
        rafraichir_ecran();
        print "Les gérants qui gérent au moins deux hotels sont : \n";
        Affiche_interr("SELECT gerant  FROM tablehotel GROUP BY gerant HAVING COUNT(*) >=2");
        print "Voulez-vous sauvegarder ?(o/n)\n";
        chomp(my $save=<>);
        if($save eq "o"){
            save_html("SELECT gerant  FROM tablehotel GROUP BY gerant HAVING COUNT(*) >=2", "Les personnes qui gèrent au moins deux Hôtels :");
        }
    }if ($rep == 4){
        rafraichir_ecran();
        print"Entrez une date de debut de reservation (JJ/MM/AAAA)\n";
        chomp(my $dated=gestion_erreur_date());#Demande la date a l'utilisateur
        print"Entrez une date de fin de reservation\n";
        chomp(my $datef=gestion_erreur_date());
        print "Les hotels qui ont au moins une chambre de libre sont : \n";
        Affiche_interr("SELECT hotel FROM reservation WHERE( (TO_DATE('$dated','DD/MM/YYYY')<debutresa AND TO_DATE('$datef','DD/MM/YYYY')<debutresa) OR (TO_DATE('$dated','DD/MM/YYYY')>finresa AND TO_DATE('$datef','DD/MM/YYYY')>finresa) ) GROUP BY hotel");
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
    my @Thotel;
        while (my($hotel) = $prep->fetchrow_array ){
        push(@Thotel,$hotel);
        }
    for (my $i=0 ; $i < $#Thotel ; $i++ ){
        print "[$i] $Thotel[$i] \n";
    }
    my $rep_numhotel = <>;
    my $rep_hotel = $Thotel[$rep_numhotel];
    print "Quel est le numéro de la chambre ?\n";
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
  print "Quel gerant voulez vous modifier ?\n";
  Affiche_interr("SELECT gerant,hotel  FROM tablehotel\n");
  chomp(my $oldgerant=<>);
  print "Quel est le nouveau nom du gérant ?\n";
  chomp(my $newgerant=<>);
  my $requete = "UPDATE tablehotel SET gerant='$newgerant' WHERE gerant='$oldgerant'";
  my $prep = $dbh->prepare($requete);
  $prep->execute;

}
#Fonction qui permet d'annuler une reservation.
sub annuler_resa{
    print"Quel est votre nom ?\n";
    chomp(my $nom=<>);

    Affiche_interr("SELECT numresa,debutresa,finresa FROM reservation WHERE nomclient='$nom' AND numresa>0" );#WHERE nomclient='$nom'");
    print"Quel est votre numero de reservation ?\n";
    chomp(my $numresa=<>);

        my $requete="DELETE FROM reservation WHERE debutresa > CURRENT_DATE+2 AND numresa = '$numresa'";
        my $prep=$dbh->prepare($requete);
        $prep->execute;

}
#Fonction qui permet de rajouter un reservation.
sub ajouter_resa{
    my $requete = "SELECT hotel FROM reservation GROUP BY hotel";
    my $prep = $dbh->prepare($requete);
    $prep->execute;
    print "Dans quel hotel voulez vous reserver ?\n";
    my @Thotel;
    while (my($h) = $prep->fetchrow_array ){
        push(@Thotel,$h);
    }
    for (my $i=0 ; $i < $#Thotel ; $i++ ){
        print "[$i] $Thotel[$i] \n";
    }
    my $rep_numhotel = <>;
    my $hotel = $Thotel[$rep_numhotel];
    chomp($hotel);
    print "Quelle est votre date d'arrivée ?\n";
    chomp(my$debut = <>);
    print "Quelle est votre date de départ ?  \n";
    chomp(my$fin = <>);

    $requete = "SELECT numchambre FROM reservation WHERE (hotel='$hotel' AND (debutresa >TO_DATE('$debut','DD/MM/YYYY')  AND debutresa>TO_DATE('$fin','DD/MM/YYYY') )
    OR(finresa<TO_DATE('$debut','DD/MM/YYYY') AND finresa<TO_DATE('$fin','DD/MM/YYYY') )) GROUP BY numchambre";
    $prep = $dbh->prepare($requete);
    $prep->execute;
    print "La liste des chambres vides pour cet hotel est : \n";
        while (my($chambre) = $prep->fetchrow_array ){
         print "chambre : $chambre \n";
         }
    print "Quel est le numéro de la chambre choisie:\n";
    my $numchambre = <>;

    print "Quel est votre nom ?  \n";
    my $nom = <>;

    print "Quel est votre numero ?  \n";
    my $numero = <>;

    $requete="SELECT MAX(numresa) FROM reservation";
    $prep= $dbh->prepare($requete);
    $prep->execute;
    my $numresa = $prep->fetchrow_array();
    $numresa=$numresa+1;
    my $insert_resa = $dbh->prepare("INSERT INTO reservation VALUES(?,?,?,?,?,?)");
    $insert_resa->execute($numresa,$debut,$fin,$numchambre,$hotel,$nom);#Insertion dans la table de la nouvelle chambre
    my $insert_client = $dbh->prepare("INSERT INTO client VALUES(?,?)");
    $insert_client->execute($nom,$numero);#Insertion dans la table de la nouvelle chambre

}
# ===========================================


# ==================STATISTIQUES=============

sub dateConvert {

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
    my $requete2 = qq(SELECT COUNT(*)  FROM reservation WHERE hotel = '$h' AND debutresa <='$today' AND finresa >= '$weekEarly' GROUP BY numchambre);
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
    my %dataStat;
    my $requete1 = qq(SELECT hotel  FROM tablehotel);
    my $prep1 = $dbh->prepare($requete1);
    $prep1->execute;
    while (my($h) = $prep1->fetchrow_array) {
        my $taux = hotel_taux($today,$weekEarly,$h);
        if($option == 2){#Si on veux le taux pour tous les hotels
            print "$h -> $taux% \n";
            $dataStat{$h} = $taux;
        }elsif($option == 3){#Ou afficher celui qui a le plus haut taux
            if($taux > $max) {
                $max = $taux;
                $hotel = $h;
            }
        }
  }
    if($option == 2) {
        statTable(%dataStat);
        print "Voulez-vous sauvegarder ? (o/n)\n";
        chomp(my $rep=<>);
        if($rep eq "o"){
            save_html("SELECT * FROM tauxHotel", "Taux d'occupations :");
        }
    }elsif($option == 3){
        print "Meilleure taux d'occupation : $hotel -> $max% \n";
    }
}

sub statTable { # creation d'une table avec chaque taux de chaque hotel
    my(%dataStat) = @_;
    $dbh -> do ("drop table if exists tauxHotel");
    my $table = $dbh->prepare("
    create table tauxHotel(
        Hotel text,
        Taux float(24));");
    $table -> execute;
    foreach my $x (keys(%dataStat)) {
        my $requete = $dbh->prepare (qq(INSERT INTO tauxHotel VALUES (?,?)));
        $requete -> execute($x,int($dataStat{$x}));
    }
}


# ===================MENU===================

sub menu {
    print "=========================MENU========================= \n";
    print "\t [1] Interrogation \n";
    print "\t [2] Mise à jour \n";
    print "\t [3] Statistiques \n";
    print "\t [4] reinitialiser la base de données \n";
    print "\t [0] Quitter \n";
}

# ===================INTERROGATION===================
sub menu_interrogation {
    rafraichir_ecran();
    print "=========================INTERROGATION========================= \n";
    print "\t [1] Afficher les nom des gérants \n";
    print "\t [2] Afficher le nombre des gérants \n";
    print "\t [3] Afficher les personnes qui gèrent au moins deux hôtels \n";
    print "\t [4] Afficher les hôtels où il y a au moins une chambre de libre \n";
}


# ===================MISE A JOUR===================

sub menu_maj{
    rafraichir_ecran();
    print "=========================MISE A JOUR========================= \n";
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
      modifier_gerant();
    }
    if ($rep == 3){
        annuler_resa();
    }
    if ($rep == 4){
        ajouter_resa();
    }
}

# ===================STATISTIQUES===================

sub menu_stats{
    rafraichir_ecran();
    print "=========================STATISTIQUES========================= \n";
    print "\t [1] Afficher le taux d'occupation d'un hôtel (7 derniers jours)\n";
    print "\t [2] Afficher le taux d'occupation de tous les hôtels (7 derniers jours)\n";
    print "\t [3] Afficher les ou les hôtels qui ont le plus grand taux d'occupation (7 derniers jours)\n";
}

sub stats{
    my $option = <>;
    print "Quelle date date de référence ? (JJ/02/2018)\n";
    chomp(my $date = <>);
    my($today,$weekEarly) = dateConvert($date);

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

sub rafraichir_ecran{
    print "\033[2J";
    print "\033[0;0H";
}

rafraichir_ecran();

while (1){
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
    if ($rep == 4){
        initialisation();#lance l'initialisation de la table.
    }
    if ($rep == 0){
        $dbh -> disconnect();
        exit;
    }
}
