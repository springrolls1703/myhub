#standardSQL
with 
purchase_data as(
SELECT 
  distinct
  PARSE_DATE('%Y-%m-%d',FORMAT_DATETIME('%Y-%m-%d',PARSE_DATETIME('%Y%m%d',install_time))) AS install_time,
  PARSE_DATE('%Y-%m-%d',FORMAT_DATETIME('%Y-%m-%d',PARSE_DATETIME('%Y%m%d',purchase_time))) AS date,
  campaign,
  device_id,
  order_code as original_order
FROM `tiki-dwh.appsflyer.purchase_event_2*`
where is_retargeting = 'false'
and device_id is not null
and _table_suffix >= '0190301'
and lower(campaign) like '%app\\_%'
and PARSE_DATE('%Y-%m-%d',FORMAT_DATETIME('%Y-%m-%d',PARSE_DATETIME('%Y%m%d',purchase_time))) <= 
DATE_ADD(PARSE_DATE('%Y-%m-%d',FORMAT_DATETIME('%Y-%m-%d',PARSE_DATETIME('%Y%m%d',install_time))), INTERVAL 3 DAY) 
),

fact_sale_order as(
select
  date_key,
  order_code,
  original_code,
  order_type,
  customer_key,
  value,
  discount,
  discount_tikixu,
  shipping_value,
  shipping_discount_value,
  handling_fee
from `tiki-dwh.dwh.fact_sales_order_nmv`
left join `tiki-dwh.dwh.dim_sale_channel` using (sale_channel_key)
where sale_channel = 'ONLINE'
and date_key >= '2019-03-01'
),

data_sale as (
select
  date_key,
  original_code,
  customer_key,
  SUM(CASE 
          WHEN order_type = 1 THEN IFNULL(value, 0) + IFNULL(shipping_value, 0) + IFNULL(handling_fee, 0)
          ELSE 0
      END) as cmv,
  SUM(CASE 
        WHEN order_type = 1 THEN IFNULL(value, 0) - (IFNULL(discount, 0) - IFNULL(discount_tikixu, 0)) + (IFNULL(shipping_value, 0) - IFNULL(shipping_discount_value, 0)) + IFNULL(handling_fee, 0)
        ELSE - (IFNULL(value, 0) - (IFNULL(discount, 0) - IFNULL(discount_tikixu, 0)) + (IFNULL(shipping_value, 0) - IFNULL(shipping_discount_value, 0)) + IFNULL(handling_fee, 0))
      END) as nmv
from fact_sale_order
group by 1,2,3
),

activation_data as (
  select
    *
  from 
    ( select 
        *,
        row_number() over (partition by order_code) as rn
      FROM `tiki-dwh.fna.fna_customer_activation_*`
      where _table_suffix >= '20190301'
    )
  where rn = 1
),

activation_raw as(
select distinct
  pd.original_order,
  a.customer_id
from purchase_data pd
join activation_data a on pd.original_order = a.order_code
),

criteocost AS (
SELECT 
'Criteo' AS new_channel,
CAST(FORMAT_DATE('%Y%m%d', PARSE_DATE("%y%m%d",_TABLE_SUFFIX)) AS INT64) AS date_key,
campaign_key as campaign,
       CASE
        WHEN campaign_key LIKE '%DIS_APP_%' THEN 'Apps'
        ELSE 'Others'
       END AS vertical,
Cost_USD as Cost
FROM `tiki-dwh.dwh.fact_campaign_criteo_rtb_20*`
WHERE _TABLE_SUFFIX >= '190301'
),


ggcost AS (
SELECT
    'Google' AS new_channel,
    CAST(FORMAT_DATE('%Y%m%d', c.Date) AS INT64) AS date_key,
    c.CampaignName as campaign,
    CASE
    WHEN c. CampaignName LIKE '%UAC\\_App%' OR c. CampaignName LIKE '%App\\_UAC%' OR c. CampaignName LIKE '%APP%' THEN 'Apps'
    ELSE 'Others'
    END AS vertical,
    CAST(ROUND(SUM(cs.Cost/ 1000000), 0) AS INT64) AS Cost 
  FROM (
  SELECT 
    CampaignName , 
    CampaignId , 
    DATE(_PARTITIONTIME, '+7') AS Date 
    FROM `tikivn-175510.adwords.p_Campaign_*`
    WHERE _TABLE_SUFFIX != '6647354050'
    ) c
  LEFT JOIN (
    SELECT 
      CampaignId, 
      Date, 
      Cost 
      FROM `tikivn-175510.adwords.p_CampaignBasicStats_*`
      WHERE _TABLE_SUFFIX != '6647354050'
    ) cs
  ON
    (c.CampaignId = cs.CampaignId AND c.Date = cs.Date )
  WHERE FORMAT_DATE('%Y%m%d', c.Date) >= '20190301'
    AND FORMAT_DATE('%Y%m%d', c.Date) <= 
        FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY))
  GROUP BY 1,2,3,4
),

