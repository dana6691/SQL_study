/*******************************************************************/
------ User Defined Functions
--1. Defined a Function
--2. Adding code to a Function
--3. Altering Functions
--4. Using Variables
--5. Using Conditional statements and Returning different answers
/*******************************************************************/
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



