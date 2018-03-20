#Fonction qui permet l'affichage des gerants de l'hotel.

# use strict;
# use warnings;
# use DBI;
#
# my $dbh = DBI -> connect("DBI:Pg:dbname=fjung;host=dbserver","fjung","idiot21",{'RaiseError' => 1});
#
# my $requete = "SELECT gerant,hotel  FROM tablehotel";
# my $prep = $dbh->prepare($requete);
#     #or die "Impossible de préparer la requête : ".$dbh->errstr;
#
# $prep->execute;
#
#     #or die 'Impossible d\'exécuter la requête : '.$prep->errstr;
# while (my($gerant,$hotel) = $prep->fetchrow_array ) {
#
#       print "$hotel -> $gerant\n";
#     #  print "Le gerant de l'hotel $hotel est monsieur $gerant\n";
#
#     }

#Fonction qui affiche le nombre de gerant.

# use strict;
# use warnings;
# use DBI;
#
# my $dbh = DBI -> connect("DBI:Pg:dbname=fjung;host=dbserver","fjung","idiot21",{'RaiseError' => 1});
#
# my $requete = "SELECT COUNT(DISTINCT gerant)  FROM tablehotel ";
# my $prep = $dbh->prepare($requete);
#     #or die "Impossible de préparer la requête : ".$dbh->errstr;
#
# $prep->execute;
# my @tab;
#     #or die 'Impossible d\'exécuter la requête : '.$prep->errstr;
# while (my($gerant) = $prep->fetchrow_array ) {
#     print "$gerant\n";
#     #  print "Le gerant de l'hotel $hotel est monsieur $gerant\n";
#
#     }


#Afficher le nom de personne qui gerent au moins deux hotel.
use strict;
use warnings;
use DBI;

my $dbh = DBI -> connect("DBI:Pg:dbname=fjung;host=dbserver","fjung","idiot21",{'RaiseError' => 1});

my $requete = "SELECT gerant  FROM tablehotel GROUP BY gerant HAVING COUNT(*) >=2";
my $prep = $dbh->prepare($requete);
    #or die "Impossible de préparer la requête : ".$dbh->errstr;
$prep->execute;

    #or die 'Impossible d\'exécuter la requête : '.$prep->errstr;
while (my($gerant) = $prep->fetchrow_array ) {
    print "$gerant\n";

    #  print "Le gerant de l'hotel $hotel est monsieur $gerant\n";

    }
