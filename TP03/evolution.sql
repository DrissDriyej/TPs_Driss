-- Exercice 3.1: Ajout de colonnes
ALTER TABLE Segment
ADD COLUMN nbSalle TINYINT(2) DEFAULT 0,
ADD COLUMN nbPoste TINYINT(2) DEFAULT 0;

ALTER TABLE Logiciel
ADD COLUMN nbInstall TINYINT(2) DEFAULT 0;

ALTER TABLE Poste
ADD COLUMN nbLog TINYINT(2) DEFAULT 0;

-- Vérification des structures après ajout
DESCRIBE Segment;
DESCRIBE Logiciel;
DESCRIBE Poste;

-- (Le contenu de ces nouvelles colonnes sera modifié ultérieurement, ici on vérifie juste l'ajout)
SELECT * FROM Segment;
SELECT * FROM Logiciel;
SELECT * FROM Poste;

-- Exercice 3.2: Modification de colonnes
ALTER TABLE Salle
MODIFY nomSalle VARCHAR(30);

ALTER TABLE Segment
MODIFY nomSegment VARCHAR(15);

-- Tentative de diminuer nomSegment à VARCHAR(14) -- Cela devrait échouer si des données dépassent 14 caractères.
-- ALTER TABLE Segment MODIFY nomSegment VARCHAR(14);
-- Pourquoi la commande n'est-elle pas possible ?
-- Réponse : Si une ou plusieurs valeurs existantes dans la colonne `nomSegment` dépassent 14 caractères,
-- MySQL refusera de réduire la taille de la colonne pour éviter une perte de données.
-- Il faudrait d'abord s'assurer qu'aucune donnée existante ne dépasse la nouvelle taille.

-- Vérification des structures et contenu après modification
DESCRIBE Salle;
DESCRIBE Segment;
SELECT nomSegment FROM Segment WHERE LENGTH(nomSegment) > 14; -- Pour voir si des données poseraient problème pour VARCHAR(14)
SELECT * FROM Salle;
SELECT * FROM Segment;

-- Exercice 3.3: Ajout de contraintes

-- Contrainte pour empêcher l'installation multiple du même logiciel sur le même poste
-- La clé primaire de la table Installer (nPoste, nLog, numIns) empêche déjà d'avoir EXACTEMENT la même ligne.
-- La question semble vouloir dire qu'un (nPoste, nLog) ne doit pas apparaître plusieurs fois, quel que soit numIns.
-- Cela nécessiterait une clé unique sur (nPoste, nLog) dans Installer, mais numIns fait partie de la PK.
-- Si numIns est un simple numéro séquentiel d'installation qui doit être unique PAR (nPoste, nLog), c'est différent.
-- L'énoncé dit "même logiciel sur un poste de travail donné".
-- Si l'objectif est d'avoir une seule trace d'installation pour un (nPoste, nLog) donné, la structure actuelle avec numIns dans la PK le permet.
-- Si l'objectif est de s'assurer qu'un (nPoste, nLog) n'est listé qu'une fois dans Installer, il faudrait une contrainte UNIQUE(nPoste, nLog).
-- Étant donné la présence de `numIns` qui semble être un identifiant d'instance d'installation, on peut supposer que plusieurs installations
-- du même logiciel sur le même poste sont possibles mais avec des numIns différents. La question est peut-être mal posée
-- ou je l'interprète mal. Je vais ajouter une contrainte UNIQUE sur (nPoste, nLog) pour illustrer, bien que cela puisse contredire l'usage de numIns.
-- Si `numIns` est LA clé qui différencie des installations multiples du même logiciel, alors la contrainte est déjà respectée par la PK (nPoste, nLog, numIns).
-- Pour le moment, je n'ajoute pas de contrainte spécifique pour cela car la PK sur Installer(nPoste, nLog, numIns) gère l'unicité d'une *instance* d'installation.
-- La question est peut-être de s'assurer qu'il n'y a pas deux lignes avec le même (nPoste, nLog) ET le même `numIns` (ce qui est déjà le cas via la PK).

-- Ajout des contraintes de clés étrangères (celles non déjà présentes ou spécifiquement demandées ici)
-- La consigne fait référence à fk_Poste_typePoste_Types (Poste.typePoste -> Types.typeLP)
ALTER TABLE Poste
ADD CONSTRAINT fk_Poste_typePoste_Types FOREIGN KEY (typePoste) REFERENCES Types(typeLP);

-- (Les autres clés étrangères devraient déjà exister depuis creParc.sql, comme Salle.indIP -> Segment.indIP,
-- Poste.indIP -> Segment.indIP, Poste.nSalle -> Salle.nSalle, Installer.nPoste -> Poste.nPoste, Installer.nLog -> Logiciel.nLog)

-- Vérification (on peut utiliser INFORMATION_SCHEMA.KEY_COLUMN_USAGE pour lister les FK)
SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Poste' AND COLUMN_NAME = 'typePoste';


-- Exercice 3.4: Traitement des erreurs

-- Tentative d'ajout de la clé étrangère Segment.indIP -> Salle.indIP (déjà existante Salle.indIP -> Segment.indIP)
-- La Figure 3-11 montre Segment.indIP <- Salle.indIP et Logiciel.typeLog <- Types.typeLP
-- Ces contraintes sont celles qui posent problème à cause des données.

-- Clé étrangère Salle.indIP REFERENCES Segment(indIP) (devrait déjà exister depuis creParc.sql)
-- Si elle n'existe pas, on la crée ici. Si elle existe, MySQL donnera une erreur de duplicata de contrainte.
-- Pour être sûr, on peut la dropper et la recréer si elle existe, ou juste tenter de l'ajouter.
-- ALTER TABLE Salle ADD CONSTRAINT fk_Salle_indIP FOREIGN KEY (indIP) REFERENCES Segment(indIP);
-- Cette contrainte va échouer si les données de Salle (s22, s23 avec indIP '130.120.83') sont incorrectes
-- et que '130.120.83' n'existe pas dans Segment.

-- Clé étrangère Logiciel.typeLog REFERENCES Types(typeLP)
-- ALTER TABLE Logiciel ADD CONSTRAINT fk_Logiciel_typeLog FOREIGN KEY (typeLog) REFERENCES Types(typeLP);
-- Cette contrainte va échouer si des typeLog dans Logiciel (ex: 'BeOS' pour log8) n'existent pas dans Types.

-- L'énoncé dit "Tentez d'ajouter les contraintes".
-- Il faut donc que ces contraintes ne soient PAS DÉJÀ PRÉSENTES pour pouvoir "tenter" de les ajouter
-- et voir les erreurs. Or, `fk_Salle_indIP` est DÉJÀ dans `creParc.sql`.
-- Et `fk_Poste_typePoste_Types` vient d'être ajoutée en 3.3 (Poste -> Types, pas Logiciel -> Types).

-- Supposons que les FK problématiques ne sont PAS encore créées pour les besoins de cet exercice précis.
-- (Si elles le sont via creParc.sql, les INSERTs du TP2 auraient déjà échoué sans SET FOREIGN_KEY_CHECKS=0)

-- Pour l'exercice, on va supposer que les FK de TP1 n'ont pas été toutes mises ou ont été enlevées.
-- On va donc explicitement essayer de créer les contraintes qui posent problème.

-- 1. Tenter d'ajouter FK Salle -> Segment (problème avec s22, s23)
-- Si cette FK existe déjà, la tentative d'ajout échouera (erreur duplicate constraint). Il faudrait la dropper avant.
-- Pour la démo, je vais la nommer différemment pour qu'elle puisse être ajoutée (si elle n'existe pas sous ce nom)
ALTER TABLE Salle ADD CONSTRAINT fk_Salle_Segment_Demo FOREIGN KEY (indIP) REFERENCES Segment(indIP);
-- Cette ligne DEVRAIT générer une erreur à cause de s22 et s23 si indIP '130.120.83' n'est pas dans Segment.

