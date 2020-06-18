WITH 
first_date AS
(
SELECT
customer_key,
date_key,
ROW_NUMBER() OVER (PARTITION BY customer_key ORDER BY date_key) AS rank_first_order
FROM
`tiki-dwh.dwh.vw_fact_marketing_mart` 
)
,
raw_omo
AS 
(
SELECT
d1.date_key,
d2.first_order_date,
DATE_DIFF(d1.date_key,d2.first_order_date,WEEK) AS retention_window,
d1.customer_key,
FROM `tiki-dwh.dwh.vw_fact_marketing_mart` d1
LEFT JOIN 
(
SELECT
date_key as first_order_date,
customer_key,
FROM first_date WHERE rank_first_order = 1
)
d2 USING(customer_key)
WHERE d1.date_key >= DATE(2019,01,01)
AND lower(brand) = 'lifebuoy'
)

SELECT DISTINCT
"clear" product_brand,
retention_window,
count(*)/ (SELECT count(*) FROM raw_omo WHERE retention_window = 0) as retention_percentage
FROM raw_omo
WHERE retention_window <= 52
GROUP BY 1,2
ORDER BY 2 ASC