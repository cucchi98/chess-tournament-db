-- funzione per calcolare il punteggio dei giocatori

CREATE FUNCTION dbo.fn_CalcolaPunti
(
    @IdGiocatore INT,
    @IdTorneo INT
)
-- Dichiariamo che tipo di dato uscirà dalla funzione (es. 5.5 punti)
RETURNS DECIMAL(4,1) 
AS
BEGIN
    -- Creiamo una variabile interna per memorizzare il risultato
    DECLARE @PuntiTotali DECIMAL(4,1);

    -- Facciamo il calcolo e lo salviamo nella variabile
    SELECT @PuntiTotali = SUM(
        CASE 
            WHEN Fide_ID_White = @IdGiocatore THEN Result
            WHEN Fide_ID_Black = @IdGiocatore THEN (1.0 - Result)
            ELSE 0.0 
        END
    )
    FROM Matches
    WHERE Tournament_ID = @IdTorneo 
      AND (Fide_ID_White = @IdGiocatore OR Fide_ID_Black = @IdGiocatore);

    -- Se il giocatore non ha giocato partite, la somma è NULL. La trasformiamo in 0.0.
    RETURN ISNULL(@PuntiTotali, 0.0);
END

--classifica usando la funzione
SELECT 
    Name, 
    Surname, 
    dbo.fn_CalcolaPunti(Fide_ID, 1) AS Punti_Torneo
FROM Players
ORDER BY Punti_Torneo DESC

--classifica con giocatori che hanno piu di 3 punti
SELECT Name, Surname
FROM Players
WHERE dbo.fn_CalcolaPunti(Fide_ID, 1) > 3.0

--classifica con punteggio in percentuale
SELECT Name, Surname, (dbo.fn_CalcolaPunti(Fide_ID, 1) * 100)/9 AS Punti_Percentuali
FROM Players
order by Punti_Percentuali desc