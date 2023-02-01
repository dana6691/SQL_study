/*
Write a query to print total number of unique hackers who made at least  submission each day (starting on the first day of the contest),
and find the hacker_id and name of the hacker who made maximum number of submissions each day
. If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. 
The query should print this information for each day of the contest, sorted by the date.
*/

WITH cte_1 AS (
select b.submission_date, a.name, a.hacker_id, COUNT(*) as CNT
from submissions b
LEFT JOIN Hackers a
on a.hacker_id = b.hacker_id
GROUP BY b.submission_date, a.name, a.hacker_id
)
SELECT submission_date, CNT, hacker_id, name
FROM (
SELECT submission_date, hacker_id, name, CNT, rank()OVER(partition by submission_date order by CNT DESC, hacker_id) as rank1
FROM cte_1) as s
WHERE rank1 = 1
