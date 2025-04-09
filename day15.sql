---1
WITH cte AS(
SELECT 
EXTRACT(YEAR FROM transaction_date) AS year,
product_id,
SUM(spend) AS curr_year_spend	
FROM user_transactions
GROUP BY EXTRACT(YEAR FROM transaction_date), product_id
)
SELECT
*,
LAG(curr_year_spend) OVER (PARTITION BY product_id ORDER BY year) AS prev_year_spend,
ROUND((curr_year_spend / (LAG(curr_year_spend) OVER (PARTITION BY product_id ORDER BY year))-1)*100,2) AS yoy_rate
FROM cte;

