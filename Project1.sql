---CREATE DATABASE
CREATE DATABASE Project;

---CREATE TABLE
create table SALES_DATASET_RFM_PRJ
(
  ordernumber VARCHAR,
  quantityordered VARCHAR,
  priceeach        VARCHAR,
  orderlinenumber  VARCHAR,
  sales            VARCHAR,
  orderdate        VARCHAR,
  status           VARCHAR,
  productline      VARCHAR,
  msrp             VARCHAR,
  productcode      VARCHAR,
  customername     VARCHAR,
  phone            VARCHAR,
  addressline1     VARCHAR,
  addressline2     VARCHAR,
  city             VARCHAR,
  state            VARCHAR,
  postalcode       VARCHAR,
  country          VARCHAR,
  territory        VARCHAR,
  contactfullname  VARCHAR,
  dealsize         VARCHAR
);

SELECT * FROM SALES_DATASET_RFM_PRJ;

---Chuyển đổi kiểu dữ liệu phù hợp cho các trường ( sử dụng câu lệnh ALTER) 

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN ordernumber
TYPE INT
USING TRIM(ordernumber)::INT;

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN quantityordered
TYPE INT
USING TRIM(quantityordered)::INT;

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN priceeach
TYPE NUMERIC(5,2)
USING TRIM(priceeach)::NUMERIC(5,2);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderlinenumber
TYPE INT
USING TRIM(orderlinenumber)::INT;

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN sales
TYPE NUMERIC(8,2)
USING TRIM(sales)::NUMERIC(8,2);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderdate
TYPE DATE
USING TRIM(orderdate)::DATE;

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN status
TYPE VARCHAR(10)
USING TRIM(status)::VARCHAR(10);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN productline
TYPE VARCHAR(16)
USING TRIM(productline)::VARCHAR(16);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN msrp
TYPE INT
USING TRIM(msrp)::INT;

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN productcode
TYPE VARCHAR(9)
USING TRIM(productcode)::VARCHAR(9);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN customername
TYPE VARCHAR(40)
USING TRIM(customername)::VARCHAR(40);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN phone
TYPE INT
USING TRIM(phone)::INT;

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN addressline1
TYPE VARCHAR(50)
USING TRIM(addressline1)::VARCHAR(50);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN addressline2
TYPE VARCHAR(50)
USING TRIM(addressline2)::VARCHAR(50);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN city
TYPE VARCHAR(20)
USING TRIM(city)::VARCHAR(20);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN state
TYPE VARCHAR(15)
USING TRIM(state)::VARCHAR(15);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN postalcode
TYPE VARCHAR(10)
USING TRIM(postalcode)::VARCHAR(10);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN country
TYPE VARCHAR(12)
USING TRIM(country)::VARCHAR(12);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN territory
TYPE VARCHAR(5)
USING TRIM(territory)::VARCHAR(5);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN contactfullname
TYPE VARCHAR(20)
USING TRIM(contactfullname)::VARCHAR(20);

ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN dealsize
TYPE VARCHAR(6)
USING TRIM(dealsize)::VARCHAR(6);

---Check NULL/BLANK (‘’)  ở các trường ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE

SELECT 
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(ORDERNUMBER) AS nulls_ordernumber,
    COUNT(*) - COUNT(QUANTITYORDERED) AS nulls_quantityordered,
    COUNT(*) - COUNT(PRICEEACH) AS nulls_priceeach,
    COUNT(*) - COUNT(ORDERLINENUMBER) AS nulls_orderlinenumber,
    COUNT(*) - COUNT(SALES) AS nulls_sales,
    COUNT(*) - COUNT(ORDERDATE) AS nulls_orderdate
FROM SALES_DATASET_RFM_PRJ;

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN ORDERNUMBER IS NULL THEN 1 ELSE 0 END) AS nulls_ordernumber,
    SUM(CASE WHEN QUANTITYORDERED IS NULL THEN 1 ELSE 0 END) AS nulls_quantityordered,
    SUM(CASE WHEN PRICEEACH IS NULL THEN 1 ELSE 0 END) AS nulls_priceeach,
    SUM(CASE WHEN ORDERLINENUMBER IS NULL THEN 1 ELSE 0 END) AS nulls_orderlinenumber,
    SUM(CASE WHEN SALES IS NULL THEN 1 ELSE 0 END) AS nulls_sales,
    SUM(CASE WHEN ORDERDATE IS NULL THEN 1 ELSE 0 END) AS nulls_orderdate
FROM SALES_DATASET_RFM_PRJ;

SELECT *
FROM SALES_DATASET_RFM_PRJ
WHERE ORDERNUMBER IS NULL
   OR QUANTITYORDERED IS NULL
   OR PRICEEACH IS NULL
   OR ORDERLINENUMBER IS NULL
   OR SALES IS NULL
   OR ORDERDATE IS NULL;

/*
Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME . 
Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên viết hoa, chữ cái tiếp theo viết thường. 
Gợi ý: ( ADD column sau đó UPDATE)
*/

