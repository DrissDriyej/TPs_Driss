-- Exercice 4.1: Création dynamique de tables

-- Création de la table Softs
CREATE TABLE Softs AS
SELECT nomLog AS nomSoft, version, prix
FROM Logiciel;

-- Création de la table PCSeuls
CREATE TABLE PCSeuls AS
SELECT nPoste AS nP, nomPoste AS nomP, indIP AS seg, ad, typePoste AS typeP, nSalle AS salle
FROM Poste
WHERE typePoste = 'PCWS' OR typePoste = 'PCNT';

-- Vérification
SELECT * FROM Softs;
SELECT * FROM PCSeuls; 