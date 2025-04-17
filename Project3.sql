SELECT * FROM sales_dataset_rfm_prj;

---1) Doanh thu theo từng ProductLine, Year  và DealSize?
---Output: PRODUCTLINE, YEAR_ID, DEALSIZE, REVENUE

SELECT PRODUCTLINE, YEAR_ID, DEALSIZE, 
SUM(sales) AS REVENUE
FROM sales_dataset_rfm_prj
GROUP BY PRODUCTLINE, YEAR_ID, DEALSIZE
ORDER BY PRODUCTLINE, YEAR_ID, DEALSIZE;

---2) Đâu là tháng có bán tốt nhất mỗi năm?
---Output: MONTH_ID, REVENUE, ORDER_NUMBER

SELECT 
RANK() OVER (ORDER BY SUM(sales) DESC, COUNT(ordernumber) DESC),
month_id,
SUM(sales) AS REVENUE,
COUNT(ordernumber) AS ORDER_NUMBER
FROM sales_dataset_rfm_prj
GROUP BY month_id;

---3) Product line nào được bán nhiều ở tháng 11?
---Output: MONTH_ID, REVENUE, ORDER_NUMBER

SELECT
RANK() OVER (ORDER BY SUM(sales) DESC, COUNT(ordernumber) DESC),
productline,
SUM(sales) AS REVENUE,
COUNT(ordernumber) AS ORDER_NUMBER
FROM sales_dataset_rfm_prj
WHERE month_id = 11
GROUP BY productline;

---4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
---Xếp hạng các các doanh thu đó theo từng năm.
---Output: YEAR_ID, PRODUCTLINE,REVENUE, RANK

SELECT 
year_id,
productline,
SUM(sales) AS REVENUE,
RANK() OVER (PARTITION BY year_id ORDER BY SUM(sales) DESC)
FROM sales_dataset_rfm_prj
GROUP BY year_id, productline

---5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM 

CREATE TABLE segment_score (
	segment VARCHAR,
	scores VARCHAR
	);

SELECT * FROM segment_score;

---B1: tinh R-F-M
WITH rfm_calculation AS(
	SELECT
	customername,
	CURRENT_DATE - MAX(orderdate) AS R,
	COUNT(ordernumber) AS F,
	SUM(sales) AS M
	FROM sales_dataset_rfm_prj
	GROUP BY customername
)

---B2: Chia các giá trị thành các khoảng trên thang điểm 1-5
, rfm_score AS(
	SELECT 
	customername,
	CONCAT(
		NTILE(5) OVER(ORDER BY R DESC),
		NTILE(5) OVER (ORDER BY F),
		NTILE(5) OVER (ORDER BY M)
		) AS rfm_score
	FROM rfm_calculation
)
---B3: Phân nhóm theo tổ hợp R-F-M

SELECT 
rfm.customername,
s.segment
FROM rfm_score rfm
LEFT JOIN segment_score s
ON rfm.rfm_score = s.scores
WHERE s.segment = 'Champions';

