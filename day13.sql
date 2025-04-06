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
