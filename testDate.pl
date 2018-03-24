use strict;
use warnings;
use DateTime;
use DBI;

# # Current date (today)
# my $today = DateTime->new ( day => 22,
#                             month =>02,
#                             year =>2018
#                             ); 
# print $today->dmy("/"),"\n";

# # 1 week 
# my $weekEarly = $today->clone->subtract( weeks => 1);
# print $weekEarly->dmy("/"),"\n";

# # compare Date
# my $cmp = DateTime->compare($today, $weekEarly);
# print "$cmp \n";

# # If statement
# if($today > $weekEarly) {
#     print "La date ",$today->dmy("/")," est plus grande que la date ",$weekEarly->dmy("/"),"\n";
# }


sub taux_occupation {
my($h) = @_;
my $today = DateTime->new ( day => 26,
                            month =>02,
                            year =>2018
                            );
my $weekEarly = $today->clone->subtract( weeks => 1);
my $dbh = DBI -> connect("DBI:Pg:dbname=sgoncal1;host=dbserver","sgoncal1","ANST4-case4",{'RaiseError' => 1});
my $requete1 = qq(SELECT COUNT(*)  FROM reservation WHERE hotel = '$h');
my $requete2 = qq(SELECT COUNT(*)  FROM reservation WHERE hotel = '$h' AND to_date(debutresa,'DD/MM/YYYY') <='$today' AND to_date(finresa,'DD/MM/YYYY') >= '$weekEarly');
my $prep1 = $dbh->prepare($requete1);
my $prep2 = $dbh->prepare($requete2);
$prep1->execute;
    #or die 'Impossible d\'exécuter la requête : '.$prep->errstr;
while (my($lineCount) = $prep1->fetchrow_array ) {
    $prep2->execute;
        #or die 'Impossible d\'exécuter la requête : '.$prep->errstr;
    while (my($dateCount) = $prep2->fetchrow_array ) {
        my $taux = ($dateCount / $lineCount)*100;
        print "$h -> $taux%\n";
        #  print "Le gerant de l'hotel $hotel est monsieur $gerant\n";
        }
    }
}

taux_occupation("Bordeaux");
taux_occupation("Bruges");
taux_occupation("Talence");
taux_occupation("Cauderan");
taux_occupation("Pessac");

