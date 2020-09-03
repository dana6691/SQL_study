/*select multiple columns*/
SELECT title, release_year, country
FROM films;

/*unique*/
SELECT DISTINCT language
FROM films
LIMIT 5;

/*count*/
select count(*) from reviews; --total rows
select count(distinct birthdate) from people; -- distinct bday

/*********Intro to Relational Databases in SQL******/
/*create table*/
CREATE TABLE professor(
    firstname text,
    last name text
);

/*add column*/
ALTER TABLE professor
ADD COLUMN university_abb text;

/*rename, drop columns*/
ALTER TABLE professor
RENAME COLUMN organization TO org;

ALTER TABLE table_name
DROP COLUMN column_name;

/*insert into new table*/
INSERT INTO university_professors
SELECT DISTINCT firstname, lastname, university_abb 
FROM professor;

/*drop table*/
DROP TABLE university_professors;






/******T-SQL************/
/*aggregation*/
SELECT Avg(DurationSeconds) AS Average, 
       Min(DurationSeconds) AS Minimum, 
       Max(DurationSeconds) AS Maximum
FROM Incidents

-- by group Shape + filter by HAVING clause
SELECT Shape,
       AVG(DurationSeconds) AS Average, 
       MIN(DurationSeconds) AS Minimum, 
       MAX(DurationSeconds) AS Maximum
FROM Incidents
GROUP BY Shape 
HAVING MIN(DurationSeconds) > 1

/*missing data*/
SELECT IncidentDateTime, IncidentState
FROM Incidents
WHERE IncidentState IS NOT NULL; -- exclude all

SELECT IncidentState, ISNULL(IncidentState, City) as LOCATION
FROM Incidents
WHERE IncidentState IS NULL; -- replace missing value with City

SELECT Country, COALESCE(Country, IncidentState, City) AS Location
FROM Incidents
WHERE Country IS NULL; -- replace missing value with IncidentState or City

/*case statement*/
-- new column SourceCountry
SELECT Country, 
       CASE WHEN Country = 'us'  THEN 'USA'
       ELSE 'International'
       END AS SourceCountry
FROM Incidents 

-- multiple cases
SELECT DurationSeconds, 
      CASE WHEN (DurationSeconds <= 120) THEN 1       
       WHEN (DurationSeconds > 120 AND DurationSeconds <= 600) THEN 2          
       WHEN (DurationSeconds > 601 AND DurationSeconds <= 1200) THEN 3             
       WHEN (DurationSeconds > 1201 AND DurationSeconds <= 5000) THEN 4   
       ELSE 5 
       END AS SecondGroup   
FROM Incidents 


/******SQL Server************/
/* 
CONVERT(DATE, startdate): convert to Format YYYY-MM-DD
DATEPART: return as a string
DATENAME: return as a integer
DATEDIFF: difference between two
*/

-- # of transactions per day
SELECT CONVERT(DATE, StartDate) as StartDate,
       COUNT(ID) as CountofRows
FROM CapitalBikeShare 
GROUP BY CONVERT(DATE, StartDate)
ORDER BY CONVERT(DATE, StartDate);

-- # of Second = 0 or Second > 0?
SELECT COUNT(ID) as Count,
       "StartDate" = CASE WHEN DATEPART(SECOND, StartDate) = 0 THEN 'SECONDS = 0'
					      WHEN DATEPART(SECOND, StartDate) > 0 THEN 'SECONDS > 0' END
FROM CapitalBikeShare
GROUP BY
	CASE WHEN DATEPART(SECOND, StartDate) = 0 THEN 'SECONDS = 0'
		 WHEN DATEPART(SECOND, StartDate) > 0 THEN 'SECONDS > 0' END

-- busiest day of week
SELECT 
	DATENAME(weekday, StartDate) as DayOfWeek,
	SUM(DATEDIFF(second, StartDate, EndDate))/ 3600 as TotalTripHours 
FROM CapitalBikeShare 
GROUP BY DATENAME(weekday, StartDate)
ORDER BY TotalTripHours DESC

-- totalride on saturday
SELECT
  	SUM(DATEDIFF(SECOND, StartDate, EndDate))/ 3600 AS TotalRideHours,
  	CONVERT(DATE, StartDate) AS DateOnly,
  	DATENAME(WEEKDAY, CONVERT(DATE, StartDate)) AS DayOfWeek 
