---1
SELECT DISTINCT CITY FROM STATION WHERE MOD(ID, 2) = 0;
---2
SELECT COUNT(CITY) - COUNT(DISTINCT CITY) FROM STATION;
---3
/*Samantha was tasked with calculating the average monthly salaries for all employees in the EMPLOYEES table, but did not realize her keyboard's  key was broken until after completing the calculation. She wants your help finding the difference between her miscalculation (using salaries with any zeros removed), and the actual average salary.

Write a query calculating the amount of error, and round it up to the next integer.*/
SELECT CEIL(AVG(Salary) - AVG(CAST(REPLACE(Salary, '0', '') AS UNSIGNED))) FROM EMPLOYEES; ---REPLACE(..., '0', ''): Removes all zeros
---4
SELECT ROUND((SUM (order_occurrences * item_count)/SUM(order_occurrences))::NUMERIC,1) FROM items_per_order;
---5
/*Given a table of candidates and their skills, you're tasked with finding the candidates best suited for an open Data Science job. You want to find candidates who are proficient in Python, Tableau, and PostgreSQL.
Write a query to list the candidates who possess all of the required skills for the job. Sort the output by candidate ID in ascending order.
Assumption:
There are no duplicates in the candidates table.
*/
SELECT DISTINCT candidate_id FROM candidates
WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(candidate_id) = 3; --- from discussion suggest: COUNT(skill) = 3
----other from dicussion:
SELECT candidate_id FROM candidates WHERE skill = 'Python'
INTERSECT ---The INTERSECT command in SQL is a set operation that combines the results of two or more SELECT queries and returns only the rows that are common to all queries.
SELECT candidate_id FROM candidates WHERE skill = 'Tableau'
INTERSECT  
SELECT candidate_id FROM candidates WHERE skill = 'PostgreSQL'
ORDER BY 1; 
---6
SELECT 
user_id,
MAX(post_date)::DATE - MIN(post_date)::DATE ---other way: EXTRACT (DAY FROM MAX(post_date) - MIN(post_date))
FROM posts
WHERE EXTRACT(YEAR FROM post_date) = 2021 --- solution: DATE_PART('year', post_date::DATE) = 2021 
GROUP BY user_id
HAVING COUNT(post_id) >= 2;
---7
SELECT 
card_name,
MAX(issued_amount) - MIN(issued_amount) AS difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC;
---8
SELECT 
manufacturer,
COUNT(drug) AS drug_count,
ABS(SUM(total_sales - cogs)) AS total_loss
FROM pharmacy_sales
WHERE total_sales-cogs < 0
GROUP BY manufacturer
ORDER BY total_loss DESC;
---9
SELECT 
id,
movie,
description,
rating
FROM Cinema
WHERE id%2 =1
AND NOT LOWER(description) LIKE '%boring%'
ORDER BY rating DESC;
---10
SELECT 
teacher_id,
COUNT(DISTINCT subject_id) AS cnt
FROM Teacher
GROUP BY teacher_id;
---11
SELECT 
user_id,
COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id;
---12
SELECT 
class
FROM Courses
GROUP BY class
HAVING COUNT(student) >= 5;
