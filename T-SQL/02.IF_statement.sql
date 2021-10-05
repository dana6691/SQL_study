/*******************************************************************/
------ If Statement
--1. IS ELSE
--2. Nesting IF
--3. If statement in Store Procedure
/*******************************************************************/
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
