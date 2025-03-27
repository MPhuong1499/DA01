---1
SELECT NAME FROM CITY WHERE COUNTRYCODE = 'USA' AND POPULATION >= 120000;
---2
SELECT * FROM CITY WHERE COUNTRYCODE = 'JPN';
---3
SELECT CITY, STATE FROM STATION;
---4
SELECT DISTINCT CITY FROM STATION WHERE CITY LIKE 'A%' OR CITY LIKE 'E%'OR CITY LIKE 'I%' OR CITY LIKE 'O%'OR CITY LIKE 'U%';
---5
SELECT DISTINCT CITY FROM STATION WHERE LOWER(CITY) LIKE '%a' OR LOWER(CITY) LIKE '%e' OR LOWER(CITY) LIKE '%i' OR LOWER(CITY) LIKE '%o' OR LOWER(CITY) LIKE '%u';
---6
SELECT DISTINCT CITY FROM STATION WHERE NOT (CITY LIKE 'A%' OR CITY LIKE 'E%'OR CITY LIKE 'I%' OR CITY LIKE 'O%' OR CITY LIKE 'U%');
---7
SELECT name FROM Employee ORDER BY name ASC;
---8
SELECT name FROM Employee WHERE salary >= 2000 AND months < 10 ORDER BY employee_id;
---9
SELECT product_id 
FROM Products
WHERE low_fats = 'Y'
AND recyclable = 'Y';
---10
SELECT name FROM Customer
WHERE referee_id != 2 OR referee_id IS NULL;
---11
SELECT name, population, area 
FROM World
WHERE area >= 3000000
OR population >= 25000000;
---12
SELECT name, population, area 
FROM World
WHERE area >= 3000000
OR population >= 25000000;
---13
SELECT part, assembly_step
FROM parts_assembly
WHERE finish_date IS NULL;
---14
select * from lyft_drivers
where yearly_salary <= 30000
or yearly_salary >= 70000;
---15
select advertising_channel from uber_advertising
where money_spent > 100000
and year = 2019;
