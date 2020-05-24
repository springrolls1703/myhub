WITH
cost_raw AS (
SELECT
  date_key AS date,
  CASE
    WHEN campaign_name LIKE '%Google_Search_SEM_Gross_Gross_@NBrand Keyword_@CAll%' or campaign_name LIKE '%Google_Search_SEM_Book_Gross_@NTiki and Books_@CAll%'
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
  CASE
    WHEN channel_name = 'zalo' THEN 'referral'
    WHEN channel_name IN ('affiliate ecomobi','affiliate websosanh') THEN 'affiliate others'
    WHEN channel_name LIKE 'ldn%' AND channel_name <> 'ldn chin' THEN 'ldn others'
    WHEN channel_name IN ('possible internal links') THEN 'othchcers'
    ELSE channel_name
  END AS channel,
  high_level_channel_rollup_name AS upper_channel,
  CASE
    WHEN lower(channel_name) like "%facebook%" and (lower(campaign_name) LIKE '%f.cir%' OR REGEXP_CONTAINS(campaign_name,'_PRC_') = True) then "reactivation"
    WHEN lower(channel_name) like "%facebook%" and lower(campaign_name) LIKE '%f.cac%' then "activation"
    WHEN (lower(channel_name) like "%rtbhouse%" or lower(channel_name) like "%criteo%")and lower(campaign_name) LIKE '%cir%' then "reactivation"
    WHEN (lower(channel_name) like "%rtbhouse%" or lower(channel_name) like "%criteo%")and lower(campaign_name) LIKE '%cac%' then "activation"
    WHEN (lower(channel_name) like "%email%" or lower(channel_name) like "%noti%")and (campaign_name LIKE '%T.SU%' or campaign_name LIKE '%Signup%' or campaign_name LIKE '%AU04%' or campaign_name LIKE '%AU01%' or campaign_name LIKE '%O.AC%') then "activation"
    WHEN (lower(channel_name) like "%email%" or lower(channel_name) like "%noti%")and (campaign_name LIKE '%AU03%' or campaign_name LIKE '%O.RE%') then "reactivation"
    else "Mix"
  end as campaign_strategy,
  cost_VND AS cost
  from `tiki-dwh.dwh.vw_fact_marketing_mart`
  WHERE 2=2
		AND date_key >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY),YEAR),INTERVAL 1 YEAR)
		AND (date_key <= DATE_SUB(DATE_SUB(CURRENT_DATE('+7'),INTERVAL 1 DAY), INTERVAL 1 YEAR)
        OR date_key >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), MONTH), INTERVAL 4 MONTH) 
        OR date_key >= DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), YEAR) 
        )
)

, cost_data AS (
SELECT
  date,
  EXTRACT(ISOWEEK FROM date) AS week,
  SUBSTR(FORMAT_DATE('%Y%m%d',date),1,6) AS month,
  campaign_strategy,
  sum(cost) as cost,
  CAST(NULL as int64) as num_customer
FROM cost_raw
WHERE (upper_channel = 'paid marketing' OR channel = 'apps')
AND date > date(2019,02,28)
GROUP BY 1,2,3,4,6
)
,
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
    customer_key AS customer_id,
    original_code,
    ROW_NUMBER() over (PARTITION BY customer_key ORDER BY date_key) AS rn
  FROM fact_sales_order_union
  WHERE 1=1
    AND sale_channel_key = 2
    AND order_type = 1
    AND (platform_key != 13 or platform_key is null)
    AND merchant_key not in (26,24,7,25,8,14)
    )
, order_data AS
(
SELECT
date_key as date,
EXTRACT(ISOWEEK FROM date_key) AS week,
SUBSTR(FORMAT_DATE('%Y%m%d',date_key),1,6) AS month,
CASE WHEN
rn = 1 THEN 'activation'
ELSE 'reactivation'
END AS campaign_strategy,
CAST(NULL as float64) as cost,
COUNT(distinct customer_id) AS num_customer
FROM fact_sales_order
WHERE date_key > date(2019,02,28)
GROUP BY 1,2,3,4,5
)

, MIX_split AS (
SELECT 
d1.date,
d1.week,
d1.month,
d2.campaign_strategy,
d1.cost*d2.num_customer/d3.total_customer as cost,
d1.num_customer
FROM cost_data d1
LEFT JOIN order_data d2 USING(date)
LEFT JOIN (
    SELECT
    date,
    SUM(num_customer) as total_customer
    FROM order_data
    GROUP BY 1
    ) d3 USING (date)
WHERE d1.campaign_strategy = 'Mix')
, final_LTV_cost AS (
SELECT 
* 
FROM cost_data
WHERE campaign_strategy != 'Mix'
UNION ALL
SELECT
* FROM 
MIX_split
UNION ALL
SELECT 
* FROM 
order_data
)

SELECT
date,
week,
month,
campaign_strategy,
SUM(cost),
SUM(num_customer)
FROM final_LTV_cost
GROUP BY 1,2,3,4