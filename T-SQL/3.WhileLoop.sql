/*******************************************************************/
------ While Loop
--1. SELECT statement in a loop
--2. Ending a loop prematurely
--3. Endless loops
--4. Looping with Cursors(print a list of data)
/*******************************************************************/
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