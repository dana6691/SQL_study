-- Using EXECUTE
EXECUTE('SELECT * FROM tblFilm')

-- Using sp_executesql
EXEC sp_executesql N'SELECT * FROM tblFilm'

--Concatenating an SQL string
DECLARE @Tablename NVARCHAR(128)
DECLARE @SQLString NVARCHAR(MAX)
DECLARE @Number INT
SET @Tablename = N'tblActor'
SET @Number = 10
SET @SQLString = N'SELECT TOP ' + CAST(@Number AS NVARCHAR(4)) + ' * FROM ' + @Tablename

EXEC sp_executesql @SQLString

-- Creating stored procedures
CREATE OR ALTER PROC spVariableTable(
	@TableName NVARCHAR(128),
	@Number INT)
AS
BEGIN
	DECLARE @SQLString NVARCHAR(MAX)
	DECLARE @NumberString NVARCHAR(4)
	SET @NumberString = CAST(@Number AS NVARCHAR(4))
	SET @SQLString = N'SELECT TOP ' + @NumberString + ' * FROM ' + @TableName
	EXEC sp_executesql @SQLString
END

EXEC spVariableTable 'tblFilm', 5

-- Creating stored procedures with IN statement
CREATE OR ALTER PROC spFilmYears( @YearList NVARCHAR(MAX))
AS
BEGIN
	DECLARE @SQLString NVARCHAR(MAX)
	SET @SQLString =	'SELECT *
						FROM tblFilm
						WHERE YEAR(FilmReleaseDate) IN (' + @YearList + 
						') ORDER BY FilmReleaseDate'
	EXEC sp_executesql @SQLString
END

EXEC spFilmYears '2000,2001,2002'


-- Parameters of sp_exectuesql
EXEC sp_executesql
N'SELECT FilmName, FilmReleaseDate, FilmRunTimeMinutes
FROM tblFilm
WHERE FilmRunTimeMinutes > @Length AND
FilmReleaseDate > @StartDate',
N'@Length INT, @StartDate DATETIME',
@Length = 180, 
@StartDate = '2000-01-01'
