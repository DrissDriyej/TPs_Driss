-- Modification de la colonne etage dans la table Segment
UPDATE Segment
SET etage = 0
WHERE indIP = '130.120.80';

UPDATE Segment
SET etage = 1
WHERE indIP = '130.120.81';

UPDATE Segment
SET etage = 2
WHERE indIP = '130.120.82';

-- Diminution de 10% du prix des logiciels de type 'PCNT'
UPDATE Logiciel
SET prix = prix * 0.90
WHERE typeLog = 'PCNT';

-- Vérification
SELECT * FROM Segment;
SELECT nLog, typeLog, prix FROM Logiciel; 