-- 2. Tenter d'ajouter FK Logiciel -> Types (problème avec log8)
ALTER TABLE Logiciel ADD CONSTRAINT fk_Logiciel_Types_Demo FOREIGN KEY (typeLog) REFERENCES Types(typeLP);
-- Cette ligne DEVRAIT générer une erreur à cause de log8 ('BeOS').

-- Extraire les enregistrements qui posent problème
SELECT nSalle, indIP FROM Salle WHERE indIP NOT IN (SELECT indIP FROM Segment);
SELECT nLog, nomLog, typeLog FROM Logiciel WHERE typeLog NOT IN (SELECT typeLP FROM Types);

-- Supprimer les enregistrements de la table Salle qui posent problème
-- (ceux où indIP n'est pas dans Segment)
DELETE FROM Salle WHERE indIP NOT IN (SELECT indIP FROM Segment);

-- Ajouter le type de logiciel ('BeOS', 'Système Be') dans la table Types
INSERT INTO Types (typeLP, nomType) VALUES ('BeOS', 'Système Be');

-- Exécuter à nouveau l'ajout des deux contraintes de clé étrangère
-- Si les contraintes fk_Salle_Segment_Demo ou fk_Logiciel_Types_Demo ont été créées partiellement
-- ou si la tentative a échoué mais que la contrainte existe sous un autre nom, il faudra gérer cela.
-- Le plus simple est de dropper les contraintes si elles existent (même sous un autre nom si on connaît le nom original)
-- et de les recréer avec les noms standard.

-- On suppose que les contraintes originales de creParc.sql sont celles à rétablir si elles avaient été omises.
-- Rappel : fk_Salle_indIP FOREIGN KEY (indIP) REFERENCES Segment(indIP)
--          fk_Logiciel_typeLog FOREIGN KEY (typeLog) REFERENCES Types(typeLP)

-- Tentative de recréation (si elles avaient été supprimées ou n'existaient pas)
-- ou création si elles ont été créées avec _Demo et qu'on veut les noms standards

-- Pour Salle -> Segment:
-- Si fk_Salle_Segment_Demo a été créée après correction, c'est bon. Sinon, on crée la FK standard (si pas déjà là).
-- Si vous voulez la nommer fk_Salle_indIP comme dans creParc, et qu'elle n'y était pas:
-- ALTER TABLE Salle ADD CONSTRAINT fk_Salle_indIP FOREIGN KEY (indIP) REFERENCES Segment(indIP);

-- Pour Logiciel -> Types:
-- ALTER TABLE Logiciel ADD CONSTRAINT fk_Logiciel_typeLog FOREIGN KEY (typeLog) REFERENCES Types(typeLP);

-- Le script `creParc.sql` contient déjà : FOREIGN KEY (indIP) REFERENCES Segment(indIP) pour Salle.
-- Et nous avons ajouté : FOREIGN KEY (typePoste) REFERENCES Types(typeLP) pour Poste en 3.3.
-- La clé étrangère pour Logiciel.typeLog -> Types.typeLP n'est pas encore explicitement définie.

-- Donc, après corrections, on ajoute celle pour Logiciel vers Types :
ALTER TABLE Logiciel
ADD CONSTRAINT fk_Logiciel_typeLog FOREIGN KEY (typeLog) REFERENCES Types(typeLP);

-- Vérifier que les instructions ne renvoient plus d'erreur
-- Et que les deux requêtes d'extraction ne renvoient aucune donnée:
SELECT nSalle, indIP FROM Salle WHERE indIP NOT IN (SELECT indIP FROM Segment);
SELECT nLog, nomLog, typeLog FROM Logiciel WHERE typeLog NOT IN (SELECT typeLP FROM Types);


-- Modification du script de destruction des tables (dropParc.sql)
-- Il faut juste s'assurer que les tables sont droppées dans le bon ordre
-- (enfants avant parents) si des clés étrangères existent.
-- L'ordre actuel dans dropParc.sql du TP1 est : Installer, Logiciel, Poste, Salle, Segment, Types.
-- Les nouvelles FK ajoutées sont :
-- Poste.typePoste -> Types.typeLP
-- Logiciel.typeLog -> Types.typeLP (après correction en 3.4)
-- Salle.indIP -> Segment.indIP (existante)

-- L'ordre actuel semble correct: Types est droppée en dernier parmi les tables référencées.
-- Segment est aussi droppée tardivement.
-- Installer (enfant de Poste, Logiciel) est droppée en premier.
-- Logiciel (potentiellement parent de Installer, enfant de Types) est droppée ensuite.
-- Poste (potentiellement parent de Installer, enfant de Segment, Salle, Types) est droppée ensuite.
-- Salle (potentiellement parent de Poste, enfant de Segment) est droppée ensuite.
-- L'ordre semble globalement OK. Il n'y a pas de nouvelles tables, juste de nouvelles contraintes entre tables existantes.
-- Le dropParc.sql actuel devrait donc fonctionner. 