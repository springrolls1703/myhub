#StandardSQL
--_02_mkt_new_nmv_okr
WITH data1 AS (
SELECT
  CAST(FORMAT_DATE('%Y%m%d',date_key) AS INT64) AS date,
  original_code ,
  order_code,
  sale_channel ,
  platform_name                                 AS platform,
  merchant_id ,
  seller_key                                    AS seller_id,
  product_key                                   AS product_id,
  ga_source                                     AS source,
  ga_medium                                     AS medium,
  ga_campaign_name                              AS campaign,
  spend_strategy, 
  CASE
    WHEN channel_name = 'zalo' THEN 'referral'
    WHEN channel_name IN ('affiliate ecomobi','affiliate websosanh') THEN 'affiliate others'
    WHEN channel_name LIKE 'ldn%' AND channel_name <> 'ldn chin' THEN 'ldn others'
    WHEN channel_name IN ('possible internal links') THEN 'others'
    ELSE channel_name
  END AS channel,
  high_level_channel_rollup_name,
  CASE
    WHEN channel_name = 'google' THEN SPLIT(campaign_key,'_')[SAFE_OFFSET(0)]
    ELSE campaign_key
  END AS campaign_id,
  CASE
    WHEN channel_name = 'google' THEN SPLIT(campaign_key,'_')[SAFE_OFFSET(1)]
    ELSE campaign_key
  END AS adgroup_id,
  CASE WHEN order_type = 1 THEN value_VND ELSE 0 
  END confirmed_value,
  CASE WHEN order_type = 2 THEN value_VND ELSE 0 
  END cancelled_value,
  CASE WHEN order_type = 3 THEN value_VND ELSE 0 
  END rma_val,
  
  CASE WHEN order_type = 1 THEN discount_tikixu_VND ELSE 0 
  END confirmed_discount_tikixu,
  CASE WHEN order_type = 2 THEN discount_tikixu_VND ELSE 0 
  END cancelled_discount_tikixu,
  CASE WHEN order_type = 3 THEN discount_tikixu_VND ELSE 0 
  END rma_discount_tikixu,
  
  CASE WHEN order_type = 1 THEN shipping_value_VND ELSE 0 
  END confirmed_shipping_fee,
  CASE WHEN order_type = 2 THEN shipping_value_VND ELSE 0 
  END cancelled_shipping_fee,
  CASE WHEN order_type = 3 THEN shipping_value_VND ELSE 0 
  END rma_shipping_fee,
  
  CASE WHEN order_type = 1 THEN shipping_discount_value_VND ELSE 0 
  END confirmed_shipping_discount_value,
  CASE WHEN order_type = 2 THEN shipping_discount_value_VND ELSE 0 
  END cancelled_shipping_discount_value,
  CASE WHEN order_type = 3 THEN shipping_discount_value_VND ELSE 0 
  END rma_shipping_discount_value,
  
  CASE WHEN order_type = 1 THEN handling_fee_VND ELSE 0 
  END confirmed_handling_fee,
  CASE WHEN order_type = 2 THEN handling_fee_VND ELSE 0 
  END cancelled_handling_fee,
  CASE WHEN order_type = 3 THEN handling_fee_VND ELSE 0 
  END rma_handling_fee,
  
  CASE WHEN order_type = 1 THEN qty ELSE 0 
  END confirmed_qty,
  CASE WHEN order_type = 2 THEN qty ELSE 0 
  END cancelled_qty,
  CASE WHEN order_type = 3 THEN qty ELSE 0 
  END rma_qty,
  
  CASE WHEN order_type = 1 THEN discount_VND ELSE 0 
  END confirmed_discount,
  CASE WHEN order_type = 2 THEN discount_VND ELSE 0 
  END cancelled_discount,
  CASE WHEN order_type = 3 THEN discount_VND ELSE 0 
  END rma_discount
  FROM(
    select * from `tiki-dwh.dwh.fact_marketing_revenue_v3_2019`
    union all
    select * from `tiki-dwh.dwh.fact_marketing_revenue_v3_2018`
  )
  
  WHERE 2=2
		AND sale_channel_key = 2
    AND (platform_key != 13 or platform_key IS NULL)
    AND merchant_key NOT IN (26,24,7,25,8,14)
		AND date_key >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY),YEAR),INTERVAL 1 YEAR)
		AND (date_key <= DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY), INTERVAL 1 YEAR)
						OR date_key >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), MONTH), INTERVAL 14 MONTH) 
						OR date_key >= DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), YEAR))
),

