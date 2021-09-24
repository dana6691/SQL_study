/*******************************************************************/
------ Store Procedure
--1. Executing Store Procedures
--2. Dropping Store Procedures
/*******************************************************************/
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

EXECUTE incomerelation
/*******************************************************************/
------ Store Procedure with Parameters
--1. Executing Procedures with Parameters
--2. Optional Parameters and Default Values
/*******************************************************************/
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
/*******************************************************************/
------ Store Procedure with Variables
--1. Declearing variables
--2. Assigning a value to a variable
--3. Referring to a variable in a query
/*******************************************************************/
-- 1
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

-- 2
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

-- Store a list of data
DECLARE @NAMELIST VARCHAR(MAX)
SET @NAMELIST = ''

SELECT @NAMELIST = @NAMELIST + ActorName + ', ' + CHAR(10)
FROM tblActor
WHERE ActorGender = 'Male'

PRINT @NAMELIST

-- Global variables
SELECT @@SERVERNAME
SELECT @@VERSION
SELECT * FROM tblActor
SELECT @@ROWCOUNT
/*******************************************************************/
------ Output Parameters & Return Values
--1. Input parameters
--2. Output parameters
--3. Result of an Output parameters
--4. Return values in stored procedures
/*******************************************************************/
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




