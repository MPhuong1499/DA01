/*TheLook is a fictitious eCommerce clothing site developed by the Looker team. 
The dataset contains information about customers, products, orders, logistics, web events and digital marketing campaigns. 
The contents of this dataset are synthetic, and are provided to industry practitioners for the purpose of product discovery, testing, and evaluation.*/

--- Amount of Customers and Orders each months
--- Output: month_year ( yyyy-mm) , total_user, total_order

SELECT
  FORMAT_TIMESTAMP('%Y-%m', created_at) AS month_year,
  COUNT(DISTINCT user_id) AS total_user,
  COUNT(order_id) AS total_order,
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE status = 'Complete'
  AND FORMAT_TIMESTAMP('%Y-%m', created_at) BETWEEN '2019-01' AND '2022-04'
GROUP BY FORMAT_TIMESTAMP('%Y-%m', created_at)
ORDER BY FORMAT_TIMESTAMP('%Y-%m', created_at);

--- Average Order Value (AOV) and Monthly Active Customers 
--- Output: month_year ( yyyy-mm), distinct_users, average_order_value

SELECT
  FORMAT_TIMESTAMP('%Y-%m', o.created_at) AS month_year,
  ROUND(SUM(oi.sale_price) / COUNT(o.order_id),2) AS average_order_value,
  COUNT(DISTINCT o.user_id) AS distinct_users
FROM bigquery-public-data.thelook_ecommerce.orders o
JOIN bigquery-public-data.thelook_ecommerce.order_items oi
  ON o.order_id = oi.order_id
WHERE o.status = 'Complete'
  AND FORMAT_TIMESTAMP('%Y-%m', o.created_at) BETWEEN '2019-01' AND '2022-04'
GROUP BY FORMAT_TIMESTAMP('%Y-%m', o.created_at)
ORDER BY FORMAT_TIMESTAMP('%Y-%m', o.created_at);

--- Customer Segmentation by Age: Identify the youngest and oldest customers for each gender 
--- Output: full_name, gender, age, tag (youngest-oldest)

WITH gender_age AS(
  SELECT
    gender,
    MAX(age) AS max_age,
    MIN(age) AS min_age
  FROM bigquery-public-data.thelook_ecommerce.users
  WHERE FORMAT_TIMESTAMP('%Y-%m', created_at) BETWEEN '2019-01' AND '2022-04'
  GROUP BY gender
  ORDER BY gender)
  
  SELECT first_name, last_name, gender, age, 'youngest' AS tag
  FROM bigquery-public-data.thelook_ecommerce.users
  WHERE age IN (SELECT min_age FROM gender_age)
  
UNION DISTINCT
  (  
  SELECT first_name, last_name, gender, age, 'oldest' AS tag
  FROM bigquery-public-data.thelook_ecommerce.users
  WHERE age IN (SELECT max_age FROM gender_age)
    )
ORDER BY gender;

--- Top 5 products with the highest profit each month (rank each product) */
--- Output: month_year ( yyyy-mm), product_id, product_name, sales, cost, profit, rank_per_month

SELECT * FROM
(
  WITH summary AS(
  SELECT
    FORMAT_TIMESTAMP('%Y-%m', oi.created_at) AS month_year,
    p.id AS product_id,
    p.name AS product_name,
    ROUND(SUM(oi.sale_price),2) AS sales,
    ROUND(SUM(p.cost),2) AS cost,
    ROUND(SUM(oi.sale_price) - SUM(p.cost),2) AS profit
  FROM bigquery-public-data.thelook_ecommerce.products p
  INNER JOIN bigquery-public-data.thelook_ecommerce.order_items oi
    ON p.id = oi.product_id
  GROUP BY month_year, product_id, product_name
  ORDER BY month_year, product_id, product_name)
  SELECT 
    *,
    DENSE_RANK() OVER (PARTITION BY month_year ORDER BY profit DESC) AS rank_per_month
  FROM summary
  )
WHERE rank_per_month <= 5
ORDER BY month_year,rank_per_month

--- Revenue for each product category
--- Output: dates, product_category, revenue

SELECT
  FORMAT_TIMESTAMP('%Y-%m-%d', oi.created_at) AS dates,
  p.category AS product_category,
  ROUND(SUM(oi.sale_price),2) AS revenue
FROM bigquery-public-data.thelook_ecommerce.products p
LEFT JOIN bigquery-public-data.thelook_ecommerce.order_items oi
  ON p.id = oi.product_id
WHERE FORMAT_TIMESTAMP('%Y-%m-%d', oi.created_at) BETWEEN '2022-01-15' AND '2022-04-15'
GROUP BY dates, product_category
ORDER BY dates DESC, product_category

--- Metrics for required dashboard
--- Output: month, year, product_category, TPV, TPO, revenue_growth, order_growth, total_cost, total_profit, profit_to_cost_ratio

WITH cte AS(
  SELECT
    FORMAT_TIMESTAMP('%Y-%m', oi.created_at) AS month,
    EXTRACT(YEAR FROM oi.created_at) AS year,
    p.category AS product_category,
    ROUND(SUM(oi.sale_price),2) AS TPV,
    COUNT(oi.order_id) AS TPO,
    ROUND(SUM(p.cost),2) AS Total_cost,
    ROUND(SUM(oi.sale_price) - SUM(p.cost),2) AS Total_profit,
    ROUND((SUM(oi.sale_price)/ SUM(p.cost)) - 1,2) AS Profit_to_cost_ratio
  FROM bigquery-public-data.thelook_ecommerce.products p
  JOIN bigquery-public-data.thelook_ecommerce.order_items oi
  ON p.id = oi.product_id
  GROUP BY month, year, product_category
)
SELECT 
  *,
  ROUND((TPV / LAG (TPV) OVER (PARTITION BY product_category ORDER BY month)) - 1,2) || '%' AS Revenue_growth,
  ROUND((TPO / LAG (TPO) OVER (PARTITION BY product_category ORDER BY month)) -1,2) || '%' AS Order_growth
FROM cte

--- Cohort analysis

WITH collected_metrics AS (
SELECT
o.order_id,
o.user_id,
FORMAT_TIMESTAMP('%Y-%m', o.created_at) AS purchase_date,
ROUND(SUM(oi.sale_price), 2) AS spending
FROM bigquery-public-data.thelook_ecommerce.orders o
JOIN bigquery-public-data.thelook_ecommerce.order_items oi
ON o.order_id = oi.order_id
GROUP BY o.order_id, o.user_id, FORMAT_TIMESTAMP('%Y-%m', o.created_at)
),
cohort_metrics AS(
SELECT
*,
MIN(purchase_date) OVER (PARTITION BY user_id) AS cohort_date,
DATE_DIFF(
PARSE_DATE('%Y-%m', purchase_date),
PARSE_DATE('%Y-%m', MIN(purchase_date) OVER (PARTITION BY user_id)),
MONTH
) + 1 AS index_month
FROM collected_metrics)
SELECT cohort_date, index_month,
COUNT(user_id) AS cnt_user,
ROUND(SUM(spending),2) AS revenue
FROM cohort_metrics
WHERE index_month <= 4
GROUP BY cohort_date, index_month
ORDER BY cohort_date, index_month
























