--funzione per calcolare spareggio bucholz

CREATE FUNCTION dbo.fn_CalcolaBuchholz
(
    @IdGiocatore INT,
    @IdTorneo INT
)
RETURNS DECIMAL(5,2) 
AS
BEGIN
    DECLARE @Buchholz DECIMAL(5,2);

    -- Sommiamo i punti finali di tutti gli avversari trovati
    SELECT @Buchholz = SUM(dbo.fn_CalcolaPunti(Avversario_ID, @IdTorneo))
    FROM (
        -- Trovo gli avversari di quando il giocatore aveva il BIANCO
        SELECT Fide_ID_Black AS Avversario_ID 
        FROM Matches 
        WHERE Fide_ID_White = @IdGiocatore AND Tournament_ID = @IdTorneo
        
        UNION ALL
        
        -- Trovo gli avversari di quando il giocatore aveva il NERO
        SELECT Fide_ID_White AS Avversario_ID 
        FROM Matches 
        WHERE Fide_ID_Black = @IdGiocatore AND Tournament_ID = @IdTorneo
    ) AS ElencoAvversari;

    -- Se non ha giocato partite, restituisco 0
    RETURN ISNULL(@Buchholz, 0.0);
END

SELECT 
    p.Name, 
    p.Surname, 
    dbo.fn_CalcolaPunti(p.Fide_ID, 1) AS Punti_Torneo,
    dbo.fn_CalcolaBuchholz(p.Fide_ID, 1) AS Punteggio_Buchholz
FROM Players p
-- Filtriamo per mostrare solo chi ha giocato almeno una partita in quel torneo
WHERE p.Fide_ID IN (
    SELECT Fide_ID_White FROM Matches WHERE Tournament_ID = 1
    UNION 
    SELECT Fide_ID_Black FROM Matches WHERE Tournament_ID = 1
)
-- ECCO LO SPAREGGIO IN AZIONE:
ORDER BY 
    Punti_Torneo DESC,       -- Prima ordina per chi ha più punti
    Punteggio_Buchholz DESC -- Se sono pari, vince chi ha il Buchholz più alto
