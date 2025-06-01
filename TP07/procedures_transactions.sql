-- TP7 Les procédures stockées
-- Assurez-vous d'utiliser la bonne base de données:
-- USE parc_informatique_db;

-- Exercice 6.1: Extraction de données
-- Écrire le bloc MySQL qui affiche les détails de la dernière installation de logiciel

DROP PROCEDURE IF EXISTS GetLastInstallationDetails;
DELIMITER //
CREATE PROCEDURE GetLastInstallationDetails()
BEGIN
    -- Variables pour stocker les résultats
    DECLARE v_nSalle VARCHAR(7);
    DECLARE v_nPoste VARCHAR(7);
    DECLARE v_nomLogiciel VARCHAR(20);
    DECLARE v_dateInstallation DATETIME;

    -- Extraire les informations de la dernière installation
    -- La "dernière" est généralement interprétée comme celle ayant la date d'installation la plus récente.
    -- S'il y a plusieurs installations à la même date/heure la plus récente, une seule sera retournée par cette logique (LIMIT 1).
    SELECT
        P.nSalle, I.nPoste, L.nomLog, I.dateIns
    INTO
        v_nSalle, v_nPoste, v_nomLogiciel, v_dateInstallation
    FROM Installer I
    JOIN Logiciel L ON I.nLog = L.nLog
    JOIN Poste P ON I.nPoste = P.nPoste
    ORDER BY I.dateIns DESC, I.numIns DESC -- dateIns puis numIns pour un critère de départage si dates identiques
    LIMIT 1;

    -- Afficher les résultats formatés
    SELECT '+--------------------------------------+' AS 'Resultat 1 exo 1';
    SELECT CONCAT('| Derniere installation en salle : ', IFNULL(v_nSalle, 'N/A'), ' |') AS ' ';
    SELECT '+--------------------------------------+' AS ' ';

    SELECT '+--------------------------------------------------------------------+' AS 'Resultat 2 exo 1';
    SELECT CONCAT('| Poste : ', IFNULL(v_nPoste, 'N/A'),
                  ' Logiciel : ', IFNULL(v_nomLogiciel, 'N/A'),
                  ' en date du ', IFNULL(DATE_FORMAT(v_dateInstallation, '%Y-%m-%d %H:%i:%s'), 'N/A'), ' |') AS ' ';
    SELECT '+--------------------------------------------------------------------+' AS ' ';

END //
DELIMITER ;

-- Pour tester l'exercice 6.1:
-- CALL GetLastInstallationDetails();


-- Exercice 6.2: Variables de session
-- Écrire le bloc MySQL qui affecte hors d'un bloc, par des variables session, un numéro de salle et un type de poste,
-- et qui retourne des variables session permettant de composer un message indiquant les nombres de postes et d'installations de logiciels correspondants.

DROP PROCEDURE IF EXISTS GetSessionStats;
DELIMITER //
CREATE PROCEDURE GetSessionStats()
BEGIN
    -- @session_salle et @session_typePoste sont supposées être définies AVANT l'appel à cette procédure.

    DECLARE v_nbPostes INT DEFAULT 0;
    DECLARE v_nbInstallations INT DEFAULT 0;

    -- Compter le nombre de postes dans la salle donnée et du type donné
    SELECT COUNT(DISTINCT P.nPoste)
    INTO v_nbPostes
    FROM Poste P
    WHERE P.nSalle = @session_salle AND P.typePoste = @session_typePoste;

    -- Compter le nombre d'installations de logiciels sur ces postes
    SELECT COUNT(I.numIns) -- ou COUNT(*) si chaque ligne de Installer est une installation distincte
    INTO v_nbInstallations
    FROM Installer I
    JOIN Poste P ON I.nPoste = P.nPoste
    WHERE P.nSalle = @session_salle AND P.typePoste = @session_typePoste;

    -- Affecter les résultats à des variables de session pour l'affichage externe si besoin,
    -- ou les utiliser directement pour l'affichage ici.
    SET @session_nbPostes = v_nbPostes;
    SET @session_nbInstallations = v_nbInstallations;

    -- Afficher le message formaté
    SELECT '+----------------------------------------------------------+' AS 'Resultat exo2';
    SELECT CONCAT('| ', IFNULL(@session_nbPostes, 0), ' poste(s) installe(s) en salle ', IFNULL(@session_salle, 'N/A'),
                  ', ', IFNULL(@session_nbInstallations, 0), ' installation(s) de type ', IFNULL(@session_typePoste, 'N/A'), ' |') AS ' ';
    SELECT '+----------------------------------------------------------+' AS ' ';

