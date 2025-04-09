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

---2
SELECT
DISTINCT card_name,
FIRST_VALUE(issued_amount) OVER(PARTITION BY card_name ORDER BY issue_year,issue_month) AS issued_amount
FROM monthly_cards_issued
ORDER BY issued_amount DESC;

---3
WITH cte AS(
SELECT *,
RANK () OVER (PARTITION BY user_id ORDER BY transaction_date) AS ranking
FROM transactions
)
SELECT user_id, spend, transaction_date
FROM cte 
WHERE ranking = 3;

---4
WITH cte AS(
SELECT 
transaction_date,
user_id,
COUNT(product_id) AS purchase_count,
FIRST_VALUE(transaction_date) OVER (PARTITION BY user_id ORDER BY transaction_date DESC) AS recent_date
FROM user_transactions
GROUP BY transaction_date, user_id
)
SELECT 
transaction_date,
user_id,
purchase_count
FROM cte 
WHERE transaction_date = recent_date
ORDER BY transaction_date;

--- other approach from discussion
SELECT 
transaction_date,
user_id,
COUNT(product_id)
FROM user_transactions
WHERE 
(user_id,transaction_date) IN (SELECT user_id,MAX(transaction_date) FROM user_transactions GROUP BY user_id)
GROUP BY 2,1
ORDER BY 1

---5
SELECT    
  user_id,    
  tweet_date,   
  ROUND(AVG(tweet_count) OVER (
    PARTITION BY user_id     
    ORDER BY tweet_date     
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)  ---Defines the window as the current row and the 2 preceding rows (up to 3 days total, including the current day).
  ,2) AS rolling_avg_3d
FROM tweets;


---6
