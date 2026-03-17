-- Creazione della tabella Giocatori
CREATE TABLE Players (
    Fide_ID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Surname VARCHAR(50) NOT NULL,
    Nationality VARCHAR(50),
    Elo INT DEFAULT 1000, -- Punteggio base di default
    Title VARCHAR(5),
    Sex VARCHAR(1)
)

-- Creazione della tabella Tornei
CREATE TABLE Tournaments (
    Tournament_ID INT PRIMARY KEY,
    Tournament_Name VARCHAR(150) NOT NULL,
    Beginning_Date DATE NOT NULL,
    End_Date DATE,
    Location VARCHAR(100)
)

-- Creazione della tabella Iscrizioni
CREATE TABLE Registrations (
    Tournament_ID INT,
    Fide_ID INT,
    Registration_Date DATE,
    PRIMARY KEY (Tournament_ID, Fide_ID),
    FOREIGN KEY (Tournament_ID) REFERENCES Tournaments(Tournament_ID) ON DELETE CASCADE,
    FOREIGN KEY (Fide_ID) REFERENCES Players(Fide_ID) ON DELETE CASCADE
)

-- Creazione della tabella Partite
CREATE TABLE Matches (
    Board_Number INT NOT NULL,
    Tournament_ID INT NOT NULL,
    Round_Number INT NOT NULL,
    Fide_ID_White INT NOT NULL,
    Fide_ID_Black INT NOT NULL,
    Result DECIMAL(2,1),

     -- Definizione della chiave primaria composta
    PRIMARY KEY (Board_Number, Round_Number, Tournament_ID),
    
    -- Chiavi esterne
    FOREIGN KEY (Tournament_ID) REFERENCES Tournaments(Tournament_ID) ON DELETE CASCADE,
    FOREIGN KEY (Fide_ID_White) REFERENCES Players(Fide_ID),
    FOREIGN KEY (Fide_ID_Black) REFERENCES Players(Fide_ID),
    
    -- Vincolo: Il bianco e il nero non possono essere lo stesso giocatore
    CONSTRAINT chk_different_players CHECK (Fide_ID_White <> Fide_ID_Black),
    CONSTRAINT chk_result CHECK (Result IN (1.0, 0.0, 0.5)),
    
)


