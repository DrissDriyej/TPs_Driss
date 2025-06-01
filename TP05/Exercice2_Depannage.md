## Deuxième exercice : Service de dépannage informatique

**1. Modèle Conceptuel des Données (MCD)**

*   **Identification des entités principales :**
    *   `CLIENT`: Personne faisant appel au service.
    *   `INTERVENTION`: Prestation de service réalisée.
    *   `TYPE_INTERVENTION`: Catégorise l'intervention et détermine le prix horaire.
    *   `MATERIEL_CLIENT`: Équipement du client sur lequel une intervention est faite.
    *   `COMPOSANT_CATALOGUE`: Type de pièce détachée potentiellement vendue.

*   **Attributs des entités (et identifiants notés avec (PK)) :**
    *   `CLIENT`:
        *   `idClient` (PK)
        *   `nomClient`
        *   `prenomClient`
        *   `adresseClient`
        *   `telephoneClient`
        *   `emailClient`
    *   `TYPE_INTERVENTION`:
        *   `idTypeIntervention` (PK)
        *   `libelleTypeIntervention`
        *   `prixHoraire`
    *   `MATERIEL_CLIENT`:
        *   `idMaterielClient` (PK)
        *   `typeEquipement` (ex: "PC Portable", "Tour PC")
        *   `marque`
        *   `modele`
        *   `#idClient` (FK vers CLIENT) - Un matériel appartient à un client.
    *   `INTERVENTION`:
        *   `idIntervention` (PK)
        *   `dateHeureDebut`
        *   `dateHeureFin`
        *   `descriptionProbleme`
        *   `descriptionSolution`
        *   `#idClient` (FK vers CLIENT) - Une intervention est pour un client.
        *   `#idTypeIntervention` (FK vers TYPE_INTERVENTION) - Une intervention a un type.
        *   `#idMaterielClient` (FK vers MATERIEL_CLIENT) - Une intervention concerne un matériel.
    *   `COMPOSANT_CATALOGUE`:
        *   `idComposantCatalogue` (PK)
        *   `nomComposant`
        *   `prixVenteStandard`

*   **Relations et cardinalités (notation : Entite1 (min,max) -- Relation -- (min,max) Entite2) :**
    *   `CLIENT` (0,n) -- demande -- (1,1) `INTERVENTION`
    *   `INTERVENTION` (0,n) -- est_de_type -- (1,1) `TYPE_INTERVENTION`
    *   `CLIENT` (1,1) -- possède -- (0,n) `MATERIEL_CLIENT` (Un client peut avoir 0 à N matériels, un matériel appartient à 1 client)
    *   `INTERVENTION` (0,n) -- concerne_materiel -- (1,1) `MATERIEL_CLIENT` (Une intervention concerne 1 matériel, un matériel peut avoir 0 à N interventions)

    *   La relation entre `INTERVENTION` et `COMPOSANT_CATALOGUE` (pour la vente de composants) est plusieurs-à-plusieurs. Elle est portée par une entité-association `DETAIL_VENTE_COMPOSANT`:
        *   `INTERVENTION` (1,1) -- inclut_vente_de -- (0,n) `DETAIL_VENTE_COMPOSANT`
        *   `COMPOSANT_CATALOGUE` (1,1) -- est_vendu_via -- (0,n) `DETAIL_VENTE_COMPOSANT`

*   **Entité-Association `DETAIL_VENTE_COMPOSANT`**
    *   `#idIntervention` (PK, FK)
    *   `#idComposantCatalogue` (PK, FK)
    *   `quantiteVendue`
    *   `prixVenteUnitaireApplique` (prix au moment de la vente, peut différer du standard)

**Description textuelle du MCD (forme tabulaire):**

```
Entité: CLIENT
  idClient (PK, Numérique Auto)
  nomClient (Texte)
  prenomClient (Texte)
  adresseClient (Texte)
  telephoneClient (Texte)
  emailClient (Texte)

Entité: TYPE_INTERVENTION
  idTypeIntervention (PK, Numérique Auto)
  libelleTypeIntervention (Texte)
  prixHoraire (Decimal)

Entité: MATERIEL_CLIENT
  idMaterielClient (PK, Numérique Auto)
  #idClient (FK) -> CLIENT.idClient
  typeEquipement (Texte)
  marque (Texte)
  modele (Texte)

Entité: INTERVENTION
  idIntervention (PK, Numérique Auto)
  #idClient (FK) -> CLIENT.idClient
  #idTypeIntervention (FK) -> TYPE_INTERVENTION.idTypeIntervention
  #idMaterielClient (FK) -> MATERIEL_CLIENT.idMaterielClient
  dateHeureDebut (Timestamp)
  dateHeureFin (Timestamp)
  descriptionProbleme (Texte Long)
  descriptionSolution (Texte Long)

Entité: COMPOSANT_CATALOGUE
  idComposantCatalogue (PK, Numérique Auto)
  nomComposant (Texte)
  prixVenteStandard (Decimal)

Entité: DETAIL_VENTE_COMPOSANT
  #idIntervention (PK, FK) -> INTERVENTION.idIntervention
  #idComposantCatalogue (PK, FK) -> COMPOSANT_CATALOGUE.idComposantCatalogue
  quantiteVendue (Entier)
  prixVenteUnitaireApplique (Decimal)
```

