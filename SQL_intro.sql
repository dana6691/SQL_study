'''
why do we need SQL?
1) protect the data
2) share the data with team 
3) easy to deal with large size data
'''
/***********************************************************************************/
/*********Basic SQL******/
/*select multiple columns*/
SELECT title, release_year, country
FROM films;

/*limit*/
SELECT DISTINCT language
FROM films
LIMIT 5;

/*count*/
select count(*) from reviews; --total rows
select count(distinct birthdate) from people; -- distinct bday

/*where*/
SELECT Major, Major_category, ShareWomen, Unemployment_rate
FROM recent_grads
 WHERE (Major_category = 'Engineering') 
   AND (ShareWomen > 0.5 OR Unemployment_rate < 0.051);

/*order by*/
SELECT Major, ShareWomen, Unemployment_rate 
 FROM recent_grads
 WHERE ShareWomen > 0.3 
   AND Unemployment_rate < .1
 ORDER BY ShareWomen DESC;

/*min/max/count/sum/avg/round*/
SELECT COUNT(*) 'Number of Majors',
       MAX(Unemployment_rate) 'Highest Unemployment Rate'
FROM recent_grads;

SELECT AVG(Total), MIN(Men), MAX(Women)
FROM recent_grads;

SELECT ROUND(ShareWomen, 4) AS Rounded_women,
       Major_category
  FROM new_grads
 LIMIT 10;

/*unique*/
SELECT COUNT(DISTINCT Major ) unique_majors,
       COUNT(DISTINCT Major_category) unique_major_categories,
       COUNT(DISTINCT Major_code) unique_major_codes
  FROM recent_grads;

/*length of text*/
SELECT Major,
       Total, Men, Women, Unemployment_rate,
       LENGTH(Major) AS Length_of_name
  FROM recent_grads
 ORDER BY Unemployment_rate DESC
 LIMIT 3;

 /*concatenate operator*/
 SELECT 'Cat: ' || Major_category
  FROM recent_grads
 LIMIT 2;
/*concatenate operator(2)*/
 SELECT
    e1.first_name || " " || e1.last_name employee_name,
    e1.title employee_title,
    e2.first_name || " " || e2.last_name supervisor_name,
    e2.title supervisor_title
FROM employee e1
LEFT JOIN employee e2 ON e1.reports_to = e2.employee_id
ORDER BY 1;

 /*75quartile-25quartile*/
 SELECT Major, Major_category, (P75th - P25th) quartile_spread 
 FROM recent_grads 
 ORDER BY quartile_spread 
 LIMIT 20;

 /*groupby*/
 SELECT Major_category,
       SUM(Women) AS Total_women,
       AVG(ShareWomen) AS Mean_women,
       SUM(Total)*AVG(ShareWomen) AS Estimate_women
  FROM recent_grads
 GROUP BY Major_category;

 /*having*/
 SELECT Major_category,
       AVG(Low_wage_jobs) / AVG(Total) AS Share_low_wage
  FROM new_grads
 GROUP BY Major_category
HAVING share_low_wage > .1
ORDER BY Share_low_wage
LIMIT 3;

/*cast: change value to float(decimals)*/
SELECT Major_category,
       CAST(SUM(Women) as Float)/Cast(SUM(Total) as Float) AS SW
  FROM new_grads
 GROUP BY Major_category
 ORDER BY SW;

/*Subquries(1)*/
SELECT CAST(COUNT(*) as FLOAT)/(SELECT COUNT(*)
                                  FROM recent_grads
                               ) AS proportion_abv_avg
 FROM recent_grads
 WHERE ShareWomen > (SELECT AVG(ShareWomen)
                       FROM recent_grads
                    );
/*Subquries(2) - IN */
SELECT Major_category, Major
  FROM recent_grads
 WHERE Major_category IN ('Business', 'Humanities & Liberal Arts', 'Education');

 SELECT Major_category, Major
  FROM recent_grads
 WHERE Major_category IN (SELECT Major_category
                            FROM recent_grads
                           GROUP BY Major_category
                           ORDER BY SUM(TOTAL) DESC
                           LIMIT 3
                         );
/***********************************************************************************/
/*********intermediate SQL******/
/*inner join*/
SELECT c.*, f.name country_name 
FROM facts f
INNER JOIN cities c ON c.facts_id = f.id
LIMIT 5;
/*left join*/
SELECT f.name country, f.population
FROM facts f
LEFT JOIN cities c ON c.facts_id = f.id
WHERE c.name IS NULL;
/*inner join(2) with subqueries*/
SELECT
    f.name country,
    c.urban_pop,
    f.population total_pop,
    (c.urban_pop / CAST(f.population AS FLOAT)) urban_pct
FROM facts f
INNER JOIN (
            SELECT
                facts_id,
                SUM(population) urban_pop
            FROM cities
            GROUP BY 1
           ) c ON c.facts_id = f.id
WHERE urban_pct > .5
ORDER BY 4 ASC;