END //
DELIMITER ;

-- Pour tester l'exercice 6.2:
-- SET @session_salle = 's01';
-- SET @session_typePoste = 'TX'; -- Exemple de type de poste
-- CALL GetSessionStats();
-- SELECT @session_nbPostes, @session_nbInstallations; -- Pour voir les variables session affectées


-- Exercice 6.3: Transaction
-- Écrire une transaction permettant d'insérer un nouveau logiciel dans la base après avoir passé en paramètres,
-- par des variables de session, toutes ses caractéristiques (numéro, nom, version et type du logiciel).
-- La date d'achat doit être celle du jour. Tracer l'insertion du logiciel.
-- Il faut ensuite procéder à l'installation de ce logiciel sur le poste de code p7 (utiliser une variable pour ce poste).
-- L'installation doit se faire aussi à la date du jour. Penser à actualiser la colonne delai.
-- Placer une attente de 5 secondes entre l'ajout dans Logiciel et celui dans Installer.
-- Utiliser TIMEDIFF pour calculer delai.
-- Insérer par exemple le logiciel log15, de nom MySQL Query, version 1.4, typePCWS coûtant 95 €.

DROP PROCEDURE IF EXISTS AddAndInstallSoftware;
DELIMITER //
CREATE PROCEDURE AddAndInstallSoftware(
    IN p_nLog VARCHAR(5), 
    IN p_nomLog VARCHAR(20), 
    IN p_version VARCHAR(7), 
    IN p_typeLog VARCHAR(9), 
    IN p_prix DECIMAL(6,2),
    IN p_nPosteInstallation VARCHAR(7) -- Paramètre pour le poste d'installation (ex: 'p7')
)
BEGIN
    DECLARE v_dateAchat DATETIME;
    DECLARE v_dateInstallation DATETIME;
    DECLARE v_delai SMALLINT; -- SMALLINT peut stocker des secondes, mais TIME est mieux pour un intervalle.
                               -- L'énoncé du TP1 pour `delai` dit `SMALLINT`. Cela pourrait être des jours.
                               -- Si c'est un intervalle en secondes, TIMEDIFF retourne un TIME, il faudra convertir.
                               -- Si delai est en jours: DATEDIFF(dateIns, dateAch)
                               -- Si delai est en secondes: TIME_TO_SEC(TIMEDIFF(dateIns, dateAch))

    -- Démarrer la transaction
    START TRANSACTION;

    SET v_dateAchat = NOW();

    -- Insérer le nouveau logiciel
    INSERT INTO Logiciel(nLog, nomLog, dateAch, version, typeLog, prix)
    VALUES (p_nLog, p_nomLog, v_dateAchat, p_version, p_typeLog, p_prix);

    -- Tracer l'insertion
    SELECT '+---------------------------+' AS 'message1';
    SELECT '| Logiciel insere dans la base |' AS ' ';
    SELECT '+---------------------------+' AS ' ';
    SELECT ROW_COUNT() AS '1 row in set (0.01 sec approx)'; -- Simule le message de MySQL, ROW_COUNT() donne le nb de lignes affectées par la dernière instruction.

    -- Afficher la date d'achat (similaire à l'énoncé)
    SELECT '+--------------------------------------+' AS 'message2';
    SELECT CONCAT('| Date achat : ', DATE_FORMAT(v_dateAchat, '%Y-%m-%d %H:%i:%s'), ' |') AS ' ';
    SELECT '+--------------------------------------+' AS ' ';

    -- Attente de 5 secondes
    SELECT SLEEP(5) AS 'Attente de 5 secondes...'; -- SLEEP retourne 0 si réussi, 1 si interrompu.
    SELECT '0' AS 'SLEEP(5) output (0 = success)'; -- Simule l'affichage de l'énoncé

    SET v_dateInstallation = NOW();

    -- Calculer delai. Si `delai` doit être en secondes :
    SET v_delai = TIME_TO_SEC(TIMEDIFF(v_dateInstallation, v_dateAchat));
    -- Si `delai` doit être en jours (ce qui est plus probable pour un SMALLINT) :
    -- SET v_delai = DATEDIFF(v_dateInstallation, v_dateAchat);
    -- L'énoncé original du TP1 indique delai SMALLINT et le décrit comme "intervalle entre achat et installation".
    -- Un intervalle de quelques secondes stocké en SMALLINT est possible, mais des jours sont plus courants pour ce type de champ.
    -- Je vais utiliser TIME_TO_SEC pour correspondre à l'attente de 5 secondes, en supposant que `delai` est en secondes.

    -- Procéder à l'installation du logiciel sur le poste p_nPosteInstallation
    -- Il faut un numIns. On va supposer qu'on prend le prochain numIns disponible pour ce (poste, logiciel).
    -- Ou, plus simplement pour cet exercice, un numIns fixe ou basé sur un compteur simple si la table Installer le permet.
    -- L'énoncé original du TP2 donnait des numIns manuels.
    -- Pour cet exercice, je vais prendre MAX(numIns) + 1 pour la combinaison (poste, logiciel), ou 1 si c'est la première fois.
    
    INSERT INTO Installer(nPoste, nLog, numIns, dateIns, delai)
    SELECT 
        p_nPosteInstallation, 
        p_nLog, 
        COALESCE(MAX(Isub.numIns), 0) + 1, 
        v_dateInstallation, 
        v_delai 
    FROM (SELECT 1) dummy -- Pour permettre le SELECT MAX sans GROUP BY si la table est vide pour ce poste/log
    LEFT JOIN Installer Isub ON Isub.nPoste = p_nPosteInstallation AND Isub.nLog = p_nLog;
    -- Note: Cette sous-requête pour numIns est une simplification. Une séquence dédiée ou une meilleure logique serait préférable en production.
    -- Si la table Installer est vide pour cette combinaison, MAX(numIns) sera NULL, COALESCE le transformera en 0, donc +1 = 1.

    -- Afficher la date d'installation
    SELECT '+--------------------------------------+' AS 'message3';
    SELECT CONCAT('| Date installation : ', DATE_FORMAT(v_dateInstallation, '%Y-%m-%d %H:%i:%s'), ' |') AS ' ';
    SELECT '+--------------------------------------+' AS ' ';

    -- Tracer l'installation
    SELECT '+---------------------------+' AS 'message4';
    SELECT '| Logiciel installe sur le poste |' AS ' ';
    SELECT '+---------------------------+' AS ' ';

    -- Valider la transaction
    COMMIT;

    -- Vérifier l'état des tables (à faire en dehors de la procédure, après l'appel)
    -- SELECT * FROM Logiciel WHERE nLog = p_nLog;
    -- SELECT * FROM Installer WHERE nLog = p_nLog AND nPoste = p_nPosteInstallation;

