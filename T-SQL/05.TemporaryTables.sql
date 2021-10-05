------ Temporary Tables
--table only appears while the code file is open, removed when we close the file
--location: Databases > System Databases > tempdb > Temporary Tables
--1. Create temporary tables & Add records to temporary tables & Remove temporary tables 
--2. Use Store procedures
USE Movies
GO
-- Create Method 1
DROP TABLE ##TempFilms
SELECT FilmName, FilmReleaseDate 
INTO ##TempFilms
FROM tblFilm
WHERE FilmName LIKE '%star%'

SELECT * FROM ##TempFilms

-- Create Method 2
DROP TABLE ##TempFilms2
CREATE TABLE ##TempFilms2(
	Title VARCHAR(MAX),
	ReleaseDate DATETIME
)
INSERT INTO ##TempFilms2
SELECT FilmName, FilmReleaseDate 
FROM tblFilm
WHERE FilmName LIKE '%star%'

SELECT * FROM ##TempFilms2

-- Store procedures 1
CREATE OR ALTER PROC spInsertTemp (@procInclude AS VARCHAR(MAX))
AS 
BEGIN
	INSERT INTO ##TempFilms
	SELECT FilmName, FilmReleaseDate 
	FROM tblFilm
	WHERE FilmName LIKE '%' + @procInclude + '%'
END

-- Store procedures 2
CREATE OR ALTER PROC spInsertTemp2
AS 
BEGIN
	SELECT FilmName, FilmReleaseDate 
	FROM ##TempFilms
END

EXEC spInsertTemp 'king'
EXEC spInsertTemp2

------ Table Variables
--1. Declaring a Table variable
--2. Inserting data into a table variable
--3. Table Variables vs Temporary Tables
-- Table Variables does not need to drop and create the table when we change WHERE statement

--Temporary Tables
DROP TABLE #TempPeople
CREATE TABLE #TempPeople(
	PersonName VARCHAR(MAX),
	PersonDate DATETIME
)
INSERT INTO #TempPeople
SELECT ActorName, ActorDOB
FROM tblActor
WHERE ActorDOB < '1950-01-01'

SELECT * FROM #TempPeople

--Table Variables
DECLARE @TempPeople TABLE(
	PersonName VARCHAR(MAX),
	PersonDate DATETIME
)
INSERT INTO @TempPeople
SELECT ActorName, ActorDOB
FROM tblActor
WHERE ActorDOB < '1960-01-01'

SELECT * FROM @TempPeople


------ Table-Valued Functions
--1. Create Table-valued function and modifying
--2. Multi-statement Table-valued functions
--location: Databases > Movies > Prograamability > Functions > dbo.FilsInYear

--Use Select statement
SELECT FilmName, 
		FilmReleaseDate,
		FilmRunTimeMinutes
FROM tblFilm
WHERE YEAR(FilmReleaseDate) = 2000

--Use Table-valued function
CREATE OR ALTER FUNCTION FilmsInYear(@FilmYear INT)
RETURNS TABLE
AS
RETURN SELECT FilmName, 
			FilmReleaseDate,
			FilmRunTimeMinutes
		FROM tblFilm
		WHERE YEAR(FilmReleaseDate) = @FilmYear

SELECT FilmName, 
		FilmReleaseDate,
		FilmRunTimeMinutes
FROM dbo.FilmsInYear(2000)

--Multi-statement Table-valued functions
CREATE OR ALTER FUNCTION PeopleInYear(@BirthYear INT)
RETURNS @t TABLE
(
	PersonName VARCHAR(MAX),
	PersonDOB DATETIME,
	PersonJob VARCHAR(8)
)
AS
BEGIN
	INSERT INTO @t
	SELECT DirectorName, DirectorDOB, 'Director'
	FROM tblDirector
	WHERE YEAR(DirectorDOB) = @BirthYear

	INSERT INTO @t
	SELECT ActorName, ActorDOB, 'Actor'
	FROM tblActor
	WHERE YEAR(ActorDOB) = @BirthYear

	RETURN
END

SELECT *
FROM dbo.PeopleInYear(1945)
