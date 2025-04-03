---1
SELECT CO.CONTINENT, FLOOR(AVG(CI.POPULATION))
FROM COUNTRY CO
INNER JOIN CITY CI
ON CO.CODE = CI.COUNTRYCODE
GROUP BY CO.CONTINENT;

---2
SELECT 
  ROUND(SUM(CASE WHEN t.signup_action = 'Confirmed' THEN 1 ELSE 0 END) :: NUMERIC/COUNT(e.email_id) :: NUMERIC,2) 
  AS confirm_rate
FROM emails e
LEFT JOIN texts t
ON e.email_id = t.email_id
WHERE t.email_id IS NOT NULL;

---3
SELECT
  ag.age_bucket,
  ROUND(SUM(CASE WHEN a.activity_type LIKE 'send' THEN  a.time_spent::DECIMAL ELSE 0 END)*100.0/
    (SUM(CASE WHEN a.activity_type LIKE 'send' THEN  a.time_spent::DECIMAL ELSE 0 END) + SUM(CASE WHEN a.activity_type LIKE 'open' THEN  a.time_spent::DECIMAL ELSE 0 END)),2) AS send_perc,
  ROUND(SUM(CASE WHEN a.activity_type LIKE 'open' THEN  a.time_spent::DECIMAL ELSE 0 END)*100.0/
  (SUM(CASE WHEN a.activity_type LIKE 'send' THEN  a.time_spent::DECIMAL ELSE 0 END) + SUM(CASE WHEN a.activity_type LIKE 'open' THEN  a.time_spent::DECIMAL ELSE 0 END)),2) AS open_perc 
FROM activities a
INNER JOIN age_breakdown ag 
ON a.user_id = ag.user_id
GROUP BY ag.age_bucket;

---4
SELECT 
c.customer_id
FROM products p
full JOIN customer_contracts c
ON p.product_id = c.product_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT product_category) = 3;

---5
SELECT 
m.employee_id,
m.name,
COUNT(e.employee_id) AS reports_count,
ROUND(AVG(e.age),0) AS average_age
FROM Employees e
JOIN Employees m
ON e.reports_to = m.employee_id
GROUP BY m.employee_id, m.name
ORDER BY m.employee_id;

---6
SELECT 
p.product_name,
SUM(o.unit) AS unit
FROM Orders o
LEFT JOIN Products p
ON o.product_id = p.product_id
WHERE EXTRACT (MONTH FROM order_date) = 2 AND EXTRACT (YEAR FROM order_date) = 2020 ----WHERE DATE_FORMAT(O.order_date,'%Y-%m') ='2020-02'
GROUP BY p.product_name
HAVING SUM(o.unit) >= 100;

---7
SELECT p.page_id
FROM pages p  
LEFT JOIN page_likes l 
ON p.page_id = l.page_id
WHERE l.page_id IS NULL
ORDER BY p.page_id;

---- from discussion
SELECT page_id FROM pages
except 
SELECT page_id FROM page_likes;
