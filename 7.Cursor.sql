------ Cursor
--1. Declaring a cursor 
--2. Inputting values into the variables
--3. Inputting values into the variables + Store Procedure
--4. Creating cumulative total column using a cursor

--1
-- Read first to the last
DECLARE FilmCursor CURSOR
	FOR SELECT FilmID, FilmName, FilmReleaseDate FROM tblFilm
OPEN FilmCursor
	--contents
	FETCH NEXT FROM FilmCursor
	WHILE @@FETCH_STATUS = 0
		FETCH NEXT FROM FilmCursor
CLOSE FilmCursor
DEALLOCATE FilmCursor

-- Read last to first
DECLARE FilmCursor CURSOR SCROLL
	FOR SELECT FilmID, FilmName, FilmReleaseDate FROM tblFilm
OPEN FilmCursor
	--contents
	FETCH LAST FROM FilmCursor
	WHILE @@FETCH_STATUS = 0
		FETCH PRIOR FROM FilmCursor
CLOSE FilmCursor
DEALLOCATE FilmCursor

-- Read last 9 records
DECLARE FilmCursor CURSOR SCROLL
	FOR SELECT FilmID, FilmName, FilmReleaseDate FROM tblFilm
OPEN FilmCursor
	--contents
	FETCH ABSOLUTE -9 FROM FilmCursor
	WHILE @@FETCH_STATUS = 0
		FETCH NEXT FROM FilmCursor
CLOSE FilmCursor
DEALLOCATE FilmCursor


-- Read FilmID = multiple of 10
DECLARE FilmCursor CURSOR SCROLL
	FOR SELECT FilmID, FilmName, FilmReleaseDate FROM tblFilm
OPEN FilmCursor
	--contents
	FETCH ABSOLUTE 9 FROM FilmCursor
	WHILE @@FETCH_STATUS = 0
		FETCH RELATIVE 10 FROM FilmCursor
CLOSE FilmCursor
DEALLOCATE FilmCursor


--2
DECLARE @ID INT
DECLARE @Name VARCHAR(MAX)
DECLARE @Date DATETIME

DECLARE FilmCursor CURSOR SCROLL
	FOR SELECT FilmID, FilmName, FilmReleaseDate FROM tblFilm
OPEN FilmCursor
	FETCH NEXT FROM FilmCursor
	INTO @ID, @Name, @Date

	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @Name + ' was released on ' + CONVERT(CHAR(10),@Date, 103)
			PRINT '===================================================='
			PRINT 'List of Characters'

			SELECT CastCharacterName
			FROM tblCast
			WHERE CastFilmID = @ID

			FETCH NEXT FROM FilmCursor
				INTO @ID, @Name, @Date
		END
CLOSE FilmCursor
DEALLOCATE FilmCursor


--3
CREATE OR ALTER PROC spListCharacters(
	@FilmID INT,
	@FilmName VARCHAR(MAX),
	@FilmDate DATETIME)
AS
BEGIN
	PRINT @FilmName + ' was released on ' + CONVERT(CHAR(10),@FilmDate, 103)
	PRINT '===================================================='
	PRINT 'List of Characters'
	SELECT CastCharacterName
	FROM tblCast
	WHERE CastFilmID = @FilmID
END

DECLARE @ID INT
DECLARE @Name VARCHAR(MAX)
DECLARE @Date DATETIME

DECLARE FilmCursor CURSOR LOCAL
	FOR SELECT FilmID, FilmName, FilmReleaseDate FROM tblFilm
OPEN FilmCursor
	FETCH NEXT FROM FilmCursor
	INTO @ID, @Name, @Date

	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spListCharacters @ID, @Name, @Date

			FETCH NEXT FROM spListCharacters
				INTO @ID, @Name, @Date
		END
CLOSE FilmCursor
DEALLOCATE FilmCursor

--4
DECLARE @FilmOscars INT
DECLARE @TotalOscars INT
SET @TotalOscars = 0
DECLARE FilmCursor CURSOR 
	FOR SELECT FilmOscarWins FROM tblFilm
	FOR UPDATE OF FilmCumulativeOscars
OPEN FilmCursor
	FETCH NEXT FROM FilmCursor INTO @FilmOscars

	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @TotalOscars += @FilmOscars
			UPDATE tblFilm
			SET FilmCumulativeOscars = @TotalOscars
			WHERE CURRENT OF FilmCursor

			FETCH NEXT FROM FilmCursor INTO @FilmOscars
		END
CLOSE FilmCursor
DEALLOCATE FilmCursor

SELECT * FROM tblFilm