#Fonction qui permet l'affichage des gerants de l'hotel.

use strict;
use warnings;
use DBI;

my $dbh = DBI -> connect("DBI:Pg:dbname=fjung;host=dbserver","fjung","idiot21",{'RaiseError' => 1});

my $requete = "SELECT gerant  FROM tablehotel";
my $prep = $dbh->prepare($requete);
    #or die "Impossible de préparer la requête : ".$dbh->errstr;

$prep->execute;

    #or die 'Impossible d\'exécuter la requête : '.$prep->errstr;
while (my($gerant,$hotel,$etoiles) = $prep->fetchrow_array ) {

      print "$gerant, $hotel, $etoiles\n";



    }
