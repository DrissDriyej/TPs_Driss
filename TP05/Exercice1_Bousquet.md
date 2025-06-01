## Premier exercice : Vente directe de M. Bousquet

Voici l'analyse et les modèles :

**1. Modèle Conceptuel des Données (MCD)**

*   **Identification des entités principales :**
    *   `PRODUIT`: Représente un type de produit vendu (ex: lapin, poule, chou, fraise).
    *   `VENTE`: Représente une transaction de vente (un passage en caisse, qui peut contenir plusieurs lignes de produits).
    *   `TYPE_PRODUIT`: Catégorise les produits (animal, légume, fruit).

*   **Attributs des entités (et identifiants notés avec (PK)) :**
    *   `PRODUIT`:
        *   `idProduit` (PK)
        *   `nomProduit`
        *   `#idTypeProduit` (FK vers TYPE_PRODUIT)
    *   `VENTE`:
        *   `idVente` (PK)
        *   `dateVente`
        *   `heureVente` (optionnel)
    *   `TYPE_PRODUIT`:
        *   `idTypeProduit` (PK)
        *   `libelleTypeProduit`

*   **Relations et cardinalités (notation : Entite1 (min,max) -- Relation -- (min,max) Entite2) :**
    *   `PRODUIT` (0,n) -- est_de_type -- (1,1) `TYPE_PRODUIT`
        *   Un produit est d'un seul type. Un type peut concerner plusieurs produits.

    *   La relation entre `VENTE` et `PRODUIT` est plusieurs-à-plusieurs (une vente a plusieurs produits, un produit peut être dans plusieurs ventes). Elle est portée par une entité-association `LIGNE_VENTE`:
        *   `VENTE` (1,1) -- compose -- (1,n) `LIGNE_VENTE`
            *   Une vente est composée d'au moins une ligne de vente. Une ligne de vente appartient à une seule vente.
        *   `PRODUIT` (1,1) -- est_concerné_par -- (0,n) `LIGNE_VENTE` (ou inversé: LIGNE_VENTE concerne un PRODUIT)
            *   Une ligne de vente concerne un seul produit. Un produit peut être dans plusieurs lignes de vente (ou aucune).

*   **Entité-Association `LIGNE_VENTE` (détail de la vente)**
    *   Attributs (identifiants hérités de VENTE et PRODUIT formant la clé primaire composée) :
        *   `#idVente` (PK, FK)
        *   `#idProduit` (PK, FK)
    *   Attributs propres :
        *   `quantiteVendueKilo`
        *   `prixAuKiloLorsDeVente`

**Description textuelle du MCD (forme tabulaire pour simplifier sans diagramme):**

```
Entité: TYPE_PRODUIT
  idTypeProduit (PK, Texte(1))  -- Ex: 'A', 'L', 'F'
  libelleTypeProduit (Texte(50))

Entité: PRODUIT
  idProduit (PK, Numérique Auto)
  nomProduit (Texte(100))
  #idTypeProduit (FK, Texte(1)) -> TYPE_PRODUIT.idTypeProduit

Entité: VENTE
  idVente (PK, Numérique Auto)
  dateVente (Date)
  heureVente (Heure) -- Optionnel

Entité: LIGNE_VENTE
  #idVente (PK, FK, Numérique) -> VENTE.idVente
  #idProduit (PK, FK, Numérique) -> PRODUIT.idProduit
  quantiteVendueKilo (Numérique Decimal(10,3))
  prixAuKiloLorsDeVente (Numérique Decimal(10,2))
```

**2. Modèle Logique des Données (MLD) - relationnel**

Le MLD découle directement du MCD. Les entités deviennent des relations (tables).

*   `TYPE_PRODUIT (idTypeProduit, libelleTypeProduit)`
    *   Clé primaire : `idTypeProduit`
*   `PRODUIT (idProduit, nomProduit, idTypeProduit)`
    *   Clé primaire : `idProduit`
    *   Clé étrangère : `idTypeProduit` référence `TYPE_PRODUIT(idTypeProduit)`
*   `VENTE (idVente, dateVente, heureVente)`
    *   Clé primaire : `idVente`
*   `LIGNE_VENTE (idVente, idProduit, quantiteVendueKilo, prixAuKiloLorsDeVente)`
    *   Clé primaire : (`idVente`, `idProduit`)
    *   Clé étrangère : `idVente` référence `VENTE(idVente)`
    *   Clé étrangère : `idProduit` référence `PRODUIT(idProduit)`

**3. Modèle Physique des Données (MPD) - Exemple pour MySQL**

```sql
CREATE TABLE TYPE_PRODUIT (
    idTypeProduit CHAR(1) PRIMARY KEY COMMENT 'A=Animal, L=Légume, F=Fruit',
    libelleTypeProduit VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE PRODUIT (
    idProduit INT AUTO_INCREMENT PRIMARY KEY,
    nomProduit VARCHAR(100) NOT NULL UNIQUE,
    idTypeProduit CHAR(1) NOT NULL,
    CONSTRAINT fk_produit_type FOREIGN KEY (idTypeProduit) REFERENCES TYPE_PRODUIT(idTypeProduit)
);

CREATE TABLE VENTE (
    idVente INT AUTO_INCREMENT PRIMARY KEY,
    dateVente DATE NOT NULL,
    heureVente TIME NULL COMMENT 'Optionnel'
);

CREATE TABLE LIGNE_VENTE (
    idVente INT NOT NULL,
    idProduit INT NOT NULL,
    quantiteVendueKilo DECIMAL(10,3) NOT NULL COMMENT 'Ex: 2.500 kg',
    prixAuKiloLorsDeVente DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (idVente, idProduit),
    CONSTRAINT fk_ligne_vente FOREIGN KEY (idVente) REFERENCES VENTE(idVente) ON DELETE CASCADE,
    CONSTRAINT fk_ligne_produit FOREIGN KEY (idProduit) REFERENCES PRODUIT(idProduit)
);
```

**4. Donner des exemples de contenu de tables**

`TYPE_PRODUIT`
| idTypeProduit | libelleTypeProduit |
|---------------|--------------------|
| A             | Animal             |
| L             | Légume             |
| F             | Fruit              |

`PRODUIT`
| idProduit | nomProduit        | idTypeProduit |
|-----------|-------------------|---------------|
| 1         | Lapin             | A             |
| 2         | Poule             | A             |
| 3         | Carotte           | L             |
| 4         | Pomme de terre    | L             |
| 5         | Fraise Gariguette | F             |
| 6         | Poire Conférence  | F             |

`VENTE`
| idVente | dateVente  | heureVente |
|---------|------------|------------|
| 101     | 2023-10-26 | 10:30:00   |
| 102     | 2023-10-26 | 11:15:00   |
| 103     | 2023-10-27 | 09:45:00   |

`LIGNE_VENTE`
| idVente | idProduit | quantiteVendueKilo | prixAuKiloLorsDeVente |
|---------|-----------|--------------------|-------------------------|
| 101     | 1         | 2.500              | 12.00                   |
| 101     | 3         | 1.200              | 1.50                    |
| 102     | 5         | 0.800              | 8.00                    |
| 102     | 2         | 1.800              | 9.50                    |
| 103     | 4         | 5.000              | 1.20                    |
| 103     | 6         | 1.500              | 3.00                    | 