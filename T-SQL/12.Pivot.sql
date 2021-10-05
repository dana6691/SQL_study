------ Pivot
--1. Basic Pivot
--2. Generating a Column List & Applying the Pivot Operator, Row Groups, Ordering the results
--3. Calculating a List of Column Headings & Storing a SQL Statement in a Variable
/*******************************************************************/
USE Movies
GO

-- Basic Pivot
SELECT c.CountryName, COUNT(f.FilmID) AS [Number of Films]
FROM tblCountry AS c
INNER JOIN tblFilm AS f
ON c.CountryID = f.FilmCountryID
GROUP BY CountryName

SELECT * FROM(
	SELECT c.CountryName, f.FilmID
	FROM tblCountry AS c
	INNER JOIN tblFilm AS f
	ON c.CountryID = f.FilmCountryID
	) 
	AS BaseData
PIVOT(COUNT(FilmID) FOR CountryName IN ([China],[France],[Germany])) AS PivotTable


-- Generating a Column List & Pivoting with row groups & Ordering the results
SELECT QUOTENAME(CountryName, '()') 
FROM tblCountry
SELECT  QUOTENAME(CountryName,'[') + ',' 
FROM tblCountry

SELECT * FROM(
		SELECT c.CountryName, YEAR(f.FilmReleaseDate) AS FilmYear, f.FilmID, DATENAME(MM,FilmReleaseDate) AS FilmMonth
		FROM tblCountry AS c
		INNER JOIN tblFilm AS f
		ON c.CountryID = f.FilmCountryID
		) AS BaseData
PIVOT(COUNT(FilmID) 
	  FOR CountryName
	  IN ([China],
[France],
[Japan],
[New Zealand],
[United Kingdom],
[United States],
[Germany],
[Russia])) AS PivotTable
ORDER BY FilmYear Desc


-- Calculating a List of Column Headings & Storing a SQL Statement in a Variable
DECLARE @ColumnNames NVARCHAR(MAX) = ''
SELECT @ColumnNames += QUOTENAME(CountryName) + ',' 
FROM tblCountry

SET @ColumnNames = LEFT(@ColumnNames, LEN(@ColumnNames)-1)
PRINT @ColumnNames


-- Concatenating a SQL Statement
DECLARE @ColumnNames NVARCHAR(MAX) = ''
DECLARE @SQL NVARCHAR(MAX) = ''
SELECT @ColumnNames += QUOTENAME(CountryName) + ',' 
FROM tblCountry

SET @ColumnNames = LEFT(@ColumnNames, LEN(@ColumnNames)-1)
SET @SQL = 
'SELECT * FROM(
	SELECT CountryName, YEAR(FilmReleaseDate) AS [FilmYear], FilmID
	FROM tblCountry AS c
	INNER JOIN tblFilm AS f
	ON c.CountryID = f.FilmCountryID
) AS BaseData
PIVOT(COUNT(FilmID) 
	  FOR CountryName
	  IN ('+ @ColumnNames + ')) AS PivotTable'

PRINT @SQL

-- Executing SQL Statement
EXECUTE sp_executesql @SQL 
