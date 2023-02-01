/*
Write a query to print total number of unique hackers who made at least  submission each day (starting on the first day of the contest),
and find the hacker_id and name of the hacker who made maximum number of submissions each day
. If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. 
The query should print this information for each day of the contest, sorted by the date.
*/

WITH CTE_1 AS (
  SELECT submission_date, hacker_id, dense_rank() OVER(partition by submission_date order by COUNT(*) DESC, hacker_id ASC) as rank1
  from submissions GROUP BY submission_date, hacker_id
),
CTE_2 AS (
  SELECT submission_date, COUNT(distinct hacker_id) as cnt 
  from submissions 
  group by submission_date
)
SELECT a.submission_date, b.cnt, a.hacker_id, c.name
FROM cte_1 a
LEFT JOIN cte_2 b
ON a.submission_date = b.submission_date
LEFT JOIN Hackers c
ON a.hacker_id = c.hacker_id
WHERE a.rank1 = 1;


WITH CTE_1 AS (
    SELECT 
        [submission_date], 
        [hacker_id],
        DAY([submission_date]) - DENSE_RANK() OVER(PARTITION BY [hacker_id] ORDER BY [submission_date]) AS 'rnk'
    FROM Submissions 
), 
CTE_2 AS ( 
    SELECT [submission_date], COUNT(DISTINCT [hacker_id]) AS 'unique_hackers'
    FROM CTE_1
    WHERE [rnk] = 0
    GROUP BY [submission_date]
),
CTE_3 AS (
    SELECT 
        [submission_date], 
        [hacker_id], 
        RANK() OVER(PARTITION BY [submission_date] ORDER BY COUNT(*) DESC, [hacker_id] ASC) AS 'rnk'
    FROM Submissions
    GROUP BY [submission_date], [hacker_id]
),
CTE_4 AS (
    SELECT [submission_date], [hacker_id]
    FROM CTE_3
    WHERE [rnk] = 1
)
SELECT 
    CTE_2.[submission_date], 
    CTE_2.[unique_hackers], 
    CTE_4.[hacker_id],
    (SELECT [name] FROM Hackers H WHERE H.[hacker_id] = CTE_4.[hacker_id])
FROM CTE_2 
LEFT JOIN CTE_4
ON CTE_2.[submission_date] = CTE_4.[submission_date];
