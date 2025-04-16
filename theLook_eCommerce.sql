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
--- step_1: find the first purchased date + selecting needed data

WITH selected_data AS(
  SELECT 
    user_id,
    CAST(created_at AS DATE) AS created_at,
    CAST(MIN(created_at) OVER (PARTITION BY user_id) AS DATE) AS first_date
  FROM bigquery-public-data.thelook_ecommerce.order_items
  WHERE FORMAT_DATE('%Y-%m', created_at) BETWEEN '2021-05' AND '2022-04'
)

-- step_2: monthly difference from the first purchase time (index column)

, index_data AS (
  SELECT 
    FORMAT_TIMESTAMP('%Y-%m', first_date) AS cohort_date,
    DATE_DIFF(created_at, first_date, MONTH)+1 AS index_month,
    user_id
  FROM selected_data
)
-- step_3: total revenue and total customer 

, summary_table AS ( 
  SELECT 
  cohort_date,
  index_month,
  COUNT(DISTINCT user_id) AS cnt_customer
  FROM index_data
  WHERE index_month <=12
  GROUP BY cohort_date, index_month
  ORDER BY cohort_date, index_month
)
-- step_4: Cohort Chart = Pivot CASE-WHEN

, cohort_table AS (
SELECT  cohort_date,
        SUM(CASE WHEN index_month = 1 then cnt_customer ELSE 0 END) as t1,
        SUM(CASE WHEN index_month = 2 then cnt_customer ELSE 0 END) as t2,
        SUM(CASE WHEN index_month = 3 then cnt_customer ELSE 0 END) as t3,
        SUM(CASE WHEN index_month = 4 then cnt_customer ELSE 0 END) as t4,
	      SUM(CASE WHEN index_month = 5 then cnt_customer ELSE 0 END) as t5,
        SUM(CASE WHEN index_month = 6 then cnt_customer ELSE 0 END) as t6,
        SUM(CASE WHEN index_month = 7 then cnt_customer ELSE 0 END) as t7,
        SUM(CASE WHEN index_month = 8 then cnt_customer ELSE 0 END) as t8,
	      SUM(CASE WHEN index_month = 9 then cnt_customer ELSE 0 END) as t9,
        SUM(CASE WHEN index_month = 10 then cnt_customer ELSE 0 END) as t10,
        SUM(CASE WHEN index_month = 11 then cnt_customer ELSE 0 END) as t11,
        SUM(CASE WHEN index_month = 12 then cnt_customer ELSE 0 END) as t12
FROM summary_table
GROUP BY cohort_date
ORDER BY cohort_date
)

-- Retention Cohort 
, retention_cohort AS(
SELECT  cohort_date,
        ROUND(100.00* t1 / t1 ,2) as t1,
        ROUND(100.00* t2 / t1 ,2) as t2,
        ROUND(100.00* t3 / t1 ,2) as t3,
        ROUND(100.00* t4 / t1 ,2) as t4,
	      ROUND(100.00* t5 / t1 ,2) as t5,
        ROUND(100.00* t6 / t1 ,2) as t6,
        ROUND(100.00* t7 / t1 ,2) as t7,
        ROUND(100.00* t8 / t1 ,2) as t8,
	      ROUND(100.00* t9 / t1 ,2) as t9,
        ROUND(100.00* t10 / t1 ,2) as t10,
        ROUND(100.00* t11 / t1 ,2) as t11,
        ROUND(100.00* t12 / t1 ,2) as t12
FROM cohort_table
)
-- Churn Cohort
SELECT  cohort_date,
        ROUND(100 - 100.00* t1 / t1 ,2) as t1,
        ROUND(100 - 100.00* t2 / t1 ,2) as t2,
        ROUND(100 - 100.00* t3 / t1 ,2) as t3,
        ROUND(100 - 100.00* t4 / t1 ,2) as t4,
	      ROUND(100 - 100.00* t5 / t1 ,2) as t5,
        ROUND(100 - 100.00* t6 / t1 ,2) as t6,
        ROUND(100 - 100.00* t7 / t1 ,2) as t7,
        ROUND(100 - 100.00* t8 / t1 ,2) as t8,
	      ROUND(100 - 100.00* t9 / t1 ,2) as t9,
        ROUND(100 - 100.00* t10 / t1 ,2) as t10,
        ROUND(100 - 100.00* t11 / t1 ,2) as t11,
        ROUND(100 - 100.00* t12 / t1 ,2) as t12
FROM retention_cohort





