FROM CapitalBikeShare
WHERE DATENAME(WEEKDAY, StartDate) = 'Saturday' 
GROUP BY CONVERT(DATE, StartDate);


-- Create @ShiftStartTime
DECLARE @ShiftStartTime AS time = '08:00 AM'

-- Create @StartDate
DECLARE @StartDate AS date

-- Set StartDate to the first StartDate from CapitalBikeShare
Set 
	@StartDate = (
    	SELECT TOP 1 StartDate 
    	FROM CapitalBikeShare 
    	ORDER BY StartDate ASC
		)

-- Create ShiftStartDateTime
DECLARE @ShiftStartDateTime AS datetime

-- Cast StartDate and ShiftStartTime to datetime data types
SET @ShiftStartDateTime = CAST(@ShiftStartTime AS datetime) + CAST(@StartDate AS datetime) 

SELECT @ShiftStartDateTime



-- Declare @Shifts as a TABLE
DECLARE @Shifts TABLE(
    -- Create StartDateTime column
	StartDateTime datetime,
    -- Create EndDateTime column
	EndDateTime datetime)
-- Populate @Shifts
INSERT INTO  @Shifts (StartDateTime, EndDateTime)
	SELECT '3/1/2018 8:00 AM', '3/1/2018 4:00 PM'
SELECT * 
FROM @Shifts


-- Declare @RideDates
Declare @RideDates TABLE(
    -- Define RideStart column
	RideStart date, 
    -- Define RideEnd column
    RideEnd date)
-- Populate @RideDates
INSERT INTO @RideDates(RideStart, RideEnd)
-- Select the unique date values of StartDate and EndDate
SELECT distinct
    -- Cast StartDate as date
	CAST(StartDate as date),
    -- Cast EndDate as date
	CAST(EndDate as date) 
FROM CapitalBikeShare 
SELECT * 
FROM @RideDates




SELECT DATEDIFF(month, '2018/02/26', '2018/3/3') AS DateDiff;

-- Find the first day of the current month
SELECT DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)




/****intermediate SQL********/
/*IN*/
SELECT team_long_name,team_api_id
FROM teams_germany
WHERE team_long_name IN ('FC Schalke 04', 'FC Bayern Munich');

/*case*/
SELECT 
	CASE WHEN hometeam_id = 10189 THEN 'FC Schalke 04'
         WHEN hometeam_id = 9823 THEN 'FC Bayern Munich'
         ELSE 'Other' END AS home_team,
	COUNT(id) AS total_matches
FROM matches_germany
GROUP BY home_team;

-- case, leftjoin
SELECT 
	m.date,
	t.team_long_name AS opponent,
	CASE WHEN m.home_goal > m.away_goal THEN 'Barcelona win!'
        WHEN m.home_goal < m.away_goal THEN 'Barcelona loss :(' 
        ELSE 'Tie' END AS outcome 
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
ON m.awayteam_id = t.team_api_id;

SELECT 
	date,
	CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END as home,
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona' 
         ELSE 'Real Madrid CF' END as away,
	-- Identify all possible match outcomes
	CASE WHEN home_goal > away_goal AND hometeam_id = 8634 THEN 'Barcelona win!'
        WHEN home_goal > away_goal AND hometeam_id = 8633 THEN 'Real Madrid win!'
        WHEN home_goal < away_goal AND awayteam_id = 8634 THEN 'Barcelona win!'
        WHEN home_goal < away_goal AND awayteam_id = 8633 THEN 'Real Madrid win!'
        ELSE 'Tie!' END AS outcome
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);

-- case, filter
SELECT 
	season,
	date,
	home_goal,
	away_goal
FROM matches_italy
WHERE
	CASE WHEN hometeam_id = 9857 AND home_goal > away_goal THEN 'Bologna Win'
         WHEN awayteam_id = 9857 AND away_goal > home_goal THEN 'Bologna Win' 
         END IS NOT NULL;

-- case aggregation
SELECT 
	c.name AS country,
	COUNT(CASE WHEN m.season = '2012/2013' 
        	THEN m.id ELSE NULL END) AS matches_2012_2013
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
GROUP By country;

-- case, ROUND, AVG
SELECT 
	c.name AS country,
    -- Round the percentage of tied games to 2 decimal points
	ROUND(AVG(CASE WHEN m.season='2013/2014' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2013_2014,
	ROUND(AVG(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;