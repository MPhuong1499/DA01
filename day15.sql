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
SELECT
COUNT (*) AS payment_count
FROM transactions t1
JOIN transactions t2
ON t1.merchant_id = t2.merchant_id
AND t1.credit_card_id = t2.credit_card_id
AND t1.amount = t2.amount
AND t1.transaction_timestamp < t2.transaction_timestamp
WHERE (ABS(EXTRACT(HOUR FROM t2.transaction_timestamp - t1.transaction_timestamp)*60) + ABS(EXTRACT(MINUTE FROM t2.transaction_timestamp - t1.transaction_timestamp))) <= 10

---other from discussion
SELECT 
  COUNT(*) AS payment_count
FROM transactions AS t1
JOIN transactions AS t2
ON t1.merchant_id = t1.merchant_id
  AND t1.credit_card_id = t2.credit_card_id
  AND t1.amount = t2.amount
  AND t1.transaction_timestamp < t2.transaction_timestamp
  AND t2.transaction_timestamp - t1.transaction_timestamp <= INTERVAL '10 MINUTES';

---other approach
WITH cte AS (
SELECT *,
LEAD(transaction_timestamp) OVER (PARTITION BY merchant_id,credit_card_id,amount ORDER BY transaction_timestamp) - transaction_timestamp AS diff,
LEAD(transaction_timestamp) OVER (PARTITION BY merchant_id,credit_card_id,amount ORDER BY transaction_timestamp) AS duplicate_timestamp,
LEAD(transaction_id) OVER (PARTITION BY merchant_id,credit_card_id,amount ORDER BY transaction_timestamp) AS duplicate_transaction_id
FROM transactions
)
SELECT COUNT (*) AS payment_count 
FROM cte 
WHERE diff <= INTERVAL '10 MINUTES'

---7
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
WHERE spending_rank <= 2

---8
WITH cte AS(
SELECT 
a.artist_name,
DENSE_RANK () OVER (ORDER BY COUNT(*) DESC) AS artist_rank
FROM artists a
LEFT JOIN songs s 
ON a.artist_id = s.artist_id
LEFT JOIN global_song_rank g 
ON s.song_id = g.song_id
WHERE rank <=10
GROUP BY a.artist_name
)
SELECT * FROM cte 
WHERE artist_rank <=5
