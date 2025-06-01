CREATE TABLE Segment (
    indIP VARCHAR(11) PRIMARY KEY,
    nomSegment VARCHAR(20) NOT NULL,
    etage TINYINT(1)
);

CREATE TABLE Salle (
    nSalle VARCHAR(7) PRIMARY KEY,
    nomSalle VARCHAR(20) NOT NULL,
    nbPoste TINYINT(2),
    indIP VARCHAR(11),
    FOREIGN KEY (indIP) REFERENCES Segment(indIP)
);

CREATE TABLE Poste (
    nPoste VARCHAR(7) PRIMARY KEY,
    nomPoste VARCHAR(20) NOT NULL,
    indIP VARCHAR(11),
    ad VARCHAR(3) CHECK (ad >= 0 AND ad <= 255),
    typePoste VARCHAR(9),
    nSalle VARCHAR(7),
    FOREIGN KEY (indIP) REFERENCES Segment(indIP),
    FOREIGN KEY (nSalle) REFERENCES Salle(nSalle)
);

CREATE TABLE Logiciel (
    nLog VARCHAR(5) PRIMARY KEY,
    nomLog VARCHAR(20),
    dateAch DATETIME,
    version VARCHAR(7),
    typeLog VARCHAR(9),
    prix DECIMAL(6,2) CHECK (prix >= 0)
);

CREATE TABLE Installer (
    nPoste VARCHAR(7),
    nLog VARCHAR(5),
    numIns INTEGER(5),
    dateIns DATETIME DEFAULT CURRENT_TIMESTAMP,
    delai SMALLINT,
    PRIMARY KEY (nPoste, nLog, numIns),
    FOREIGN KEY (nPoste) REFERENCES Poste(nPoste),
    FOREIGN KEY (nLog) REFERENCES Logiciel(nLog)
);

CREATE TABLE Types (
    typeLP VARCHAR(9) PRIMARY KEY,
    nomType VARCHAR(20)
); 