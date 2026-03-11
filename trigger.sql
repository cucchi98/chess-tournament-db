CREATE TABLE Log_Modifiche_Risultati (
    Log_ID INT IDENTITY(1,1) PRIMARY KEY,
    Tournament_ID INT,
    Round_Number INT,
    Board_Number INT,
    Vecchio_Risultato DECIMAL(2,1),
    Nuovo_Risultato DECIMAL(2,1),
    Data_Modifica DATETIME DEFAULT GETDATE()
)

--trigger per salvare il vecchio risultato in una tabella log nel momento in cui un risultato viene modificato nella tabella matches
CREATE TRIGGER trg_Storico_Risultati
ON Matches
AFTER UPDATE -- Scatta solo DOPO che è stato fatto un UPDATE
AS
BEGIN
    -- Seleziono i dati dalle tabelle inserted e deleted
    INSERT INTO Log_Modifiche_Risultati (Tournament_ID, Round_Number, Board_Number, Vecchio_Risultato, Nuovo_Risultato)
    SELECT 
        i.Tournament_ID,
        i.Round_Number,
        i.Board_Number,
        d.Result, -- Il risultato prima della modifica
        i.Result  -- Il risultato dopo la modifica
    FROM inserted AS i
    JOIN deleted AS d 
      ON i.Tournament_ID = d.Tournament_ID 
     AND i.Round_Number = d.Round_Number 
     AND i.Board_Number = d.Board_Number
    -- Salviamo la riga solo se il risultato è effettivamente cambiato!
    WHERE i.Result <> d.Result 
       OR (d.Result IS NULL AND i.Result IS NOT NULL);
END