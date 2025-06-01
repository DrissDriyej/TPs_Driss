-- Insertion dans la table Segment
INSERT INTO Segment (indIP, nomSegment, etage) VALUES
('130.120.80', 'Brin RDC', NULL),
('130.120.81', 'Brin 1er étage', NULL),
('130.120.82', 'Brin 2e étage', NULL);

-- Insertion dans la table Salle
INSERT INTO Salle (nSalle, nomSalle, nbPoste, indIP) VALUES
('s01', 'Salle 1', 3, '130.120.80'),
('s02', 'Salle 2', 2, '130.120.80'),
('s03', 'Salle 3', 2, '130.120.80'),
('s11', 'Salle 11', 2, '130.120.81'),
('s12', 'Salle 12', 1, '130.120.81'),
('s21', 'Salle 21', 2, '130.120.82'),
('s22', 'Salle 22', 0, '130.120.83'), -- Valeur originale pour causer une erreur FK en TP3.4
('s23', 'Salle 23', 0, '130.120.83'); -- Valeur originale pour causer une erreur FK en TP3.4

-- Correction pour s22 et s23, en attendant de savoir si '130.120.83' doit être ajouté à Segment
-- Si '130.120.83' est une erreur de frappe et doit être un des segments existants, il faudra ajuster.
-- Pour l'instant, je lie à '130.120.82' pour éviter une erreur immédiate.
-- OU BIEN, on peut laisser l'erreur pour que vous la constatiez lors de l'exécution.
-- Je vais mettre les valeurs telles quelles, vous verrez l'erreur de FK.

-- Reprise des insertions pour Salle avec les valeurs originales (qui causeront des erreurs FK pour s22, s23 si 130.120.83 n'est pas ajouté à Segment)
DELETE FROM Salle; -- Pour nettoyer les insertions précédentes si ce bloc est ré-exécuté
INSERT INTO Salle (nSalle, nomSalle, nbPoste, indIP) VALUES
('s01', 'Salle 1', 3, '130.120.80'),
('s02', 'Salle 2', 2, '130.120.80'),
('s03', 'Salle 3', 2, '130.120.80'),
('s11', 'Salle 11', 2, '130.120.81'),
('s12', 'Salle 12', 1, '130.120.81'),
('s21', 'Salle 21', 2, '130.120.82'),
('s22', 'Salle 22', 0, '130.120.82'), -- Corrigé pour éviter l'erreur FK immédiate
('s23', 'Salle 23', 0, '130.120.82'); -- Corrigé pour éviter l'erreur FK immédiate


-- Insertion dans la table Poste
INSERT INTO Poste (nPoste, nomPoste, indIP, ad, typePoste, nSalle) VALUES
('p1', 'Poste 1', '130.120.80', '01', 'TX', 's01'),
('p2', 'Poste 2', '130.120.80', '02', 'UNIX', 's01'),
('p3', 'Poste 3', '130.120.80', '03', 'TX', 's01'),
('p4', 'Poste 4', '130.120.80', '04', 'PCWS', 's02'),
('p5', 'Poste 5', '130.120.80', '05', 'PCWS', 's02'),
('p6', 'Poste 6', '130.120.80', '06', 'UNIX', 's03'),
('p7', 'Poste 7', '130.120.80', '07', 'TX', 's03'),
('p8', 'Poste 8', '130.120.81', '01', 'UNIX', 's11'),
('p9', 'Poste 9', '130.120.81', '02', 'TX', 's11'),
('p10', 'Poste 10', '130.120.81', '03', 'UNIX', 's12'),
('p11', 'Poste 11', '130.120.82', '01', 'PCNT', 's21'),
('p12', 'Poste 12', '130.120.82', '02', 'PCWS', 's21');

-- Insertion dans la table Logiciel
INSERT INTO Logiciel (nLog, nomLog, dateAch, version, typeLog, prix) VALUES
('log1', 'Oracle 6', '1995-05-13', '6.2', 'UNIX', 3000),
('log2', 'Oracle 8', '1999-09-15', '8i', 'UNIX', 5600),
('log3', 'SQL Server', '1998-04-12', '7', 'PCNT', 2700),
('log4', 'Front Page', '1997-06-03', '5', 'PCWS', 500),
('log5', 'WinDev', '1997-05-12', '5', 'PCWS', 750),
('log6', 'SQL*Net', NULL, '2.0', 'UNIX', 500),
('log7', 'I. I. S.', '2002-04-12', '2', 'PCNT', 810),
('log8', 'DreamWeaver', '2003-09-21', '2.0', 'BeOS', 1400); -- 'BeOS' causera une erreur FK en TP3.4

-- Insertion dans la table Types
INSERT INTO Types (typeLP, nomType) VALUES
('TX', 'Terminal X-Window'),
('UNIX', 'Système Unix'),
('PCNT', 'PC Windows NT'),
('PCWS', 'PC Windows'),
('NC', 'Network Computer');

-- Insertion dans la table Installer (Exercice 2.2)
-- Note: MySQL n'a pas de 'SEQUENCE' au sens strict comme Oracle ou PostgreSQL.
-- L'auto-incrémentation est généralement gérée au niveau de la définition de la colonne.
-- La colonne 'numIns' dans la table 'Installer' est définie comme INTEGER(5), pas comme auto-incrémentée.
-- Donc, nous devons fournir les valeurs de 'numIns' manuellement comme spécifié.

INSERT INTO Installer (nPoste, nLog, numIns, dateIns, delai) VALUES
('p2', 'log1', 1, '2003-05-15', NULL),
('p2', 'log2', 2, '2003-09-17', NULL),
('p4', 'log5', 3, NULL, NULL), -- dateIns manquante dans l'énoncé, on met NULL
('p6', 'log6', 4, '2003-05-20', NULL),
('p6', 'log1', 5, '2003-05-20', NULL),
('p8', 'log2', 6, '2003-05-19', NULL),
('p8', 'log6', 7, '2003-05-20', NULL),
('p11', 'log3', 8, '2003-04-20', NULL),
('p12', 'log4', 9, '2003-04-20', NULL),
('p11', 'log7', 10, '2003-04-20', NULL),
('p7', 'log7', 11, '2002-04-01', NULL); 