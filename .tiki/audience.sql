#standardSQL
#There are four parts in this SQL:
#Part_1: Activation
#Part_2: CMV-NMV-Order JOIN activation
#Part_2.1: Session
#Part_3: Cost
#Final_Run

#Part_1
WITH 
fact_sales_order_all AS (
  SELECT customer_key 
        , order_code 
        , original_code
        , date_key 
        , order_type
        , sale_channel_key
        , date_at
  FROM    `tiki-dwh.dwh.fact_sales_order_nmv_2017` 
UNION ALL  

  SELECT customer_key 
        , order_code 
        , original_code
        , date_key 
        , order_type
        , sale_channel_key
        , date_at
  FROM `tiki-dwh.dwh.fact_sales_order_nmv` 
), 

raw_act AS (
SELECT * EXCEPT(preceeding_order_date_at, preceeding_order,rank_first_order,date_at,order_code) 
      ,MAX(IF(rank_first_order=1,order_code,'')) OVER (PARTITION BY customer_id) AS first_order_code
      ,IF(rank_first_order=1,1,0) AS is_activation
      ,IF(rank_first_order=1,0,DATE_DIFF(date_key,DATE(preceeding_order_date_at), DAY)) AS num_of_datediff
      ,IF(DATE_DIFF(date_key,DATE(preceeding_order_date_at),DAY) >= 8, 1,0) is_7days_reactivation
      ,IF(DATE_DIFF(date_key,DATE(preceeding_order_date_at),DAY) >= 31, 1,0) is_30days_reactivation
      ,IF(DATE_DIFF(date_key,DATE(preceeding_order_date_at),DAY) >= 91, 1,0) is_90days_reactivation
      ,IF(DATE_DIFF(date_key,DATE(preceeding_order_date_at),DAY) >= 366, 1,0) is_365days_reactivation
      ,order_code
  FROM 
      (
        SELECT
              date_key
              ,date_at
              ,customer_key AS customer_id 
              ,order_code
              ,original_code
              ,ROW_NUMBER() OVER (PARTITION BY customer_key ORDER BY date_key, date_at) AS rank_first_order
              ,LAG(order_code) OVER (PARTITION BY customer_key ORDER BY date_key, date_at) AS preceeding_order
              ,LAG(date_at) OVER (PARTITION BY customer_key ORDER BY date_key, date_at ) AS preceeding_order_date_at
        FROM  fact_sales_order_all
        WHERE sale_channel_key = 2
        AND order_type = 1
       ) 
)

, activation 
AS 
(
  SELECT distinct customer_id, original_code
  FROM raw_act
  WHERE is_activation = 1 
AND date_key >= '20190101'
)

#note: above this line is to define activation

#Part_2
,raw AS (
SELECT
  CAST(FORMAT_DATE('%Y%m%d',date_key) AS INT64) AS date,
  original_code ,
  order_code,
  sale_channel ,
  platform_name AS platform,
  merchant_id ,
  seller_key                                    AS seller_id,
  product_key                                   AS product_id,
  ga_source                                     ,
  ga_medium                                     ,
  ga_campaign_name                              ,
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
#Define Facebook here    
    AND channel_name LIKE '%facebook%'
    AND (platform_key != 13 or platform_key IS NULL)
    AND merchant_key NOT IN (26,24,7,25,8,14)
	AND date_key >= '20190101'
),
#Part_2.1
session AS (
SELECT 
      date,
      source, 
      medium, 
      campaign, 
      session
FROM `tiki-dwh.dwh.fact_ga_session_2019*`
WHERE source LIKE '%facebook%'
AND _TABLE_SUFFIX  >= format_date('%m%d', DATE_TRUNC(date_sub(CURRENT_DATE('+7'),interval 1 month),month))
),

union_cmv AS (
SELECT 
PARSE_DATE('%Y%m%d',CAST(d.date AS STRING)) AS date,
ga_source                                     AS source,
ga_medium                                     AS medium,
ga_campaign_name                              AS campaign,
SAFE_CAST(REGEXP_EXTRACT(ga_campaign_name, r"_Z.(.+?$)") as int64) as ad_id,
SUM(confirmed_value - confirmed_discount + confirmed_discount_tikixu + confirmed_shipping_fee - confirmed_shipping_discount_value + confirmed_handling_fee 
    - cancelled_value+ cancelled_discount - cancelled_discount_tikixu - cancelled_shipping_fee + cancelled_shipping_discount_value - cancelled_handling_fee
    - rma_val - rma_discount_tikixu + rma_shipping_discount_value - rma_shipping_fee - rma_handling_fee) as nmv,
SUM(confirmed_value + confirmed_shipping_fee + confirmed_handling_fee) AS cmv,
SUM(confirmed_qty- cancelled_qty - rma_qty) as net_qty,
a.customer_id AS customer_id
FROM raw d
LEFT JOIN `tiki-dwh.dwh.dim_product_full` dp on d.product_id = dp.product_key
LEFT JOIN activation a ON d.original_code = a.original_code
WHERE 1=1 
  AND PARSE_DATE('%Y%m%d',CAST(d.date AS STRING)) >= '20190101'
GROUP BY 1,2,3,4,5,9
)