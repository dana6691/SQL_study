
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