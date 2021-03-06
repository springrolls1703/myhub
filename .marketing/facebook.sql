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
AND date_key >= DATE_TRUNC(DATE_SUB(DATE_SUB(CURRENT_DATE('+7')INTERVAL 1 DAY),INTERVAL 4 MONTH),MONTH)
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
    select * from `tiki-dwh.dwh.fact_marketing_revenue_v3_2020`
    union all
    select * from `tiki-dwh.dwh.fact_marketing_revenue_v3_2019`
  )
  
  WHERE 2=2
	AND sale_channel_key = 2
#Define Facebook here    
    AND channel_name LIKE '%facebook%'
    AND (platform_key != 13 or platform_key IS NULL)
    AND merchant_key NOT IN (26,24,7,25,8,14)
	AND date_key >= DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 4 MONTH),MONTH)
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
FROM `tikivn-175510.ecom.fact_mkt_cost_facebook_*`
WHERE _TABLE_SUFFIX  >= format_date('%Y%m%d', DATE_TRUNC(date_sub(CURRENT_DATE('+7'),interval 4 month),month))
GROUP BY 1,2,3,4,5,6,7,8,9 
)

#Final_Run
,cost_and_cmv 
  AS (
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
  WHERE spend > 0
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
                            WHEN ad_name LIKE 'DIS%' OR ad_name LIKE 'BRC%' THEN ad_name
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

,final_data AS 
(SELECT 
    t1.date,
    CAST(NULL AS INT64) AS session_c,
    FORMAT_DATE("%V", t1.date) as week,
    FORMAT_DATE("%m", t1.date) as month,
    FORMAT_DATE("%Y", t1.date) as year,
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
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(1)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(1)]
    END AS spend_strategy,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(3)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(3)]
    END AS ad_type,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(4)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(4)] 
    END AS campaign_type,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(7)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(7)]
    END AS category,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(10)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(10)]
    END AS camp_name,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(11)] 
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(11)]
    END AS camp_code,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(12)] 
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(12)] 
    END AS Audience_list,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(13)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(13)] 
    END AS Time_retention,
    CASE WHEN
    REGEXP_CONTAINS(t2.ad_name,'_PRC_') = True THEN 'Existing_Customers'
    WHEN
    date < DATE(2019, 12, 06) AND 
    REGEXP_CONTAINS(t2.ad_name,'_PRC_') = False THEN 'New_Customers'
    WHEN
    REGEXP_CONTAINS(t2.ad_name,'F.CIR') = True THEN 'Existing_Customers'
    ELSE 'New_Customers' 
    END AS Customer_type,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(15)] 
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(15)] 
    END AS Age,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(16)] 
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(16)] 
    END AS Placement,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(17)] 
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(17)]
    END AS Destination,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(18)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(18)]
    END AS Banner,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(19)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(19)]
    END AS Content,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(20)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(20)]
    END AS Optimize,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(21)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(21)]
    END AS Bidding_event,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(22)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(22)]
    END AS Objective,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(23)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(23)]
    END AS Cate_level,
    CASE WHEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(2)] = 'FB'
    THEN SPLIT(t2.ad_name, '_')[SAFE_OFFSET(24)]
    ELSE SPLIT(t1.campaign, '_')[SAFE_OFFSET(24)]
    END AS Strategy
FROM cost_and_cmv AS t1
     LEFT JOIN get_campaign_name AS t2 ON t1.ad_id = t2.ad_id
GROUP BY 1,3,4,5,6,7,8,9,10,11,12,13,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39
)

SELECT 
* 
FROM final_data 
WHERE date >= DATE_TRUNC(date_sub(CURRENT_DATE('+7'),interval 28 day),ISOWEEK)
UNION ALL
SELECT
CAST(NULL AS DATE)	AS date,
CAST(NULL AS INT64) AS session_c,	
CAST(NULL AS STRING) AS week,
month,
year,
CAST(NULL AS STRING) AS account_name,
CAST(NULL AS STRING) AS adset_name,
CAST(NULL AS STRING) AS ad_name,
CAST(NULL AS STRING) AS campaign_name,
CAST(NULL AS STRING) AS campaign,
CAST(NULL AS INT64) AS ad_id,
CAST(NULL AS STRING) AS source,
CAST(NULL AS STRING) AS medium,
sum(cmv),
sum(nmv),
sum(act),
sum(net_qty),
sum(spend),
sum(unique_clicks),
sum(impressions),
spend_strategy,
ad_type,
campaign_type,
CAST(NULL AS STRING) AS category,
CAST(NULL AS STRING) AS camp_name,
CAST(NULL AS STRING) AS camp_code,
CAST(NULL AS STRING) AS Audience_list,
CAST(NULL AS STRING) AS Time_retention,
Customer_type,
CAST(NULL AS STRING) AS Age,
CAST(NULL AS STRING) AS Placement,
CAST(NULL AS STRING) AS Destination,
CAST(NULL AS STRING) AS Banner,
CAST(NULL AS STRING) AS Content,
CAST(NULL AS STRING) AS Optimize,
CAST(NULL AS STRING) AS Bidding_event,
Objective,
CAST(NULL AS STRING) AS Cate_level,
CAST(NULL AS STRING) AS Strategy
FROM final_data 
WHERE date < DATE_TRUNC(date_sub(CURRENT_DATE('+7'),interval 28 day),ISOWEEK)
GROUP BY 1,3,4,5,6,7,8,9,10,11,12,13,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39