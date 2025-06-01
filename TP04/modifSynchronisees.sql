-- Exercice 4.5: Modifications synchronisées

-- Ajout des lignes dans la table Installer
-- Note: 'sequence' pour numIns n'est pas un mot-clé direct en MySQL pour l'insertion.
-- numIns est une colonne INTEGER, pas auto-incrémentée par une séquence de base de données dans la définition de la table.
-- Il faut soit fournir une valeur explicite, soit si on veut simuler une séquence, on pourrait
-- la calculer par MAX(numIns) + 1 pour un (nPoste, nLog) donné si c'est le sens, ou globalement.
-- L'énoncé du TP2 a fourni des valeurs explicites pour numIns.
-- Pour cet exercice, je vais supposer qu'il faut trouver la prochaine valeur de numIns disponible globalement ou par groupe.
-- Étant donné que numIns fait partie de la clé primaire (nPoste, nLog, numIns), la valeur doit être unique pour chaque combinaison.
-- Je vais utiliser des valeurs fixes pour numIns qui sont supposées être uniques et séquentielles pour les besoins de l'exercice, en partant de la suite de l'énoncé du TP2.
-- Le dernier numIns dans TP2 était 11. Je vais donc utiliser 12, 13, 14.
-- SYSDATE() en MySQL est un alias pour NOW().

INSERT INTO Installer (nPoste, nLog, numIns, dateIns, delai) VALUES
('p2', 'log6', 12, NOW(), NULL),
('p8', 'log1', 13, NOW(), NULL),
('p10', 'log1', 14, NOW(), NULL);

-- Vérification des ajouts
SELECT * FROM Installer WHERE numIns >= 12;


-- Mettre à jour automatiquement les colonnes rajoutées (nbSalle, nbPoste dans Segment, nbInstall dans Logiciel, nbLog dans Poste)

-- 1. nbSalle dans la table Segment (nombre de salles traversées par le segment)
UPDATE Segment s
SET s.nbSalle = (SELECT COUNT(sa.nSalle) FROM Salle sa WHERE sa.indIP = s.indIP);

-- 2. nbPoste dans la table Segment (nombre de postes du segment)
UPDATE Segment s
SET s.nbPoste = (SELECT COUNT(p.nPoste) FROM Poste p WHERE p.indIP = s.indIP);

-- 3. nbInstall dans la table Logiciel (nombre d'installations du logiciel)
UPDATE Logiciel l
SET l.nbInstall = (SELECT COUNT(i.nPoste) FROM Installer i WHERE i.nLog = l.nLog); -- Compte le nombre d'installations (peut être plusieurs sur le même poste si numIns différent)
-- Si on veut le nombre de postes *distincts* sur lesquels le logiciel est installé:
-- UPDATE Logiciel l
-- SET l.nbInstall = (SELECT COUNT(DISTINCT i.nPoste) FROM Installer i WHERE i.nLog = l.nLog);
-- L'énoncé (Figure 3-5) pour la création de la colonne nbInstall dans Logiciel dit "nombre d'installations par défaut = 0".
-- Cela suggère le nombre total d'installations.

-- 4. nbLog dans la table Poste (nombre de logiciels installés par poste)
UPDATE Poste p
SET p.nbLog = (SELECT COUNT(i.nLog) FROM Installer i WHERE i.nPoste = p.nPoste);
-- Si on veut le nombre de logiciels *distincts* installés sur le poste:
-- UPDATE Poste p
-- SET p.nbLog = (SELECT COUNT(DISTINCT i.nLog) FROM Installer i WHERE i.nPoste = p.nPoste);
-- L'énoncé (Figure 3-5) pour la création de la colonne nbLog dans Poste dit "nombre de logiciels installés par défaut = 0".
-- Cela suggère le nombre total (ou distinct) de logiciels.
-- Généralement, on compte les logiciels distincts par poste.
-- Je vais utiliser COUNT(DISTINCT i.nLog) pour nbLog dans Poste.
UPDATE Poste p
SET p.nbLog = (SELECT COUNT(DISTINCT i.nLog) FROM Installer i WHERE i.nPoste = p.nPoste);


-- Vérifier le contenu des tables modifiées (Segment, Logiciel et Poste)
SELECT * FROM Segment;
SELECT nLog, nomLog, nbInstall FROM Logiciel;
SELECT nPoste, nomPoste, nbLog FROM Poste; 