**2. Modèle Logique des Données (MLD) - relationnel**

*   `CLIENT (idClient, nomClient, prenomClient, adresseClient, telephoneClient, emailClient)`
    *   PK: `idClient`
*   `TYPE_INTERVENTION (idTypeIntervention, libelleTypeIntervention, prixHoraire)`
    *   PK: `idTypeIntervention`
*   `MATERIEL_CLIENT (idMaterielClient, idClient, typeEquipement, marque, modele)`
    *   PK: `idMaterielClient`
    *   FK: `idClient` REFERENCES `CLIENT(idClient)`
*   `INTERVENTION (idIntervention, idClient, idTypeIntervention, idMaterielClient, dateHeureDebut, dateHeureFin, descriptionProbleme, descriptionSolution)`
    *   PK: `idIntervention`
    *   FK: `idClient` REFERENCES `CLIENT(idClient)`
    *   FK: `idTypeIntervention` REFERENCES `TYPE_INTERVENTION(idTypeIntervention)`
    *   FK: `idMaterielClient` REFERENCES `MATERIEL_CLIENT(idMaterielClient)`
*   `COMPOSANT_CATALOGUE (idComposantCatalogue, nomComposant, prixVenteStandard)`
    *   PK: `idComposantCatalogue`
*   `DETAIL_VENTE_COMPOSANT (idIntervention, idComposantCatalogue, quantiteVendue, prixVenteUnitaireApplique)`
    *   PK: (`idIntervention`, `idComposantCatalogue`)
    *   FK: `idIntervention` REFERENCES `INTERVENTION(idIntervention)`
    *   FK: `idComposantCatalogue` REFERENCES `COMPOSANT_CATALOGUE(idComposantCatalogue)`

**3. Modèle Physique des Données (MPD) - Exemple pour MySQL**

```sql
CREATE TABLE CLIENT (
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    nomClient VARCHAR(100) NOT NULL,
    prenomClient VARCHAR(100),
    adresseClient VARCHAR(255),
    telephoneClient VARCHAR(20) UNIQUE,
    emailClient VARCHAR(100) UNIQUE
);

CREATE TABLE TYPE_INTERVENTION (
    idTypeIntervention INT AUTO_INCREMENT PRIMARY KEY,
    libelleTypeIntervention VARCHAR(150) NOT NULL UNIQUE,
    prixHoraire DECIMAL(10,2) NOT NULL
);

CREATE TABLE MATERIEL_CLIENT (
    idMaterielClient INT AUTO_INCREMENT PRIMARY KEY,
    idClient INT NOT NULL,
    typeEquipement VARCHAR(100) COMMENT 'Ex: PC Portable, Tour, Imprimante',
    marque VARCHAR(100),
    modele VARCHAR(100),
    CONSTRAINT fk_materiel_client_ref FOREIGN KEY (idClient) REFERENCES CLIENT(idClient) ON DELETE CASCADE
);

CREATE TABLE INTERVENTION (
    idIntervention INT AUTO_INCREMENT PRIMARY KEY,
    idClient INT NOT NULL,
    idTypeIntervention INT NOT NULL,
    idMaterielClient INT NULL COMMENT 'Peut être NULL si non applicable à un matériel spécifique',
    dateHeureDebut DATETIME NOT NULL,
    dateHeureFin DATETIME NULL,
    dureeReelle DECIMAL(5,2) NULL COMMENT 'Durée en heures, ex: 1.5 pour 1h30',
    descriptionProbleme TEXT,
    descriptionSolutionApportee TEXT,
    CONSTRAINT fk_intervention_client_ref FOREIGN KEY (idClient) REFERENCES CLIENT(idClient),
    CONSTRAINT fk_intervention_type_ref FOREIGN KEY (idTypeIntervention) REFERENCES TYPE_INTERVENTION(idTypeIntervention),
    CONSTRAINT fk_intervention_materiel_ref FOREIGN KEY (idMaterielClient) REFERENCES MATERIEL_CLIENT(idMaterielClient) ON DELETE SET NULL
);

CREATE TABLE COMPOSANT_CATALOGUE (
    idComposantCatalogue INT AUTO_INCREMENT PRIMARY KEY,
    nomComposant VARCHAR(150) NOT NULL UNIQUE,
    prixVenteStandard DECIMAL(10,2) NOT NULL
);

CREATE TABLE DETAIL_VENTE_COMPOSANT (
    idDetailVenteComposant INT AUTO_INCREMENT PRIMARY KEY COMMENT 'PK simple pour gestion facile',
    idIntervention INT NOT NULL,
    idComposantCatalogue INT NOT NULL,
    quantiteVendue INT NOT NULL DEFAULT 1,
    prixVenteUnitaireApplique DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_dvc_intervention FOREIGN KEY (idIntervention) REFERENCES INTERVENTION(idIntervention) ON DELETE CASCADE,
    CONSTRAINT fk_dvc_composant FOREIGN KEY (idComposantCatalogue) REFERENCES COMPOSANT_CATALOGUE(idComposantCatalogue),
    UNIQUE KEY uk_intervention_composant_unique (idIntervention, idComposantCatalogue) 
    COMMENT 'Assure qu'un type de composant n'est listé qu'une fois par intervention (la quantité gère le nombre)'
);
``` 