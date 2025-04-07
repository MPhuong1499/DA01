---1
WITH count_duplicate AS 
(SELECT company_id, title, description, COUNT(*)
FROM job_listings
GROUP BY company_id, title, description
HAVING COUNT(*) > 1)
SELECT COUNT(company_id) AS duplicate_companies 
FROM count_duplicate;

---2
WITH cte AS ( 
SELECT 
category, 
product, 
SUM(spend) AS total_spend,
RANK() OVER (
        PARTITION BY category
        ORDER BY SUM(spend) DESC
    ) AS spending_rank
FROM product_spend
WHERE EXTRACT(YEAR FROM transaction_date) = 2022 
GROUP BY category, product
)
SELECT category, product, total_spend
FROM cte 
WHERE spending_rank <= 2;

---3
WITH cte AS
(SELECT policy_holder_id, COUNT(case_id)
FROM callers
GROUP BY policy_holder_id
HAVING COUNT(case_id) >= 3)
SELECT COUNT(*) AS policy_holder_count
FROM cte;

---4
SELECT p.page_id
FROM pages p
LEFT JOIN page_likes pl
ON p.page_id = pl.page_id
WHERE pl.page_id IS NULL;

---5
WITH active_user_id AS
(SELECT user_id
FROM user_actions
WHERE EXTRACT (MONTH FROM event_date) = 7
GROUP BY user_id,EXTRACT (MONTH FROM event_date)
INTERSECT
SELECT user_id
FROM user_actions
WHERE EXTRACT (MONTH FROM event_date) = 6
GROUP BY user_id,EXTRACT (MONTH FROM event_date))
SELECT 7 AS month,
COUNT(*) AS monthly_active_users
FROM active_user_id;
  
---6
SELECT
TO_CHAR(trans_date, 'yyyy-mm') AS month,
country,
COUNT(id) AS trans_count,
SUM (CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
SUM(amount) AS trans_total_amount,
SUM (CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transactions
GROUP BY TO_CHAR(trans_date, 'yyyy-mm'), country

---cte approach
WITH transactions1 AS (
    SELECT
        TO_CHAR(trans_date, 'YYYY-MM') AS month,
        country,
        COUNT(*) AS trans_count,
        SUM(amount) AS trans_total_amount
    FROM Transactions
    GROUP BY TO_CHAR(trans_date, 'YYYY-MM'), country
),
approved_transactions AS (
    SELECT
        TO_CHAR(trans_date, 'YYYY-MM') AS month,
        country,
        COUNT(*) AS approved_count,
        SUM(amount) AS approved_total_amount
    FROM Transactions
    WHERE state = 'approved'
    GROUP BY TO_CHAR(trans_date, 'YYYY-MM'), country
)

SELECT 
    t.month,
    t.country,
    t.trans_count,
    COALESCE(a.approved_count, 0) AS approved_count,
    t.trans_total_amount,
    COALESCE(a.approved_total_amount, 0) AS approved_total_amount
FROM transactions1 t
LEFT JOIN approved_transactions a
ON t.country IS NOT DISTINCT FROM a.country AND t.month = a.month; ---Therefore, when t.country is NULL (from transactions) and a.country is NULL (from approved_transactions), the condition t.country = a.country does not match, because NULL = NULL is not TRUE. To handle NULL values correctly in the join, we need to treat NULL as equal to NULL. In PostgreSQL, you can use the IS NOT DISTINCT FROM operator, which considers NULL equal to NULL and non-NULL values equal if they match:
        
        ---- other approach
SELECT 
    TO_CHAR(trans_date, 'YYYY-MM') AS month,
    country,
    COUNT(*) AS trans_count,
    COUNT(*) FILTER (WHERE state = 'approved') AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(amount) FILTER (WHERE state = 'approved') AS approved_total_amount
FROM Transactions
GROUP BY TO_CHAR(trans_date, 'YYYY-MM'), country;

---7
WITH cte AS
(SELECT product_id,
MIN(year) AS first_year
FROM Sales
GROUP BY product_id)
SELECT c.product_id, first_year, quantity, price 
FROM Sales s
JOIN cte c
ON s.product_id = c.product_id AND s.year = c.first_year;

---8
SELECT
customer_id
FROM Customer
WHERE product_key IN (SELECT DISTINCT product_key FROM Product)
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT (*) FROM Product)

---9
SELECT e.employee_id FROM Employees e
LEFT JOIN Employees m
ON e.manager_id = m.employee_id
WHERE e.salary < 30000
AND m.employee_id IS NULL
AND e.manager_id IS NOT NULL
ORDER BY e.employee_id

SELECT employee_id
FROM Employees 
WHERE salary < 30000 AND manager_id NOT IN (
    SELECT employee_id FROM Employees
)
ORDER BY employee_id

---10
SELECT 
    o.employee_id,
    e.department_id
FROM
    (SELECT employee_id
    FROM Employee
    GROUP BY employee_id
    HAVING COUNT(department_id) =1) AS o
LEFT JOIN Employee e
ON o.employee_id = e.employee_id
UNION
SELECT employee_id, department_id
FROM Employee
WHERE primary_flag = 'Y'

        ---other approach
SELECT employee_id, department_id FROM Employee WHERE employee_id IN (
SELECT employee_id FROM Employee
GROUP BY employee_id HAVING COUNT(*) =1) OR primary_flag = 'Y'

---11
(SELECT name AS results
FROM Users u
LEFT JOIN MovieRating mr
ON u.user_id = mr.user_id
GROUP BY name
ORDER BY COUNT(mr.user_id) DESC, name
LIMIT 1)
UNION ALL
(SELECT title AS results
FROM Movies m 
LEFT JOIN MovieRating mr
ON m.movie_id = mr.movie_id
WHERE EXTRACT (MONTH FROM created_at) = 2 AND EXTRACT (YEAR FROM created_at) = 2020
GROUP BY title
ORDER BY AVG(rating) DESC, title
LIMIT 1)

---12
WITH cte AS (
SELECT requester_id AS user_id, COUNT(accepter_id) AS friend
FROM RequestAccepted
GROUP BY requester_id
UNION ALL
SELECT accepter_id AS user_id, COUNT(requester_id) AS friend
FROM RequestAccepted
GROUP BY accepter_id)
SELECT 
user_id AS id,
SUM(friend) AS num
FROM cte
GROUP BY user_id
ORDER BY SUM(friend) DESC
LIMIT 1

        ---other approach
SELECT user_id AS id, COUNT(*) AS num
FROM
    (SELECT requester_id AS user_id FROM RequestAccepted
    UNION ALL 
    SELECT accepter_id AS user_id FROM RequestAccepted)
GROUP BY user_id
ORDER BY COUNT(*) DESC
LIMIT 1


