#standardSQL
WITH
fact_sales_order_union AS (
SELECT 
  date_key,
  customer_key,
  original_code,
  product_key,
  sale_channel_key,
  order_type,
  platform_key,
  merchant_key
  FROM `tiki-dwh.dwh.fact_sales_order_nmv` 

UNION ALL

SELECT
  date_key,
  customer_key,
  original_code,
  product_key,
  sale_channel_key,
  order_type,
  platform_key,
  merchant_key
  FROM `tiki-dwh.dwh.fact_sales_order_nmv_2017` 

)

, fact_sales_order AS ( 
	SELECT DISTINCT
    date_key,
    customer_key AS customer_id ,
    original_code 
  FROM fact_sales_order_union
  WHERE 1=1
    AND sale_channel_key = 2
    AND order_type = 1
    AND (platform_key != 13 or platform_key is null)
    AND merchant_key not in (26,24,7,25,8,14)
    ),
	
temp AS(
	SELECT 
		fso.*,
		ROW_NUMBER() over (PARTITION BY customer_id ORDER BY date_key) AS rn
	FROM fact_sales_order  fso
	),
	
activation AS(
	SELECT 
		customer_id,
        original_code,
		date_key AS date,
    SUBSTR(FORMAT_DATE('%Y%m%d',date_key),1,6) AS month,
    EXTRACT(ISOWEEK FROM date_key) AS week
	FROM temp
	WHERE rn=1)

, last_click AS (
SELECT DISTINCT
  original_code ,
  ga_source AS source,
  ga_medium AS medium,
  campaign_name AS campaign,
  CASE
    WHEN channel_name = 'zalo' THEN 'referral'
    WHEN channel_name IN ('affiliate ecomobi','affiliate websosanh') THEN 'affiliate others'
    WHEN channel_name LIKE 'ldn%' AND channel_name <> 'ldn chin' THEN 'ldn others'
    WHEN channel_name IN ('possible internal links') THEN 'others'
    ELSE channel_name
  END AS channel,
  high_level_channel_rollup_name AS upper_channel
  FROM `tiki-dwh.dwh.fact_marketing_revenue_cost` 
  WHERE 2=2
    AND order_type = 1
    AND date_key >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY),YEAR),INTERVAL 1 YEAR)
    AND (date_key <= DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY), INTERVAL 1 YEAR)
                    OR date_key >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), MONTH), INTERVAL 4 MONTH) 
                    OR date_key >= DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), YEAR) 
                    )
)

, raw AS (
SELECT DISTINCT
	a.customer_id,
	a.date,
  a.month,
  a.week,
  SUBSTR(FORMAT_DATE('%Y%m%d',a.date),1,4) AS year,
	CASE
  WHEN campaign LIKE '%Google_Search_SEM_Gross_Gross_@NBrand Keyword_@CAll%' 
  THEN 'Google Brand'
  
  WHEN (LOWER(source) LIKE '%tiki.vn%' 
            OR source LIKE '%product%')
      AND medium LIKE '%referrer%' 
  THEN 'Apps'
  
  WHEN LOWER(campaign) LIKE '%partnership%' 
      OR campaign LIKE '%PNS%' 
  THEN 'Partnership'
  
  WHEN campaign LIKE  '%SPO%' 
  THEN 'Sponsored'
  
  WHEN campaign LIKE '%Branding%'
      OR campaign LIKE '%\\_YBR\\_%'
      OR campaign LIKE '%UM020718%' 
      OR campaign LIKE '%Back To School%' 
      OR campaign LIKE '%UM180701%' 
      OR campaign LIKE '%GDN\\_B2S%' 
      OR campaign LIKE '%DCH1808%' 
      OR campaign LIKE '%UM0%' 
      OR campaign LIKE '%_BA_%' 
      OR campaign LIKE '%YTV%' 
      OR campaign LIKE '%\\_YBA\\_%' 
      OR campaign LIKE '%Brand Awareness%'
      OR campaign LIKE '%ENG%' 
      OR campaign LIKE '%BAW%' 
      OR campaign LIKE '%REA%' 
      OR campaign LIKE '%VVI%'
  THEN 'Brand'
  
  ELSE 'Nonbrand' 
END AS strategy,
  channel,
  upper_channel
FROM activation a
LEFT JOIN last_click lc ON a.original_code = lc.original_code --AND a.date = lc.date_key ???
WHERE a.date >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY),YEAR),INTERVAL 1 YEAR)
  AND (a.date <= DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY), INTERVAL 1 YEAR)
    OR a.date >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), MONTH), INTERVAL 4 MONTH) 
    OR a.date >= DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), YEAR)
    )
  AND a.date <= DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY)
)

, data AS (
    SELECT
        customer_id,
        date,
        month,
        week,
        year,
        strategy,
        channel,
        upper_channel
        FROM raw
)

