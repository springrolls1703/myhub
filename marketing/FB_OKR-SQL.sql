#standardSQL
#There are four parts in this SQL:
#Part_1: Activation
#Part_2: CMV-NMV-Order JOIN activation
#Part_3: Cost
#Final_Run

#Part_1
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
    CAST(1 AS INT64) AS act,
    EXTRACT(ISOWEEK FROM date_key) AS week
	FROM temp
	WHERE rn=1)
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
    AND partner = 'FB'
    AND (platform_key != 13 or platform_key IS NULL)
    AND merchant_key NOT IN (26,24,7,25,8,14)
		AND date_key >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY),MONTH),INTERVAL 1 MONTH)
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
SUM(confirmed_qty- cancelled_qty- rma_qty) as net_qty,
a.customer_id AS customer_id
FROM raw d
LEFT JOIN `tiki-dwh.dwh.dim_product_full` dp on d.product_id = dp.product_key
LEFT JOIN activation a ON d.original_code = a.original_code
WHERE 1=1
  AND PARSE_DATE('%Y%m%d',CAST(d.date AS STRING)) >= 
      DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), YEAR), INTERVAL 1 YEAR)
GROUP BY 1,2,3,4,5,9
)
#note: above this line is to define cmv-nmv-order

#Part_3
, cost AS
(
SELECT 
PARSE_DATE('%Y%m%d', CAST(date_key AS string)) AS date,
format_date("%V", parse_date("%Y%m%d", cast (date_key as string))) as Week,
format_date("%m", parse_date("%Y%m%d", cast (date_key as string))) as Month,
format_date("%Y", parse_date("%Y%m%d", cast (date_key as string))) as Year,
account_name, 
campaign_name,
adset_name,
ad_name,
ad_id,
sum(spend) as spend,
sum(unique_clicks) as unique_clicks,
sum(impressions) as impressions
FROM `tikivn-175510.ecom.fact_mkt_cost_facebook_2019*`
WHERE _TABLE_SUFFIX  >= format_date('%m%d', DATE_TRUNC(date_sub(CURRENT_DATE('+7'),interval 1 month),month))
GROUP BY 1,2,3,4,5,6,7,8,9 
)

#Final_Run
,cost_and_cmv AS (
  SELECT 
        date,
        CAST(NULL AS STRING) AS account_name, 
        CAST(NULL AS STRING) AS adset_name, 
        CAST(NULL AS STRING) AS ad_name, 
        CAST(NULL AS STRING) AS campaign_name, 
        campaign,
        ad_id,
        source,
        medium,
        SUM(cmv) as cmv, 
        SUM(nmv) as nmv, 
        COUNT(DISTINCT customer_id) AS act,
        SUM(net_qty) AS net_qty,
        CAST(NULL AS FLOAT64) AS spend, 
        CAST(NULL AS INT64) AS unique_clicks,
        CAST(NULL AS INT64) AS impressions 
  FROM union_cmv
  GROUP BY 1,2,3,4,5,6,7,8,9
  UNION ALL 
  SELECT 
        date,
        account_name, 
        adset_name, 
        ad_name, 
        campaign_name, 
        CAST(NULL AS STRING) AS campaign, 
        ad_id, 
        CAST(NULL AS STRING) AS source, 
        CAST(NULL AS STRING) AS medium, 
        CAST(NULL AS FLOAT64) AS cmv, 
        CAST(NULL AS FLOAT64) AS nmv, 
        CAST(NULL AS INT64) AS act,
        CAST(NULL AS INT64) AS net_qty,
        spend, 
        unique_clicks,
        impressions
  FROM cost
)
, get_campaign_name AS
(
    SELECT * EXCEPT(rank_adname) 
    FROM 
    (
    SELECT 
          *
          ,ROW_NUMBER() OVER (PARTITION BY ad_id ORDER BY ad_name DESC) AS rank_adname
    FROM (
          SELECT * EXCEPT(plus), 
                RANK() OVER (PARTITION BY ad_id ORDER BY plus DESC) AS rank_get_name
          FROM (
                SELECT DISTINCT 
                       ad_id
                       ,CASE 
                            WHEN ad_name LIKE 'DIS%' THEN ad_name
                            WHEN ad_name NOT LIKE 'DIS%' AND campaign LIKE 'DIS%' THEN campaign
                            WHEN account_name LIKE 'App' AND Upper(campaign_name) LIKE '%ANDROID%' THEN 'DIS_APP_FB_ALL_ALL_ALL_ALL_ALL_AND_UNK'
                            WHEN account_name LIKE 'App' AND Upper(campaign_name) LIKE '%IOS%' THEN 'DIS_APP_FB_ALL_ALL_ALL_ALL_ALL_IOS_UNK'
                            WHEN account_name LIKE '%PNS%' OR campaign_name LIKE '%PNS%' THEN 'DIS_PNS_FB_ALL_ALL_ALL_ALL_ALL_UNK_UNK'
                            ELSE 'Broken_Broken_FB_Broken_Broken_Broken_Broken_Broken_Broken_Broken' 
                        END AS ad_name
                       ,account_name
                       ,campaign_name
                       ,adset_name
                       ,IF(account_name IS NULL, 0, 1) AS plus
                 FROM  cost_and_cmv                        
                )
      )
      WHERE rank_get_name = 1 
      ) WHERE rank_adname = 1
)


SELECT 
      t1.date,
      FORMAT_DATE("%d", t1.date) as e_date,
      FORMAT_DATE("%V", t1.date) as week,
      FORMAT_DATE("%m", t1.date) as month,
      FORMAT_DATE("%G", t1.date) as year,
      t2.account_name, 
      t2.adset_name, 
      t2.ad_name, 
      t2.campaign_name, 
      t1.campaign, 
      t2.ad_id, 
      t1.source, 
      t1.medium, 
      SUM(cmv) as cmv, 
      SUM(nmv) as nmv, 
      SUM(act) as act,
      SUM(net_qty) as net_qty,
      SUM(spend) as spend, 
      SUM(unique_clicks) as unique_clicks,
      SUM(impressions) as impressions,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(1)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(1)]
      END AS spend_strategy,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(3)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(3)]
      END AS ad_type,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(4)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(4)] 
      END AS campaign_type,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(7)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(7)]
      END AS category,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(10)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(10)]
      END AS camp_name,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(11)] 
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(11)]
      END AS camp_code,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(12)] 
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(12)] 
      END AS Audience_list,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(13)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(13)] 
      ELSE 
      END AS Time_retention,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(14)] 
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(14)] 
      END AS Gender,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(15)] 
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(15)] 
      END AS Age,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(16)] 
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(16)] 
      END AS Placement,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(17)] 
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(17)]
      END AS Destination,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(18)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(18)]
      END AS Banner,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(19)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(19)]
      END AS Content,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(20)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(20)]
      END AS Optimize,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(21)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(21)]
      END AS Bidding_event,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(22)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(22)]
      END AS Objective,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(23)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(23)]
      END AS Cate_level,
      CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] != 'FB'
      THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(24)]
      ELSE SPLIT(t1.campaign_name, '_')[SAFE_OFFSET(24)]
      END AS Strategy
FROM cost_and_cmv AS t1
     LEFT JOIN get_campaign_name AS t2
     ON t1.ad_id = t2.ad_id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39