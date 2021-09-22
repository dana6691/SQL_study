------ Store Procedure: average number of cars and children by salary
Use XAdventureWorks
Go
IF OBJECT_ID('incomerelation', 'P') IS NOT NULL
    DROP PROCEDURE incomerelation
GO
CREATE OR ALTER PROC incomerelation
AS 
BEGIN
	SELECT YearlyIncome, 
		AVG(CAST(NumberCarsOwned AS DECIMAL)) AS TOTALCARS, 
		AVG(CAST(TotalChildren AS DECIMAL)) AS TOTALCHILDREN,
		COUNT(YearlyIncome) AS INCOMECOUNT
	FROM DimCustomer
	GROUP BY YearlyIncome
	ORDER BY YearlyIncome DESC
END

EXECUTE incomerelation;

------ Store Procedure with Parameters
--1. parameter can be null
CREATE OR ALTER PROC incomerelation(
	@MinSalary AS INT,
	@MaxSalary AS INT,
	@searchAdd AS VARCHAR(50))
AS 
BEGIN
	SELECT FirstName, YearlyIncome, MaritalStatus, EnglishEducation, AddressLine1
	FROM DimCustomer
	WHERE   YearlyIncome BETWEEN @MinSalary AND @MaxSalary AND
			(@searchAdd IS NULL OR AddressLine1 LIKE '%' + @searchAdd)			
	ORDER BY YearlyIncome DESC
END

EXECUTE incomerelation 60000, 100000, 'Dr.';
EXECUTE incomerelation 6000,100000,'';

------ Store Procedure with Variables
--1. declearing variables
--2. assigning a value to a variable
--3. referring to a variable in a query
USE Movies
GO
DECLARE @VARDATE DATETIME
DECLARE @NUMFIILMS INT
DECLARE @NUMACTORS INT
DECLARE @NUMDIRECTORS INT

SET @VARDATE = '1980-01-01'
SET @NUMFILMS = (SELECT COUNT(*) FROM tblFilm WHERE FilmReleaseDate >= @VARDATE)
SET @NUMACTORS = (SELECT COUNT(*) FROM tblActor WHERE ActorDOB >= @VARDATE)
SET @NUMDIRECTORS = (SELECT COUNT(*) FROM tblDirector WHERE DirectorDOB >= @VARDATE)

PRINT 'Number of Films after 01/01/80 = ' + CAST(@NumSales AS VARCHAR(50))
PRINT 'Number of Actor Birthday after 01/01/80 = ' + CAST(@NumOnlineSales AS VARCHAR(50))
PRINT 'Number of Director Birthday after 01/01/80 = ' + CAST(@NumEmployee AS VARCHAR(50))

SELECT 'Number of Director Birthday after 01/01/80', @NumEmployee

------ Store a data into the select statement
DECLARE @ID INT
DECLARE @NAME VARCHAR(MAX)
DECLARE @DATE DATETIME

SELECT TOP 1 
	@ID = ActorID, 
	@NAME = ActorName, 
	@DATE = ActorDOB
FROM tblActor
WHERE ActorDOB >= '1950-01-01'
ORDER BY ActorDOB ASC
 
SELECT @ID, @NAME, @DATE
SELECT f.FilmName, c.CastCharacterName,c.CastActorID
FROM tblFilm AS f
INNER JOIN tblCast AS c 
ON f.FilmID = c.CastFilmID
WHERE c.CastActorID = @ID

------ Store a list of data
DECLARE @NAMELIST VARCHAR(MAX)
SET @NAMELIST = ''

SELECT @NAMELIST = @NAMELIST + ActorName + ', ' + CHAR(10)
FROM tblActor
WHERE ActorGender = 'Male'

PRINT @NAMELIST

------ Global variables
SELECT @@SERVERNAME
SELECT @@VERSION
SELECT * FROM tblActor
SELECT @@ROWCOUNT

------ Output Parameters & Return Values
--1. Input parameters
--2. Output parameters
--3. Result of an Output parameters
--4. Return values in stored procedures
USE Movies
GO
CREATE OR ALTER PROC filmsyear(@YEAR INT)
AS
BEGIN
	SELECT FilmName
	FROM tblFilm
	WHERE YEAR(FilmReleaseDate) = @YEAR
	ORDER BY FilmName ASC
END
EXEC filmsyear @YEAR = 2000
EXEC filmsyear 1999

