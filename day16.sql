---1
WITH cte AS(
SELECT *,
CASE WHEN (order_date = customer_pref_delivery_date ) THEN 'immediate'
    ELSE 'scheduled'
    END AS type,
FIRST_VALUE (order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS earliest_order
FROM Delivery
)
SELECT
ROUND(100.0*COUNT (*) / (SELECT COUNT(DISTINCT customer_id) FROM Delivery),2) AS immediate_percentage
FROM cte
WHERE order_date = earliest_order AND type = 'immediate';

---other approach from discussion
select ROUND (100.0 * sum(CASE WHEN order_date=customer_pref_delivery_date THEN 1 ELSE 0 END) / count(*) , 2) as immediate_percentage 
from Delivery 
where (customer_id, order_date) in (select customer_id, min(order_date) from Delivery group by customer_id);

---2
WITH cte AS(
SELECT *,
RANK () OVER (PARTITION BY player_id  ORDER BY event_date) AS day_rank,
LEAD(event_date) OVER (PARTITION BY player_id  ORDER BY event_date) - event_date AS diff
FROM Activity
)
SELECT ROUND(COUNT (*)::NUMERIC / (SELECT COUNT(DISTINCT player_id) FROM Activity),2) AS fraction
FROM cte
WHERE day_rank = 1 AND diff = 1

---other approach
SELECT ROUND(
    1.0 * COUNT(player_id) / 
    (SELECT COUNT(DISTINCT player_id)
    FROM Activity), 2) AS fraction
FROM Activity
WHERE (player_id, event_date) IN (
    SELECT player_id, MIN(event_date) + 1
    FROM Activity
    GROUP BY player_id
)

---3
SELECT 
s1.id,
    CASE 
        WHEN MOD(s1.id, 2) = 0 THEN (SELECT student FROM seat s2 WHERE s2.id = s1.id-1)
        WHEN s1.id = (SELECT MAX(id) FROM seat) AND MOD(s1.id, 2) = 1 THEN student
        ELSE (SELECT student FROM seat s3 WHERE s3.id = s1.id+1)
    END AS student
FROM seat s1

---other approach
SELECT 
id,
    CASE 
        WHEN MOD(id, 2) = 0 THEN LAG(student) OVER (ORDER BY id)
        WHEN id = (SELECT MAX(id) FROM seat) AND MOD(id, 2) = 1 THEN student
        ELSE LEAD(student) OVER (ORDER BY id)
    END AS student
FROM seat 

---from discussion
SELECT(
  CASE WHEN id % 2 = 1 and  id = (select max(id) from Seat) THEN id
  WHEN id % 2 = 1 THEN id + 1
  WHEN id % 2 = 0 THEN id - 1
  END ) AS id, student 
FROM Seat
ORDER BY id

---4

---5
SELECT ROUND(SUM(tiv_2016)::NUMERIC,2) AS tiv_2016
FROM Insurance
WHERE pid IN (
(SELECT
DISTINCT i1.pid
FROM Insurance i1
JOIN Insurance i2
ON i1.tiv_2015 = i2.tiv_2015
AND i1.pid <> i2.pid)
EXCEPT
(SELECT DISTINCT i1.pid
FROM Insurance i1
JOIN Insurance i2
ON i1.lat = i2.lat
AND i1.lon = i2.lon
AND i1.pid <> i2.pid)
)

---from dícussion
SELECT ROUND(SUM(tiv_2016)::NUMERIC,2) AS tiv_2016 FROM Insurance 
WHERE (tiv_2015) IN (SELECT tiv_2015 FROM Insurance GROUP BY tiv_2015 HAVING COUNT(*) > 1) AND
(lat, lon) IN (SELECT lat, lon FROM Insurance GROUP BY lat,lon HAVING count(*) = 1)



