-- Test comparatif entre Perl et SQL 

-- ============ Nombre de chambre par hôtel================
SELECT Hotel,COUNT(NumChambre)
FROM Chambre
GROUP BY Hotel

-- ============ Nombre de réservation par hôtel ===========
SELECT Hotel,COUNT(NumResa)
FROM Reservation
GROUP BY Hotel
