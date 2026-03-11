select *
from players
select *
from matches
select *
from registrations
select *
from tournaments


--Elenco dei giocatori iscritti al torneo di spilimbergo master ordinati per Elo (dal più forte al più debole)

select p.Fide_ID, p.Name, p.Surname, p.Elo
from Tournaments as t join Registrations as r on t.Tournament_ID = r.Tournament_ID
					  join Players as p on r.Fide_ID = p.Fide_ID
order by p.Elo desc

-- mostra abbinamento del turno 1 di spilmbergo master con le informazioni di nome e cognome dei giocatori

select m.Round_Number, 
	   m.Fide_ID_White, 
	   p1.Name,
	   p1.Surname,
	   p2.Name,
	   p2.Surname,
	   m.Fide_ID_Black

from matches as m join Players as p1 on p1.Fide_ID = m.Fide_ID_White
				  join Players as p2 on p2.Fide_ID = m.Fide_ID_Black
where Round_Number = 1

-- percorso di un giocatore specifico (Lorenzo Lodici), con somma running sum risultato

select m.Round_Number, 
	   m.Fide_ID_White, 
	   p1.Name,
	   p1.Surname,
	   m.Result,
	   p2.Name,
	   p2.Surname,
	   m.Fide_ID_Black,
	   CASE 
	      WHEN m.Fide_ID_White = '884189' THEN m.Result 
          ELSE (1.0 - m.Result) 
       END AS Punti_Match,
       -- Somma incrementale (Running Total)
       SUM(CASE 
            WHEN m.Fide_ID_White = '884189' THEN m.Result 
            ELSE (1.0 - m.Result) 
       END) OVER (ORDER BY m.Round_Number) AS Punteggio_Progressivo

from matches as m join Players as p1 on p1.Fide_ID = m.Fide_ID_White
				  join Players as p2 on p2.Fide_ID = m.Fide_ID_Black
where m.Fide_ID_White = '884189' or m.Fide_ID_Black = '884189'
order by Round_Number


-- classifica finale per il torneo spilimbergo master (solo punti senza spareggi)

select p.Name, 
	   p.Surname,
	   sum(case when p.Fide_ID = m.Fide_ID_White then m.Result
			    when p.Fide_ID = m.Fide_ID_Black then (1.0 - m.Result)
			    end) as risultato
	 
from Players as p join Matches as m on p.Fide_ID = m.Fide_ID_White or p.Fide_ID = m.Fide_ID_Black
where m.Tournament_ID = 1
group by p.Fide_ID, p.Name, p.Surname
order by risultato desc

--quante volte il bianco vince rispetto al nero?

SELECT 
    COUNT(*) AS Total_Matches,
    SUM(CASE WHEN Result = 1.0 THEN 1 ELSE 0 END) AS White_Wins,
    SUM(CASE WHEN Result = 0.0 THEN 1 ELSE 0 END) AS Black_Wins,
    SUM(CASE WHEN Result = 0.5 THEN 1 ELSE 0 END) AS Draws
FROM Matches
WHERE Result IS NOT NULL