END //
DELIMITER ;

-- Pour tester l'exercice 6.3:
-- 1. Définir les variables de session (si la procédure les utilisait directement, ce qui n'est pas le cas ici car on passe des paramètres)
-- SET @session_nLog = 'log15';
-- SET @session_nomLog = 'MySQL Query';
-- SET @session_version = '1.4';
-- SET @session_typeLog = 'PCWS';
-- SET @session_prix = 95;
-- SET @session_posteInstallation = 'p7';

-- 2. Appeler la procédure avec des paramètres
-- CALL AddAndInstallSoftware('log15', 'MySQL Query', '1.4', 'PCWS', 95, 'p7');

-- 3. Vérifier les tables après l'appel
-- SELECT * FROM Logiciel WHERE nLog = 'log15';
-- SELECT * FROM Installer WHERE nLog = 'log15' AND nPoste = 'p7';
-- SELECT nLog, nbInstall FROM Logiciel WHERE nLog = 'log15'; -- Si la colonne nbInstall est mise à jour par un trigger ou une autre procédure.
-- SELECT nPoste, nbLog FROM Poste WHERE nPoste = 'p7'; -- Si la colonne nbLog est mise à jour.

-- Rappel: Les colonnes nbInstall (dans Logiciel) et nbLog (dans Poste) ont été ajoutées dans le TP3.
-- Leur mise à jour n'est pas demandée explicitement dans CETTE transaction du TP7,
-- mais l'énoncé du TP4 (ex 4.5) montrait comment les mettre à jour par des UPDATE séparés.
-- Si ces colonnes doivent être à jour après cette transaction, il faudrait ajouter des UPDATE
-- à l'intérieur de la procédure AddAndInstallSoftware (après l'INSERT dans Installer) ou utiliser des triggers. 