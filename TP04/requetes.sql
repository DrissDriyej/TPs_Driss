-- Exercice 4.2: Requêtes monotables

-- 1. Type du poste 'p8'
SELECT typePoste
FROM Poste
WHERE nPoste = 'p8';

-- 2. Noms des logiciels 'UNIX'
SELECT nomLog
FROM Logiciel
WHERE typeLog = 'UNIX';

-- 3. Noms, adresses IP, numéros de salle des postes de type 'UNIX' ou 'PCWS'
SELECT nomPoste, indIP, nSalle
FROM Poste
WHERE typePoste = 'UNIX' OR typePoste = 'PCWS';
-- Alternative avec IN:
-- SELECT nomPoste, indIP, nSalle
-- FROM Poste
-- WHERE typePoste IN ('UNIX', 'PCWS');

-- 4. Même requête pour les postes du segment '130.120.80' triés par numéros de salles décroissants
SELECT nomPoste, indIP, nSalle
FROM Poste
WHERE indIP = '130.120.80'
ORDER BY nSalle DESC;

-- 5. Numéros des logiciels installés sur le poste 'p6'
SELECT nLog
FROM Installer
WHERE nPoste = 'p6';

-- 6. Numéros des postes qui hébergent le logiciel 'log1'
SELECT nPoste
FROM Installer
WHERE nLog = 'log1';

-- 7. Noms et adresses IP complètes (ex : '130.120.80.01') des postes de type 'TX' (utiliser la fonction de concaténation)
SELECT nomPoste, CONCAT(indIP, '.', ad) AS ipComplete
FROM Poste
WHERE typePoste = 'TX';


-- Exercice 4.3: Fonctions et groupements

-- 8. Pour chaque poste, le nombre de logiciels installés (en utilisant la table Installer)
SELECT nPoste, COUNT(nLog) AS nombreLogicielsInstalles
FROM Installer
GROUP BY nPoste;

-- 9. Pour chaque salle, le nombre de postes (à partir de la table Poste)
SELECT nSalle, COUNT(nPoste) AS nombrePostes
FROM Poste
GROUP BY nSalle;

-- 10. Pour chaque logiciel, le nombre d'installations sur des postes différents
SELECT nLog, COUNT(DISTINCT nPoste) AS nombreInstallationsDistinctesSurPostes
FROM Installer
GROUP BY nLog;

-- 11. Moyenne des prix des logiciels 'UNIX'
SELECT AVG(prix) AS moyennePrixUnix
FROM Logiciel
WHERE typeLog = 'UNIX';

-- 12. Plus récente date d'achat d'un logiciel
SELECT MAX(dateAch) AS dateAchatPlusRecente
FROM Logiciel;

-- 13. Numéros des postes hébergeant 2 logiciels
SELECT nPoste
FROM Installer
GROUP BY nPoste
HAVING COUNT(nLog) = 2;

-- 14. Nombre de postes hébergeant 2 logiciels (utiliser la requête précédente en faisant un SELECT dans la clause FROM)
SELECT COUNT(*) AS nombrePostesAvec2Logiciels
FROM (
    SELECT nPoste
    FROM Installer
    GROUP BY nPoste
    HAVING COUNT(nLog) = 2
) AS PostesAvec2Logiciels;


-- Exercice 4.4: Requêtes multitables

-- Opérateurs ensemblistes

