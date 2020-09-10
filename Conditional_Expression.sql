/*****************************************************************/
/* CASE */
/*****************************************************************/
-- less/greater
SELECT school_id, name,
       CASE 
           WHEN rate > 0 AND rate < 50 THEN 'Bad reputation'
           WHEN rate >= 50 AND rate < 80 THEN 'Average'
           ELSE 'Excellent'
       END AS rate_text
FROM school
ORDER BY rate;
-- equal
SELECT first_name, dpartment_id, salary,
       CASE dpartment_id WHEN 50 THEN 1.5*salary
                         WHEN 12 THEN 2.0*salary
       ELSE salary
       END "REVISED SALARY"
FROM Employee;
-- CASE with an aggregate function
SELECT SUM( CASE
               WHEN rate < 50 THEN 1
               ELSE 0
            END) AS "bad_school",
       SUM( CASE
               WHEN rate >= 50 AND rate < 80 THEN 1
               ELSE 0
            END) AS "medium_school",
       SUM( CASE
               WHEN rate >= 80 THEN 1
               ELSE 0
            END) AS "good_school"
FROM school;
/*****************************************************************/
/* COALESCE
- returns the first non-null argument.
- COALESCE(argument_1, argument_2,...)
- Accept unlimnited number of arguments.
- If all arguments are NULL, return NULL.
- Evaluates from left to right.*/
/*****************************************************************/
-- Net price
SELECT
	product,
	(price - COALESCE(discount,0)) AS net_price
FROM items;
GO
-- Total Salary
SELECT CAST(COALESCE(hourly_wage * 40 * 52,   
   salary,   
   commission * num_sales) AS DECIMAL(10,2)) AS TotalSalary   
FROM dbo.wages  
ORDER BY TotalSalary;  
/*****************************************************************/
/* IFNULL
- If arg1 is not NULL, returns arg1; otherwise it returns arg2 
- IFNULL(argument_1, argument_2)*/
/*****************************************************************/
SELECT IFNULL(1,0)  -- return 1
SELECT IFNULL(NULL,10) -- return 10
-- product price
SELECT ProductName, UnitPrice * (UnitsInStock + IFNULL(UnitsOnOrder, 0))
FROM Products; 
/*****************************************************************/
/* NULLIF
- If argument_1 equals to argument_2 then returns a null value. Otherwise, it returns argument_1
- NULLIF(argument_1, argument_2)*/
/*****************************************************************/
SELECT NULLIF (1, 1); -- return NULL
SELECT NULLIF (1, 0); -- return 1
SELECT NULLIF ('A', 'B'); -- return A
-- Make, FinishedGood
SELECT ProductID, MakeFlag, FinishedGoodsFlag,   
   NULLIF(MakeFlag,FinishedGoodsFlag) AS 'Null if Equal'  
FROM Production.Product  
WHERE ProductID < 10; 
/*****************************************************************/
/* IN */
SELECT * FROM employee
WHERE department_id IN (50,12);
/*****************************************************************/
/* GREATEST */
SELECT GREATEST('XYZ', null, 'xyz')
from dual;
/*****************************************************************/