raw AS (
SELECT 
PARSE_DATE('%Y%m%d',CAST(d.date AS STRING)) AS date,
EXTRACT(ISOWEEK FROM PARSE_DATE('%Y%m%d',CAST(d.date AS STRING))) AS week,
SUBSTR(CAST(d.date AS STRING),1,6) AS month,
SUBSTR(CAST(d.date AS STRING),1,4) AS year,
CASE
    WHEN campaign LIKE '%Google_Search_SEM_Gross_Gross_@NBrand Keyword_@CAll%' 
      THEN 'Google Brand'
    WHEN spend_strategy = 'APP'
      THEN 'Apps'
    WHEN spend_strategy in ('PNS', 'PRT')
      THEN 'Partnership'
    WHEN spend_strategy = 'SPO'
    THEN 'Sponsored'
    WHEN spend_strategy = 'YBR'
      THEN 'Brand'
    WHEN spend_strategy = 'NBR'
      THEN 'Nonbrand'
    ELSE 'Other'
  END AS strategy,
channel,
high_level_channel_rollup_name,
CASE
WHEN dp.merchant_english_name IS NULL THEN 'Other'
ELSE dp.merchant_english_name END AS merchant_name,
SUM(confirmed_value - confirmed_discount + confirmed_discount_tikixu + confirmed_shipping_fee - confirmed_shipping_discount_value + confirmed_handling_fee 
    - cancelled_value+ cancelled_discount - cancelled_discount_tikixu - cancelled_shipping_fee + cancelled_shipping_discount_value - cancelled_handling_fee
    - rma_val - rma_discount_tikixu + rma_shipping_discount_value - rma_shipping_fee - rma_handling_fee) as nmv,
SUM(confirmed_value + confirmed_shipping_fee + confirmed_handling_fee) AS cmv,
SUM(confirmed_qty- cancelled_qty- rma_qty) as net_qty
FROM data1 d
LEFT JOIN `tiki-dwh.dwh.dim_product_full` dp on d.product_id = dp.product_key
WHERE 1=1
  AND PARSE_DATE('%Y%m%d',CAST(d.date AS STRING)) >= 
      DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), YEAR), INTERVAL 1 YEAR)
GROUP BY 1,2,3,4,5,6,7,8
)

, data AS (
    SELECT
        date,
        week,
        month,
        year,
        strategy,
        channel,
        high_level_channel_rollup_name AS upper_channel,
        merchant_name,
        nmv,
        cmv,
        net_qty
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
    d.strategy,
    d.channel,
    d.merchant_name,
    SUM(nmv) AS nmv,
    SUM(cmv) AS cmv,
    SUM(net_qty) AS net_qty,
    MAX(date) AS latest_date,
    upper_channel
FROM data d
GROUP BY 1,2,3,4,9
)

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
    d.strategy,
    d.channel,
    d.merchant_name,
    SUM(nmv) AS nmv,
    SUM(cmv) AS cmv,
    SUM(net_qty) AS net_qty,
    MAX(date) AS latest_date,
    upper_channel
FROM data d
WHERE year = '2019'
GROUP BY 1,2,3,4,9
)


, month AS(
SELECT
    CASE
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY)),1,6)                             THEN 'MTD'
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY), INTERVAL 1 MONTH)),1,6) THEN 'M-1'
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY), INTERVAL 2 MONTH)),1,6) THEN 'M-2'
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY), INTERVAL 3 MONTH)),1,6) THEN 'M-3'
    WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 0 DAY), INTERVAL 4 MONTH)),1,6) THEN 'M-4'
    END AS time,
    d.strategy,
    d.channel,
    d.merchant_name,
    SUM(nmv) AS nmv,
    SUM(cmv) AS cmv,
    SUM(net_qty) AS net_qty,
    MAX(date) AS latest_date,
    upper_channel
FROM data d
GROUP BY 1,2,3,4,9
)

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
    d.strategy,
    d.channel,
    d.merchant_name,
    SUM(nmv) AS nmv,
    SUM(cmv) AS cmv,
    SUM(net_qty) AS net_qty,
    MAX(date) AS latest_date,
    upper_channel
FROM data d
WHERE year = '2018'
GROUP BY 1,2,3,4,9
)


, month_ly AS(
SELECT
    CASE
        WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 YEAR)),1,6)                                THEN 'MTD LY'
        WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 MONTH), INTERVAL 1 YEAR)),1,6)    THEN 'M-1 LY'
        WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 2 MONTH), INTERVAL 1 YEAR)),1,6)    THEN 'M-2 LY'
        WHEN month = SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 3 MONTH), INTERVAL 1 YEAR)),1,6)    THEN 'M-3 LY'
    END AS time,
    d.strategy,
    d.channel,
    d.merchant_name,
    SUM(nmv) AS nmv,
    SUM(cmv) AS cmv,
    SUM(net_qty) AS net_qty,
    MAX(date) AS latest_date,
    upper_channel
FROM data d
where date < DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 YEAR)
GROUP BY 1,2,3,4,9
)


, ytd AS(
SELECT
    CASE
      WHEN date >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY),YEAR),INTERVAL 1 YEAR)
       AND date <= DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY), INTERVAL 1 YEAR)                 
      THEN 'Y-1 YTD'
      WHEN date >= DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY),YEAR)           
      THEN 'YTD'
    END AS time,
    d.strategy,
    d.channel,
    d.merchant_name,
    SUM(nmv) AS nmv,
    SUM(cmv) AS cmv,
    SUM(net_qty) AS net_qty,
    MAX(date) AS latest_date,
    upper_channel
FROM data d
GROUP BY 1,2,3,4,9
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