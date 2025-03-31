---1
SELECT Name
FROM STUDENTS
WHERE Marks > 75
ORDER BY RIGHT(Name, 3), ID;

---2
SELECT
user_id,
CONCAT(UPPER(LEFT(name,1)),LOWER(RIGHT(name,LENGTH(name)-1))) AS name
FROM Users
ORDER BY user_id;

---3
SELECT 
manufacturer,
CONCAT('$', ROUND(SUM(total_sales)/10^6), ' million') AS sales_mil
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY (SUM(total_sales)/10^6) DESC, manufacturer;

---4
SELECT 
EXTRACT(MONTH FROM submit_date) AS mth,
product_id AS product,
ROUND(AVG(stars),2) AS avg_stars
FROM reviews
GROUP BY product_id, EXTRACT(MONTH FROM submit_date)
ORDER BY mth, product;

---5
SELECT 
sender_id,
COUNT(message_id) AS message_count
FROM messages
WHERE EXTRACT(MONTH FROM sent_date) = 8 AND EXTRACT(YEAR FROM sent_date) = 2022
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2;

---6
SELECT tweet_id
FROM Tweets
WHERE LENGTH(content) > 15;

---7
SELECT 
activity_date AS day,
COUNT(DISTINCT user_id) AS active_users
FROM Activity
WHERE activity_date BETWEEN ('2019-07-27'::DATE - 29) AND '2019-07-27'
GROUP BY activity_date;

---8
SELECT
COUNT(id) AS number_of_hired
FROM employees
WHERE EXTRACT(MONTH FROM joining_date) BETWEEN 1 AND 7 
AND EXTRACT(YEAR FROM joining_date) = 2022
GROUP BY EXTRACT (MONTH FROM joining_date);

---9
SELECT 
POSITION ('a' IN first_name)
FROM worker
WHERE first_name = 'Amitah';

---10
SELECT title, winery,
    CASE 
        WHEN POSITION (' 1' IN title) > 0 THEN SUBSTRING(title FROM POSITION (' 1' IN title) FOR 5)
        WHEN POSITION (' 2' IN title) > 0 THEN SUBSTRING(title FROM POSITION (' 2' IN title) FOR 5)
        ELSE NULL
    END
from winemag_p2
WHERE country = 'Macedonia';