ALTER PROC filmsyear(
		@YEAR INT,
		@FilmList VARCHAR(MAX) OUTPUT,
		@FilmCount INT OUTPUT)
AS 
BEGIN
	DECLARE @Films VARCHAR(MAX)
	SET @Films = ''
	SELECT @Films = @Films + FilmName + ', '
	FROM tblFilm
	WHERE YEAR(FilmReleaseDate) = @YEAR
	ORDER BY FilmName ASC
	SET @FilmCount = @@ROWCOUNT
	SET @FilmList = @Films
END
DECLARE @Names VARCHAR(MAX)
DECLARE @Count INT
EXEC filmsyear @YEAR = 1999,
			@FilmList = @Names OUTPUT,
			@FilmCount = @Count OUTPUT
SELECT @Count AS 'Number of films', @Names AS 'List of Films'


DECLARE @Count INT
EXEC @Count = filmsyear @YEAR = 2000
SELECT @Count AS 'Number of films', @Names AS 'List of Films'

------ If Statement
--1. IS ELSE
--2. Nesting IF
--3. If statement in Store Procedure
USE Movies
GO
--1 & 2
DECLARE @DramaFilms INT
DECLARE @ActionFilms INT

SET @DramaFilms = (SELECT COUNT(*) FROM tblFilm WHERE FilmGenreID = 2)
SET @ActionFilms = (SELECT COUNT(*) FROM tblFilm WHERE FilmGenreID = 1)

IF @DramaFilms > 5
	BEGIN
		PRINT 'WARNING!'
		PRINT 'There are too many drama films in the databse.'
		IF @ActionFilms > 10
			BEGIN
				PRINT 'There are enough action films.'
			END
		ELSE
			BEGIN
				PRINT 'Not enough action films either'
			END
	END
ELSE
	BEGIN
		PRINT 'INFORMATION!'
		PRINT 'There are no more than 5 drama films in the databse.'
	END

--3
CREATE OR ALTER PROC ifvariable ( @infotype VARCHAR(9))
AS
BEGIN
	IF @infotype ='ALL'
		BEGIN
			(SELECT * FROM tblFilm)
			RETURN
		END
	IF @infotype = 'AWARD'
		BEGIN
			(SELECT FilmName, FilmOscarWins, FilmOscarNominations FROM tblFilm)
			RETURN
		END
	SELECT 'You must choose either ALL or AWARD'
END
EXEC ifvariable 'ALL'
EXEC ifvariable 'se'

------ While Loop
--1. SELECT statement in a loop
--2. Ending a loop prematurely
--3. Endless loops
--4. Looping with Cursors(print a list of data)

-- 1 & 2
DECLARE @Counter INT
DECLARE @MaxOscars INT
DECLARE @NumFilms INT

SET @Counter = 1
SET @MaxOscars = (SELECT MAX(FilmOscarWins) FROM tblFilm)

WHILE @Counter <= @MaxOscars
	BEGIN
		SET @NumFilms = (SELECT COUNT(*) FROM tblFilm WHERE FilmOscarWins = @Counter) 
		
		IF @NumFilms = 0 BREAK

		PRINT CAST(@NumFilms AS VARCHAR(3)) + ' films have won ' + CAST(@Counter AS VARCHAR(3)) + ' Oscars'
		SET @Counter = @Counter + 1
	END

--3
DECLARE @Counter INT
DECLARE @MaxOscars INT
DECLARE @NumFilms INT

SET @Counter = 0
SET @MaxOscars = (SELECT MAX(FilmOscarWins) FROM tblFilm)

WHILE @Counter <= @MaxOscars
	BEGIN
		SET @NumFilms = (SELECT COUNT(*) FROM tblFilm WHERE FilmOscarWins = @Counter) 
		PRINT CAST(@NumFilms AS VARCHAR(3)) + ' films have won ' + CAST(@Counter AS VARCHAR(3)) + ' Oscars'
	END

--4
DECLARE @FilmID INT
DECLARE @FilmName VARCHAR(MAX)
DECLARE FilmCursor CURSOR FOR SELECT FilmID, FilmName FROM tblFilm
OPEN FilmCursor
FETCH NEXT FROM FilmCursor INTO @FilmID, @FilmName
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Characters in the film ' + @Filmname
		SELECT CastCharacterName FROM tblCast WHERE CastFilmID = @FilmID
		FETCH NEXT FROM FilmCursor INTO @FilmID, @FilmName
	END
