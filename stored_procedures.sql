--Inserimento sicuro
--Obiettivo: creare una procedura per inserire una nuova partita, ma l'arbitro (o chi inserisce i dati) a volte sbaglia 
--e cerca di far giocare un giocatore che sta già giocando un'altra partita in quello stesso turno
--La procedura deve prima controllare se il Bianco o il Nero hanno già una partita registrata in quel Round_Number e Tournament_ID. 
--Se ce l'hanno, blocca tutto e lancia un messaggio di errore. Altrimenti, inserisce la partita.

CREATE PROCEDURE InserisciPartitaSicura
    @Board INT,
    @Torneo INT,
    @Turno INT,
    @IdBianco INT,
    @IdNero INT,
    @Risultato DECIMAL(2,1)
AS
BEGIN
    -- Controllo se uno dei due giocatori sta già giocando in questo turno di questo torneo
    IF EXISTS (
        SELECT 1 
        FROM matches
        WHERE Tournament_ID = @Torneo 
          AND Round_Number = @Turno
          AND (Fide_ID_White IN (@IdBianco, @IdNero) OR Fide_ID_Black IN (@IdBianco, @IdNero))
    )
    BEGIN
        -- Se la query sopra trova qualcosa, significa che c'è un'anomalia
        PRINT 'ERRORE: Uno dei due giocatori sta già giocando in questo turno!';
    END
    ELSE
    BEGIN
        -- Se non c'è nessuna anomalia, procedo con l'inserimento
        INSERT INTO Matches (Board_Number, Tournament_ID, Round_Number, Fide_ID_White, Fide_ID_Black, Result)
        VALUES (@Board, @Torneo, @Turno, @IdBianco, @IdNero, @Risultato);
        
        PRINT 'Partita inserita correttamente!';
    END
END

--Ricerca Giocatore
--Obiettivo: Creare una procedura che, dandole in pasto l'ID FIDE di un giocatore, ti restituisca tutti i suoi dati anagrafici (Nome, Cognome, Nazionalità, Elo).

create procedure cerca_giocatore
    @ID_cercato int
as
begin
    select Name, Surname, Nationality, Elo
    from Players
    where Fide_ID = @ID_cercato
end

exec cerca_giocatore
    200999




--Filtro Turno
--Obiettivo: Spesso l'arbitro vuole vedere a colpo d'occhio tutte le partite di un determinato turno in un torneo specifico. 

create procedure filtro_turno
    @numero_turno int,
    @ID_torneo int
as
begin
    select m.Board_Number,
           m.Tournament_ID,
           m.Round_Number,
           p1.Name,
           p1.Surname,
           m.Result,
           p2.Name,
           p2.Surname

    from Matches as m join Players as p1 on p1.Fide_ID = m.Fide_ID_White
                      join Players as p2 on p2.Fide_ID = m.Fide_ID_Black
    where Round_Number = @numero_turno and Tournament_ID = @ID_torneo
end

exec filtro_turno
    1,
    1
    

--Generatore di Classifica
--Obiettivo: Creare una procedura che prenda in input l'ID di un torneo e generi la classifica in tempo reale, calcolando i punti totali di ogni giocatore. 

create procedure genera_classifica
    @ID_torneo int
as
begin
    select p.Name, 
	       p.Surname,
    	   sum(case when p.Fide_ID = m.Fide_ID_White then m.Result
    			    when p.Fide_ID = m.Fide_ID_Black then (1.0 - m.Result)
    			    end) as risultato
    from Players as p join Matches as m on p.Fide_ID = m.Fide_ID_White or p.Fide_ID = m.Fide_ID_Black
    where m.Tournament_ID = @ID_torneo
    group by p.Fide_ID, p.Name, p.Surname
    order by risultato desc
end

exec genera_classifica
    1

--Le Statistiche Dettagliate (Multi-aggregazione)
--Obiettivo: Creare un "profilo statistico" di un giocatore. Dando in pasto il suo Fide_ID, la procedura deve restituire quante vittorie ha ottenuto col Bianco, 
--quante col Nero, e quante patte (in uno specifico torneo).

create procedure statistiche_giocatore
    @ID_giocatore int,
    @ID_torneo int
as
begin
    select p.Fide_ID,
           p.Name,
           p.Surname,
           count(m.Board_Number) as Partite_Giocate,
           sum(case when m.Fide_ID_White = p.Fide_ID AND m.Result = 1.0 then 1 else 0 end) as Vittorie_Bianco,
           sum(case when m.Fide_ID_Black = p.Fide_ID AND m.Result = 0.0 then 1 else 0 end) as Vittorie_Nero,
           sum(case when m.Result = 0.5 then 1 else 0 end) as Patte_Totali
    from players as p join Matches as m on p.Fide_ID = m.Fide_ID_White or p.Fide_ID = m.Fide_ID_Black
    where m.Tournament_ID = @ID_torneo and p.Fide_ID = @ID_giocatore
    group by p.Fide_ID, p.Name, p.Surname
end

exec statistiche_giocatore
    240990,
    1