-- 15. Types de postes non recensés dans le parc informatique (utiliser la table Types)
--    (Ceci suppose qu'on cherche les types DANS LA TABLE TYPES qui ne sont PAS UTILISES dans la table Poste)
SELECT T.typeLP, T.nomType
FROM Types T
LEFT JOIN Poste P ON T.typeLP = P.typePoste
WHERE P.typePoste IS NULL;
-- Ou avec NOT EXISTS / NOT IN si l'on veut être plus direct :
-- SELECT typeLP, nomType
-- FROM Types
-- WHERE typeLP NOT IN (SELECT DISTINCT typePoste FROM Poste WHERE typePoste IS NOT NULL);


-- 16. Types existant à la fois comme types de postes et de logiciels
SELECT typeLP FROM Types WHERE typeLP IN (SELECT DISTINCT typePoste FROM Poste WHERE typePoste IS NOT NULL)
INTERSECT
SELECT typeLP FROM Types WHERE typeLP IN (SELECT DISTINCT typeLog FROM Logiciel WHERE typeLog IS NOT NULL);
-- Note: MySQL ne supporte pas INTERSECT directement avant la version 8.0.1.
-- Alternative pour MySQL < 8.0.1 (ou plus portable):
-- SELECT DISTINCT T1.typeLP
-- FROM Types T1
-- WHERE T1.typeLP IN (SELECT DISTINCT typePoste FROM Poste WHERE typePoste IS NOT NULL)
--   AND T1.typeLP IN (SELECT DISTINCT typeLog FROM Logiciel WHERE typeLog IS NOT NULL);
-- Ou avec des jointures :
-- SELECT DISTINCT P.typePoste
-- FROM Poste P
-- JOIN Logiciel L ON P.typePoste = L.typeLog
-- WHERE P.typePoste IS NOT NULL; -- Assure que le type existe dans Poste et est aussi dans Logiciel


-- 17. Types de postes de travail n'étant pas des types de logiciels
SELECT DISTINCT typePoste
FROM Poste
WHERE typePoste IS NOT NULL AND typePoste NOT IN (SELECT DISTINCT typeLog FROM Logiciel WHERE typeLog IS NOT NULL);
-- Note: Exclut les types de poste qui sont aussi des types de logiciel.


-- Jointures procédurales (style Oracle plus ancien, ou formulation par étapes logiques)
-- Ces requêtes sont généralement écrites avec des jointures explicites (relationnelles ou SQL2) en SQL moderne.
-- Je vais les traduire en jointures SQL standard.

-- 18. Adresses IP complètes des postes qui hébergent le logiciel 'log6'
SELECT CONCAT(P.indIP, '.', P.ad) AS ipComplete
FROM Poste P, Installer I
WHERE P.nPoste = I.nPoste
  AND I.nLog = 'log6';

-- 19. Adresses IP complètes des postes qui hébergent le logiciel de nom 'Oracle 8'
SELECT CONCAT(P.indIP, '.', P.ad) AS ipComplete
FROM Poste P, Installer I, Logiciel L
WHERE P.nPoste = I.nPoste
  AND I.nLog = L.nLog
  AND L.nomLog = 'Oracle 8';

-- 20. Noms des segments possédant exactement trois postes de travail de type 'TX'
SELECT S.nomSegment
FROM Segment S, Poste P
WHERE S.indIP = P.indIP
  AND P.typePoste = 'TX'
GROUP BY S.indIP, S.nomSegment -- indIP est PK de Segment donc nomSegment est fonctionnellement dépendant
HAVING COUNT(P.nPoste) = 3;

-- 21. Noms des salles ou l'on peut trouver au moins un poste hébergeant le logiciel 'Oracle 6'
SELECT DISTINCT Sa.nomSalle
FROM Salle Sa, Poste P, Installer I, Logiciel L
WHERE Sa.nSalle = P.nSalle
  AND P.nPoste = I.nPoste
  AND I.nLog = L.nLog
  AND L.nomLog = 'Oracle 6';

-- 22. Nom du logiciel acheté le plus récent (utiliser la requête 12)
SELECT nomLog
FROM Logiciel
WHERE dateAch = (SELECT MAX(dateAch) FROM Logiciel);
-- Si plusieurs logiciels partagent la date la plus récente, cette requête les listera tous.


-- Jointures relationnelles (réécriture des 18, 19, 20, 21)

-- 23. (Réécriture de 18) Adresses IP complètes des postes qui hébergent le logiciel 'log6'
SELECT CONCAT(Poste.indIP, '.', Poste.ad) AS ipComplete
FROM Poste
JOIN Installer ON Poste.nPoste = Installer.nPoste
WHERE Installer.nLog = 'log6';

-- 24. (Réécriture de 19) Adresses IP complètes des postes qui hébergent le logiciel de nom 'Oracle 8'
SELECT CONCAT(Poste.indIP, '.', Poste.ad) AS ipComplete
FROM Poste
JOIN Installer ON Poste.nPoste = Installer.nPoste
JOIN Logiciel ON Installer.nLog = Logiciel.nLog
WHERE Logiciel.nomLog = 'Oracle 8';

-- 25. (Réécriture de 20) Noms des segments possédant exactement trois postes de travail de type 'TX'
SELECT Segment.nomSegment
FROM Segment
JOIN Poste ON Segment.indIP = Poste.indIP
WHERE Poste.typePoste = 'TX'
GROUP BY Segment.indIP, Segment.nomSegment
HAVING COUNT(Poste.nPoste) = 3;

-- 26. (Réécriture de 21) Noms des salles ou l'on peut trouver au moins un poste hébergeant le logiciel 'Oracle 6'
SELECT DISTINCT Salle.nomSalle
FROM Salle
JOIN Poste ON Salle.nSalle = Poste.nSalle
JOIN Installer ON Poste.nPoste = Installer.nPoste
JOIN Logiciel ON Installer.nLog = Logiciel.nLog
WHERE Logiciel.nomLog = 'Oracle 6';

-- 27. Installations (nom segment, nom salle, adresse IP complète, nom logiciel, date d'installation) triées par segment, salle et adresse IP.
SELECT
    S.nomSegment,
    Sa.nomSalle,
    CONCAT(P.indIP, '.', P.ad) AS ipCompletePoste,
    L.nomLog AS nomLogiciel,
    I.dateIns AS dateInstallation
FROM Segment S
JOIN Poste P ON S.indIP = P.indIP
JOIN Salle Sa ON P.nSalle = Sa.nSalle
JOIN Installer I ON P.nPoste = I.nPoste
JOIN Logiciel L ON I.nLog = L.nLog
ORDER BY S.nomSegment, Sa.nomSalle, ipCompletePoste;


-- Jointures SQL2 (réécriture des 18, 19, 20, 21 avec JOIN, NATURAL JOIN, JOIN USING si applicable)
-- NATURAL JOIN est souvent déconseillé car il se base sur des noms de colonnes identiques, ce qui peut être fragile.
-- JOIN USING est plus sûr si les colonnes de jointure ont le même nom.

-- 28. (Réécriture de 18 avec JOIN USING)
SELECT CONCAT(P.indIP, '.', P.ad) AS ipComplete
FROM Poste P
JOIN Installer I USING (nPoste) -- si nPoste est la seule colonne commune ou celle qu'on veut utiliser
WHERE I.nLog = 'log6';

-- 29. (Réécriture de 19 avec JOIN USING)
SELECT CONCAT(P.indIP, '.', P.ad) AS ipComplete
FROM Poste P
JOIN Installer I USING (nPoste)
JOIN Logiciel L USING (nLog)
WHERE L.nomLog = 'Oracle 8';

-- 30. (Réécriture de 20 avec JOIN USING)
SELECT S.nomSegment
FROM Segment S
JOIN Poste P USING (indIP) -- indIP est la colonne de jointure
WHERE P.typePoste = 'TX'
GROUP BY S.indIP, S.nomSegment
HAVING COUNT(P.nPoste) = 3;

-- 31. (Réécriture de 21 avec JOIN USING)
SELECT DISTINCT Sa.nomSalle
FROM Salle Sa
JOIN Poste P USING (nSalle)
JOIN Installer I USING (nPoste)
JOIN Logiciel L USING (nLog)
WHERE L.nomLog = 'Oracle 6';


-- Exercice 4.6: Opérateurs existentiels

-- Sous-interrogation synchronisée

-- 32. Noms des postes ayant au moins un logiciel commun au poste 'p6' (on doit trouver les postes p2, p8 et p10).
--     (Un poste X a un logiciel commun avec 'p6' s'il existe un logiciel L tel que X a L ET p6 a L)
SELECT DISTINCT I1.nPoste
FROM Installer I1
WHERE I1.nPoste <> 'p6' -- On ne veut pas p6 lui-même
  AND EXISTS (
    SELECT I2.nLog
    FROM Installer I2
    WHERE I2.nPoste = 'p6'
      AND I2.nLog = I1.nLog -- Le logiciel commun
  );

-- Divisions

-- 33. Noms des postes ayant les mêmes logiciels que le poste 'p6'
--     (les postes peuvent avoir plus de logiciels que 'p6'). (division inexacte)
--     Un poste P a "au moins" tous les logiciels de p6.
--     Pour tout logiciel L installé sur p6, L doit aussi être installé sur P.
SELECT DISTINCT P.nPoste
FROM Poste P
WHERE NOT EXISTS ( -- Il n'existe aucun logiciel...
    SELECT LogP6.nLog
    FROM Installer LogP6
    WHERE LogP6.nPoste = 'p6' -- ...installé sur p6...
    AND NOT EXISTS ( -- ...qui ne soit PAS installé sur P
        SELECT LogP.nLog
        FROM Installer LogP
        WHERE LogP.nPoste = P.nPoste
          AND LogP.nLog = LogP6.nLog
    )
)
AND P.nPoste <> 'p6'; -- Optionnel: exclure p6 lui-même si la question l'implique


-- 34. Noms des postes ayant exactement les mêmes logiciels que le poste 'p2' (division exacte)
--     Un poste P a "exactement" les mêmes logiciels que p2.
--     Condition 1: P a au moins tous les logiciels de p2 (comme ci-dessus)
--     Condition 2: p2 a au moins tous les logiciels de P (symétrique)
--     OU Condition 1 ET COUNT(logiciels de P) = COUNT(logiciels de p2)
SELECT P.nPoste
FROM Poste P
WHERE P.nPoste <> 'p2' -- Exclure p2 lui-même
  -- Condition 1: P contient tous les logiciels de p2
  AND NOT EXISTS (
    SELECT LogP2.nLog
    FROM Installer LogP2
    WHERE LogP2.nPoste = 'p2'
    AND NOT EXISTS (
        SELECT LogP.nLog
        FROM Installer LogP
        WHERE LogP.nPoste = P.nPoste
          AND LogP.nLog = LogP2.nLog
    )
  )
  -- Condition 2: p2 contient tous les logiciels de P
  AND NOT EXISTS (
    SELECT LogP.nLog
    FROM Installer LogP
    WHERE LogP.nPoste = P.nPoste
    AND NOT EXISTS (
        SELECT LogP2.nLog
        FROM Installer LogP2
        WHERE LogP2.nPoste = 'p2'
          AND LogP2.nLog = LogP.nLog
    )
  );
-- Alternative pour la division exacte, souvent plus simple si les comptes correspondent :
-- SELECT P.nPoste
-- FROM Poste P
-- JOIN Installer I_P ON P.nPoste = I_P.nPoste
-- WHERE P.nPoste <> 'p2'
-- GROUP BY P.nPoste
-- HAVING COUNT(DISTINCT I_P.nLog) = (SELECT COUNT(DISTINCT nLog) FROM Installer WHERE nPoste = 'p2') -- Même nombre de logiciels
-- AND NOT EXISTS ( -- P contient tous les logiciels de p2
--    SELECT LogP2.nLog FROM Installer LogP2 WHERE LogP2.nPoste = 'p2'
--    AND LogP2.nLog NOT IN (SELECT nLog FROM Installer WHERE nPoste = P.nPoste)
-- );
-- La formulation avec double NOT EXISTS est la définition formelle de la division.
-- Pour la division exacte, s'assurer que P contient tous les logiciels de P2 ET que P2 contient tous les logiciels de P
-- est équivalent à: P contient tous les logiciels de P2 ET le nombre de logiciels distincts de P est égal au nombre de logiciels distincts de P2.

-- Réponse pour 34 (selon l'énoncé "on doit trouver p8") :
-- Les données pour p2 : log1, log2 (2 logiciels)
-- Les données pour p8 : log2, log6 (2 logiciels)
-- Celles-ci ne sont PAS "exactement les mêmes". Il y a une erreur dans l'attendu de l'énoncé ou dans les données.
-- Si on cherche les postes ayant EXACTEMENT les mêmes logiciels que p2, aucun autre poste ne correspond dans les données fournies.
-- Si la question était "Noms des postes ayant le MÊME NOMBRE de logiciels que 'p2' ET AU MOINS UN logiciel commun", la réponse serait différente.

-- En se basant sur le fait que "on doit trouver p8" pour la question 34 avec p2.
-- Logiciels de p2: {log1, log2}
-- Logiciels de p8: {log2, log6}
-- Celles-ci ne sont pas exactement les mêmes.
-- Revoyons les données de l'énoncé du TP2 pour p2 et p8 :
-- p2: log1, log2
-- p8: log2, log6
-- L'attendu "p8" pour la division exacte avec p2 est incorrect si les données sont celles du TP2.
-- Je vais fournir la requête pour la division exacte standard.
-- Si "exactement les mêmes" signifie "même ensemble de logiciels", alors ma double négation est correcte.
-- Si le résultat attendu 'p8' est correct, la définition de "exactement les mêmes" est autre chose, peut-être une erreur dans l'énoncé.
-- Par exemple, si l'énoncé pour la division exacte avec 'p2' voulait dire,
-- "les postes qui ont tous les logiciels de 'p2' et dont tous les logiciels sont aussi sur 'p2'", c'est la définition standard.
-- Si p2 : log1, log2
-- Si p8 : log1, log2
-- Alors p8 aurait exactement les mêmes.
-- Si p8 : log1, log2, log3 -- alors p8 n'a pas exactement les mêmes (plus de logiciels)
-- Si p8 : log1 -- alors p8 n'a pas exactement les mêmes (moins de logiciels)

-- Je maintiens la requête standard de la division exacte. 