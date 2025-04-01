---1
SELECT
SUM(CASE 
  WHEN device_type = 'laptop' THEN 1
  ELSE 0
END) AS laptop_views,
SUM(CASE 
  WHEN device_type IN ('phone', 'tablet') THEN 1
  ELSE 0
END) AS mobile_views
FROM viewership;

----using filer from discussion
SELECT
  COUNT(*) filter( WHERE device_type='laptop') as laptop_views,
  COUNT(*) filter( WHERE device_type not in ('laptop')) as mobile_views
FROM viewership;

---2
SELECT *,
    CASE
        WHEN x+y > z AND y+z > x AND x+z > y THEN 'Yes'
        ELSE 'No'
    END AS triangle
FROM Triangle;

---3
SELECT
  ROUND(100.0 * 
    SUM(CASE WHEN call_category IS NULL OR call_category = 'n/a'
      THEN 1
      ELSE 0
      END)
    /COUNT(*), 1) AS uncategorised_call_pct
FROM callers;

---4
SELECT
    name
FROM Customer
WHERE referee_id != 2 
OR referee_id IS NULL;

SELECT
    name
FROM Customer
WHERE COALESCE(referee_id, 0) != 2;

---5
SELECT 
    survived,
    SUM(CASE
        WHEN pclass = 1 THEN 1
        ELSE 0
    END) AS first_class,
    SUM(CASE
        WHEN pclass = 2 THEN 1
        ELSE 0
    END) AS second_class,
     SUM(CASE
        WHEN pclass = 3 THEN 1
        ELSE 0
    END) AS third_class
FROM titanic
GROUP BY survived;