WITH cte AS(
SELECT contactfullname,
INITCAP(LEFT(contactfullname, POSITION ('-' IN contactfullname) -1)) AS CONTACTLASTNAME,
INITCAP(RIGHT(contactfullname,LENGTH(contactfullname) - POSITION ('-' IN contactfullname))) AS CONTACTFIRSTNAME
FROM public.sales_dataset_rfm_prj
)
SELECT
MAX(LENGTH(CONTACTLASTNAME)) AS CONTACTLASTNAME,
MAX(LENGTH(CONTACTFIRSTNAME)) AS CONTACTFIRSTNAME
FROM cte;


ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN CONTACTLASTNAME VARCHAR(11);

ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN CONTACTFIRSTNAME VARCHAR(10);

UPDATE sales_dataset_rfm_prj
SET CONTACTLASTNAME = INITCAP(LEFT(contactfullname, POSITION ('-' IN contactfullname) -1));

UPDATE sales_dataset_rfm_prj
SET CONTACTFIRSTNAME = INITCAP(RIGHT(contactfullname,LENGTH(contactfullname) - POSITION ('-' IN contactfullname)));

SELECT * FROM sales_dataset_rfm_prj;

---Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE 
SELECT
ORDERDATE,
EXTRACT(QUARTER FROM ORDERDATE) AS QTR_ID,
EXTRACT(MONTH FROM ORDERDATE) AS MONTH_ID,
EXTRACT(YEAR FROM ORDERDATE) AS YEAR_ID
FROM sales_dataset_rfm_prj;

ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN QTR_ID INT;

ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN MONTH_ID INT;

ALTER TABLE public.sales_dataset_rfm_prj
ADD COLUMN YEAR_ID INT;

UPDATE sales_dataset_rfm_prj
SET QTR_ID = EXTRACT(QUARTER FROM ORDERDATE);

UPDATE sales_dataset_rfm_prj
SET MONTH_ID = EXTRACT(MONTH FROM ORDERDATE);

UPDATE sales_dataset_rfm_prj
SET YEAR_ID = EXTRACT(YEAR FROM ORDERDATE);


---Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED và hãy chọn cách xử lý cho bản ghi đó (2 cách) ( Không chạy câu lệnh trước khi bài được review)

SELECT QUANTITYORDERED FROM sales_dataset_rfm_prj;

---SU DUNG BOXPLOT
WITH cte AS(
SELECT Q1 - 1.5 * IQR AS min_value,
Q3 + 1.5 * IQR AS max_value
FROM(
	SELECT
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q1,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q3,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS IQR
	FROM sales_dataset_rfm_prj
	)
)
SELECT * FROM sales_dataset_rfm_prj
WHERE QUANTITYORDERED < (SELECT min_value FROM cte)
OR QUANTITYORDERED > (SELECT max_value FROM cte)


---su dung z score
SELECT
QUANTITYORDERED,
(SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS avg,
(SELECT STDDEV(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS stddev,
(QUANTITYORDERED - (SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj))/(SELECT STDDEV(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS z_score
FROM sales_dataset_rfm_prj
WHERE ABS((QUANTITYORDERED - (SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj))/(SELECT STDDEV(QUANTITYORDERED) FROM sales_dataset_rfm_prj)) > 4;


---update outlier bằng AVG

WITH cte AS(
SELECT
QUANTITYORDERED,
(SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS avg,
(SELECT STDDEV(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS stddev,
(QUANTITYORDERED - (SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj))/(SELECT STDDEV(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS z_score
FROM sales_dataset_rfm_prj
WHERE ABS((QUANTITYORDERED - (SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj))/(SELECT STDDEV(QUANTITYORDERED) FROM sales_dataset_rfm_prj)) > 4
)
UPDATE sales_dataset_rfm_prj
SET QUANTITYORDERED = (SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj)
WHERE QUANTITYORDERED IN (SELECT QUANTITYORDERED FROM cte);

---delete outlier
WITH cte AS(
SELECT
QUANTITYORDERED,
(SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS avg,
(SELECT STDDEV(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS stddev,
(QUANTITYORDERED - (SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj))/(SELECT STDDEV(QUANTITYORDERED) FROM sales_dataset_rfm_prj) AS z_score
FROM sales_dataset_rfm_prj
WHERE ABS((QUANTITYORDERED - (SELECT AVG(QUANTITYORDERED) FROM sales_dataset_rfm_prj))/(SELECT STDDEV(QUANTITYORDERED) FROM sales_dataset_rfm_prj)) > 4
)
DELETE FROM sales_dataset_rfm_prj
WHERE QUANTITYORDERED IN (SELECT QUANTITYORDERED FROM cte);

---Sau khi làm sạch dữ liệu, hãy lưu vào bảng mới  tên là SALES_DATASET_RFM_PRJ_CLEAN

CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS (
SELECT *
FROM sales_dataset_rfm_prj);

