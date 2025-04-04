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

---MID COURSE TEST
---1
SELECT DISTINCT replacement_cost FROM film ORDER BY replacement_cost;

---2
SELECT
CASE
	WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
	WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
	WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'high'
END AS categoty,
COUNT(film_id) AS number_of_film
FROM film
GROUP BY categoty;

---3
SELECT
	f.title,
	f.length,
	c.name
FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON fc.category_id = c.category_id
WHERE c.name IN ('Drama', 'Sports')
ORDER BY f.length DESC;

---4
SELECT
	c.name AS category,
	COUNT(f.title) AS number_of_film
FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY COUNT(f.title) DESC;

---5
SELECT 
a.first_name,
a.last_name,
COUNT (film_id) AS number_of_film
FROM actor a
LEFT JOIN film_actor fa
ON a.actor_id = fa.actor_id
GROUP BY a.first_name, a.last_name
ORDER BY number_of_film DESC;

---6
SELECT 
	COUNT (a.address_id)
FROM address a
LEFT JOIN customer c
ON a.address_id = c.address_id
WHERE c.address_id IS NULL;

---7
SELECT 
ct.city,
SUM(p.amount) AS total_revenue
FROM city ct
LEFT JOIN address a
ON ct.city_id = a.city_id
LEFT JOIN customer c
ON a.address_id = c.address_id
LEFT JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY ct.city
HAVING SUM(p.amount) IS NOT NULL
ORDER BY SUM(p.amount) DESC;

---8
SELECT 
country.country || ', ' || ct.city,
SUM(p.amount) AS total_revenue
FROM country
LEFT JOIN city ct
ON country.country_id = ct.country_id
LEFT JOIN address a
ON ct.city_id = a.city_id
LEFT JOIN customer c
ON a.address_id = c.address_id
LEFT JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY country.country, ct.city
HAVING SUM(p.amount) IS NOT NULL
ORDER BY SUM(p.amount);

