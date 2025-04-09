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