CLOSE FilmCursor
DEALLOCATE FilmCursor

------ User Defined Functions
--1. Defined a Function
--2. Adding code to a Function
--3. Altering Functions
--4. Using Variables
--5. Using Conditional statements and Returning different answers
-- 1 & 2
SELECT FilmName, 
		FilmReleaseDate,
		DATENAME(DW, FilmReleaseDate) + ' ' +
		DATENAME(M, FilmReleaseDate) + ' ' +
		DATENAME(D, FilmReleaseDate) + ' ' +
		DATENAME(YY, FilmReleaseDate) + ' '
FROM tblFilm

CREATE FUNCTION fnlongDate ( @pramDate AS DATETIME )
RETURNS VARCHAR(MAX)
AS 
BEGIN
	RETURN  DATENAME(DW, @pramDate) + ' ' +
			DATENAME(M, @pramDate) + ' ' +
			DATENAME(D, @pramDate) + ' ' +
			DATENAME(YY, @pramDate) + ' '
END

SELECT FilmName, 
		FilmReleaseDate,
		dbo.fnlongDate(FilmReleaseDate)
FROM tblFilm
-- 3
ALTER FUNCTION fnlongDate ( @pramDate AS DATETIME )
RETURNS VARCHAR(MAX)
AS 
BEGIN
	RETURN  DATENAME(DW, @pramDate) + ' ' +
			DATENAME(M, @pramDate) + ' ' +
			DATENAME(D, @pramDate) + 
			CASE WHEN DAY(@pramDate) IN (1,21,31) THEN 'st'
				 WHEN DAY(@pramDate) IN (2,22) THEN 'nd'
				 WHEN DAY(@pramDate) IN (3,23) THEN 'rd'
				 ELSE 'th'
			END + ', ' + 
			DATENAME(YY, @pramDate) + ' '
END
SELECT FilmName, 
		FilmReleaseDate,
		dbo.fnlongDate(FilmReleaseDate)
FROM tblFilm

-- 4 & 5
SELECT ActorName, LEFT(ActorName,CHARINDEX(' ',ActorName)-1)
FROM tblActor

CREATE OR ALTER FUNCTION fnFirstName (@pramName VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @SpacePosition AS INT
	DECLARE @Answer AS VARCHAR(MAX)
	SET @SpacePosition = CHARINDEX(' ',@pramName)
	IF @SpacePosition = 0
		SET @Answer = @pramName
	ELSE
		SET @Answer = LEFT(@pramName, @SpacePosition-1)
	
	RETURN @Answer
END

SELECT ActorName, dbo.fnFirstName(ActorName)
FROM tblActor










--- Basic Transactions
USE XMovies
GO
--Adding new record
INSERT INTO tblFilm (FilmID,FilmName, FilmReleaseDate)
VALUES(270, 'Iron Man 3', '2013-04-25')

--Updating record 
UPDATE tblFilm
SET FilmBoxOfficeDollars = 39665950
WHERE FilmName = 'Iron Man 3'

--Deleting record
DELETE FROM tblFilm 
WHERE FilmName IN ('Iron Man 3','Hello Man')

--Committing & Rolling Back Transaction
BEGIN TRAN AddRollback

INSERT INTO tblFilm (FilmName, FilmReleaseDate)
VALUES('Hello Man', '2015-07-12')


INSERT INTO tblFilm (FilmID,FilmName, FilmReleaseDate)
VALUES(271, 'Hello Man', '2015-07-12')

SELECT * FROM tblFilm WHERE FilmName = 'Hello Man'
ROLLBACK TRAN
SELECT * FROM tblFilm WHERE FilmName = 'Hello Man'

COMMIT TRAN AddRollback

--Committing or Rolling Back With Condition
USE Movies
GO
DECLARE @Ironmen INT

BEGIN TRAN AddIronman3

INSERT INTO tblFilm (FilmID,FilmName, FilmReleaseDate)
VALUES(270, 'Iron Man 3', '2013-04-25')

SELECT @Ironmen = COUNT(*) FROM tblFilm WHERE FilmName = 'Iron Man 3'

If @Ironmen > 1
	BEGIN
		ROLLBACK TRAN AddIronman3
		PRINT 'Iron Man 3 is already there'
	END
ELSE
	BEGIN
		COMMIT TRAN AddIronman3
		PRINT 'Add Iron Man 3'
	END