fbcost AS (
SELECT 'Facebook' AS new_channel,
       date_key,
       campaign_name as campaign,
       CASE
        WHEN account_name LIKE '%App%' OR campaign_name LIKE '%\\_App%' THEN 'Apps'
        ELSE 'Others'
       END AS vertical, 
       ROUND(SUM(spend*1.054), 0) AS Cost 
FROM `tikivn-175510.ecom.fact_mkt_cost_facebook_2*` 
WHERE _TABLE_SUFFIX >= '0190301'
  AND _TABLE_SUFFIX <= SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY)),2,7)
GROUP BY 1,2,3,4
), 

temp as (
SELECT *,PARSE_DATE("%Y%m%d", CAST(date_key as string)) as date FROM ggcost 
WHERE vertical = 'Apps'
UNION ALL
SELECT *,PARSE_DATE("%Y%m%d", CAST(date_key as string)) as date FROM fbcost
WHERE vertical = 'Apps'
UNION ALL
SELECT *,PARSE_DATE("%Y%m%d", CAST(date_key as string)) as date FROM criteocost
WHERE vertical = 'Apps'
),

raw as (
select 
  pd.*,
  cmv,
  nmv,
  a.customer_id,
  customer_key
from purchase_data pd
left join data_sale d on pd.original_order = d.original_code
left join activation_raw a on pd.original_order = a.original_order
),

install_data 
as(
SELECT
date_key,
campaign,
COUNT(distinct device_id) as install FROM(
SELECT
  PARSE_DATE("%Y%m%d",format_timestamp('%Y%m%d', install_time)) as date_key,
  campaign,
  Case
    when android_id != 'null' then android_id
    when advertising_id != 'null' then advertising_id
    when idfa != 'null' then idfa
    when idfv != 'null' then idfv
  end as device_id
FROM `tiki-dwh.appsflyer.installs_2*`
where lower(campaign) like "%app\\_%"
and _table_suffix >= '0190301'
)
group by 1,2
),

cmv_side AS (
select
  pd.date,
  pd.campaign,
  count(distinct original_order) as num_order,
  sum(cmv) as cmv,
  sum(nmv) as nmv,
  count(distinct customer_id) as act,
  count(distinct customer_key) as num_customer
FROM raw pd
WHERE pd.date >= DATE_TRUNC(DATE_SUB(CURRENT_DATE("+7"), INTERVAL 30 DAY), MONTH)
group by 1,2
)
, 
g AS (SELECT
  pd.date,
  SPLIT(pd.campaign, '_')[SAFE_OFFSET(2)] as channel,
  CAST (NULL AS float64) AS Cost,
  pd.campaign,
  pd.num_order,
  pd.cmv,
  pd.nmv,
  pd.act,
  pd.num_customer,
  CAST (NULL AS int64) AS install
FROM cmv_side pd
WHERE num_order IS NOT NULL OR cmv IS NOT NULL OR nmv IS NOT NULL OR act IS NOT NULL
UNION ALL
SELECT
  date,
  SPLIT(campaign, '_')[SAFE_OFFSET(2)] as channel,
  Cost,
  campaign,
  CAST (NULL as int64) as num_order,
  CAST (NULL as float64) as cmv,
  CAST (NULL as float64) as nmv,
  CAST (NULL as float64) as act,
  CAST (NULL as int64) as num_customer,
  CAST (NULL AS int64) AS install
FROM temp 
WHERE cost is NOT NULL
UNION ALL
SELECT
  date_key as date,
  SPLIT(campaign, '_')[SAFE_OFFSET(2)] as channel,
  CAST (NULL AS float64) AS Cost,
  campaign,
  CAST (NULL as int64) as num_order,
  CAST (NULL as float64) as cmv,
  CAST (NULL as float64) as nmv,
  CAST (NULL as float64) as act,
  CAST (NULL as int64) as num_customer,
  install
FROM install_data
WHERE install IS NOT NULL
)

SELECT
date,
channel,
sum(cost) as cost,
campaign,
sum(num_order) as num_order,
sum(cmv) as cmv,
sum(nmv) as nmv,
sum(act) as act,
sum(num_customer) - sum(act) as retention,
sum(install) as install
FROM g
WHERE date >= DATE_TRUNC(DATE_SUB(CURRENT_DATE("+7"), INTERVAL 30 DAY), MONTH)
GROUP BY 1,2,4
order by 1 DESC