/*UNION/EXCEPT/INTERSECT*/
SELECT * from customer_usa
UNION
SELECT * from customer_gt_90_dollars;

SELECT * from customer_usa
EXCEPT
SELECT * from customer_gt_90_dollars;

SELECT * from customer_usa
INTERSECT
SELECT * from customer_gt_90_dollars;

/*multiple join*/
SELECT
    il.track_id,
    t.name track_name,
    mt.name track_type,
    il.unit_price,
    il.quantity
FROM invoice_line il
INNER JOIN track t ON t.track_id = il.track_id
INNER JOIN media_type mt ON mt.media_type_id = t.media_type_id
WHERE il.invoice_id = 4;

/*create VIEW*/
CREATE VIEW chinook.customer_gt_90_dollars AS 
    SELECT
        c.*
    FROM chinook.invoice i
    INNER JOIN chinook.customer c ON i.customer_id = c.customer_id
    GROUP BY 1
    HAVING SUM(i.total) > 90;
SELECT * FROM chinook.customer_gt_90_dollars;

/*LIKE*/
SELECT
    first_name,
    last_name,
    phone
FROM customer
where first_name LIKE "%belle%";

/*with*/
WITH
    customers_india AS
        (
        SELECT * FROM customer
        WHERE country = "India"
        ),
    sales_per_customer AS
        (
         SELECT
             customer_id,
             SUM(total) total
         FROM invoice
         GROUP BY 1
        )

SELECT
    ci.first_name || " " || ci.last_name customer_name,
    spc.total total_purchases
FROM customers_india ci
INNER JOIN sales_per_customer spc ON ci.customer_id = spc.customer_id
ORDER BY 1;
/***********************************************************************************/
/*********SQlite******/
/*connect, object*/
import sqlite3
conn = sqlite3.connect("jobs.db")
cursor = conn.cursor()

/*fetch first three tuples*/
cursor = conn.cursor()
query = "select major from recent_grads;"
majors = cursor.execute(query).fetchall()
print(majors[0:3])

/*fetch the first five results*/
cursor = conn.cursor()
query = "select Major,Major_category from recent_grads;"
cursor.execute(query)
five_results = cursor.fetchmany(5)

/*reverse alphabet*/
cur = conn.cursor()
query = "select Major from recent_grads order by Major desc;"
reverse_alphabetical = cur.execute(query).fetchall()
conn.close()
/***********************************************************************************/
/*******Shell******/
-- Launch the SQLite shell, connecting to the chinook.db database file
sqlite3 chinook.db
-- display tables
.tables
-- allow us to select
.mode column
-- query
SELECT track_id, name, album_id FROM track WHERE album_id =3;
-- help
.help
-- clear
.shell clear
-- quit
.quit
/*create table*/
sqlite3 new_database.db
CREATE TABLE user (
		user_id INTEGER,
		first_name TEXT,
		last_name TEXT);
.schema user
.quit
/*primary,foreign*/
sqlite3 chinook.db
CREATE TABLE wishlist (
wishlist_id INTEGER PRIMARY KEY,
customer_id INTEGER,
name TEXT,
FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
.quit
/*multiple primary,foreign*/
sqlite3 chinook.db
CREATE TABLE wishlist_track (
wishlist_id INTEGER,
track_id INTEGER,
PRIMARY KEY (wishlist_id, track_id),
FOREIGN KEY (wishlist_id) REFERENCES wishlist(wishlist_id),
FOREIGN KEY (track_id) REFERENCES track(track_id)
);
.quit
/*Insert into*/
sqlite3 chinook.db
INSERT INTO wishlist
VALUES
(1, 34, "Joao's awesome wishlist"),
(2, 18, "Amy loves pop");
INSERT INTO wishlist_track
VALUES
(1, 1158),
(1, 2646),
(1, 1990),
(2, 3272),
(2, 3470);
.quit
/*Insert into(2)*/
sqlite3 chinook.db <<EOF
INSERT INTO wishlist
VALUES
    (1, 34, "Joao's awesome wishlist"),
    (2, 18, "Amy loves pop");
INSERT INTO wishlist_track
VALUES
    (1, 1158),
    (1, 2646),
    (1, 1990),
    (2, 3272),
    (2, 3470);
EOF
/*add column*/
sqlite3 chinook.db <<EOF
ALTER TABLE wishlist
ADD COLUMN active NUMERIC;
ALTER TABLE wishlist_track
ADD COLUMN active NUMERIC;
EOF
/*wishlist, withlist_track tables*/
/*set all values for active column to 1*/
sqlite3 chinook.db <<EOF
UPDATE wishlist
SET active = 1;
UPDATE wishlist_track
SET active = 1;
EOF
/*set + add column*/
sqlite3 chinook.db <<EOF
ALTER TABLE invoice
ADD COLUMN tax NUMERIC;
ALTER TABLE invoice
ADD COLUMN subtotal NUMERIC;
UPDATE invoice
SET
    tax = 0,
    subtotal = total;
EOF
/***********************************************************************************/
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





/***********************************************************************************/
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

/***********************************************************************************/
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