, day AS(
SELECT
    CASE
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 day)  THEN 'D-1'
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 2 day)  THEN 'D-2'
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 3 day)  THEN 'D-3'
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 4 day)  THEN 'D-4'
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 5 day)  THEN 'D-5'
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 6 day)  THEN 'D-6'
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 7 day)  THEN 'D-7'
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 8 day)  THEN 'D-8'
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 9 day)  THEN 'D-9'
    WHEN date = DATE_SUB(CURRENT_DATE('+7'),INTERVAL 10 day) THEN 'D-10'
    END AS time,
    strategy,
    upper_channel,
    d.channel,
    COUNT(DISTINCT customer_id) AS activation,
    MAX(date) AS latest_date
FROM data d
GROUP BY 1,2,3,4)

, week AS(
SELECT
    CASE
    WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY))  THEN 'WTD'
    WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(CURRENT_DATE('+7'),INTERVAL 7 DAY))  THEN 'W-1'
    WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(CURRENT_DATE('+7'),INTERVAL 14 DAY)) THEN 'W-2'
    WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(CURRENT_DATE('+7'),INTERVAL 21 DAY)) THEN 'W-3'
    WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(CURRENT_DATE('+7'),INTERVAL 28 DAY)) THEN 'W-4'
    WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(CURRENT_DATE('+7'),INTERVAL 35 DAY)) THEN 'W-5'
    END AS time,
    strategy,
    upper_channel,
    d.channel,
    COUNT(DISTINCT customer_id) AS activation,
    MAX(date) AS latest_date
FROM data d
WHERE year = '2019'
GROUP BY 1,2,3,4)


, month AS(
SELECT
    CASE
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY)),1,6)                             THEN 'MTD'
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY), INTERVAL 1 MONTH)),1,6) THEN 'M-1'
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY), INTERVAL 2 MONTH)),1,6) THEN 'M-2'
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY), INTERVAL 3 MONTH)),1,6) THEN 'M-3'
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY), INTERVAL 4 MONTH)),1,6) THEN 'M-4'
    END AS time,
    strategy,
    upper_channel,
    d.channel,
    COUNT(DISTINCT customer_id) AS activation,
    MAX(date) AS latest_date
FROM data d
GROUP BY 1,2,3,4)

, week_ly AS(
SELECT
    CASE
        WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY), INTERVAL 1 YEAR))   THEN 'WTD LY'
        WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 7 DAY), INTERVAL 1 YEAR))   THEN 'W-1 LY'
        WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 14 DAY), INTERVAL 1 YEAR))  THEN 'W-2 LY'
        WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 21 DAY), INTERVAL 1 YEAR))  THEN 'W-3 LY'
        WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 28 DAY), INTERVAL 1 YEAR))  THEN 'W-4 LY'
        WHEN week = EXTRACT(ISOWEEK FROM DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 35 DAY), INTERVAL 1 YEAR))  THEN 'W-5 LY'
    END AS time,
    strategy,
    upper_channel,
    d.channel,
    COUNT(DISTINCT customer_id) AS activation,
    MAX(date) AS latest_date
FROM data d
WHERE year = '2018'
GROUP BY 1,2,3,4
)


, month_ly AS(
SELECT
    CASE
        WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 YEAR)),1,6)                                THEN 'MTD LY'
        WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 MONTH), INTERVAL 1 YEAR)),1,6)    THEN 'M-1 LY'
        WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 2 MONTH), INTERVAL 1 YEAR)),1,6)    THEN 'M-2 LY'
        WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 3 MONTH), INTERVAL 1 YEAR)),1,6)    THEN 'M-3 LY'
    END AS time,
    strategy,
    upper_channel,
    d.channel,
    COUNT(DISTINCT customer_id) AS activation,
    MAX(date) AS latest_date
FROM data d
GROUP BY 1,2,3,4
)

, ytd AS (
SELECT
    CASE
    WHEN date >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY),YEAR),INTERVAL 1 YEAR)
     AND date <= DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY), INTERVAL 1 YEAR) THEN 'Y-1 YTD'
    WHEN date >= DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY),YEAR) THEN 'YTD'
    END AS time,
    strategy,
    upper_channel,
    d.channel,
    COUNT(DISTINCT customer_id) AS activation,
    MAX(date) AS latest_date
FROM data d
GROUP BY 1,2,3,4
)


SELECT * FROM
(SELECT * FROM day
UNION ALL 
SELECT * FROM week
UNION ALL 
SELECT * FROM month
UNION ALL 
SELECT * FROM week_ly
UNION ALL 
SELECT * FROM month_ly
UNION ALL
SELECT * FROM ytd
)
WHERE time IS NOT NULL

-- SELECT DISTINCT date FROM data