------ Common Table Expressions(CTE)
--1. Create CTE and calculate aggregates, and naming CTE columns
--2. Create Multiple CTEs
WITH EarlyFilms AS
(
SELECT FilmName, 
	FilmReleaseDate,
	FilmRunTimeMinutes
FROM tblFilm
WHERE FilmReleaseDate < '2000-01-01'
)
SELECT *
FROM EarlyFilms
WHERE FilmRunTimeMinutes > 120


--Calculate aggregates
WITH FilmCounts AS
(
SELECT FilmCountryID, COUNT(*) AS NumberOfFilms
FROM tblFilm
GROUP BY FilmCountryID
)
SELECT AVG(NumberOfFilms)
FROM FilmCounts

--Naming CTE columns
WITH FilmCounts(Country, NumberOfFilms) AS
(
SELECT FilmCountryID, COUNT(*) 
FROM tblFilm
GROUP BY FilmCountryID
)
SELECT Country, NumberOfFilms
FROM FilmCounts


-- Multiple CTEs
WITH EarlyFilms AS
(
SELECT FilmName, FilmReleaseDate
FROM tblFilm
WHERE FilmReleaseDate < '2000-01-01'
),
RecentFilms AS 
(
SELECT FilmName, FilmReleaseDate
FROM tblFilm
WHERE FilmReleaseDate >= '2000-01-01'
)
SELECT *
FROM EarlyFilms AS e
INNER JOIN RecentFilms AS r
ON e.FilmName = r.FilmName 
