#standardSQL
with 

purchase_data as(
SELECT 
  distinct
  EXTRACT(DATE FROM install_time) AS install_time,
  date_key as date,
  campaign,
  device_id,
  order_code as original_order
FROM `tiki-dwh.appsflyer.purchased`
where is_retargeting = 'false'
and device_id is not null
and lower(campaign) like '%app%'
and date_key >= date(2019,03,01)
and purchase_time <= TIMESTAMP_ADD(install_time, interval 30 DAY) 
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
  SUM(CASE 
          WHEN order_type = 1 THEN IFNULL(value, 0) + IFNULL(shipping_value, 0) + IFNULL(handling_fee, 0)
          ELSE 0
      END) as cmv,
  SUM(CASE 
        WHEN order_type = 1 THEN IFNULL(value, 0) - (IFNULL(discount, 0) - IFNULL(discount_tikixu, 0)) + (IFNULL(shipping_value, 0) - IFNULL(shipping_discount_value, 0)) + IFNULL(handling_fee, 0)
        ELSE - (IFNULL(value, 0) - (IFNULL(discount, 0) - IFNULL(discount_tikixu, 0)) + (IFNULL(shipping_value, 0) - IFNULL(shipping_discount_value, 0)) + IFNULL(handling_fee, 0))
      END) as nmv
from fact_sale_order
group by 1,2
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
Cost_USD as Cost,
impressions as impression,
clicks as click
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
    CAST(ROUND(SUM(cs.Cost/ 1000000), 0) AS INT64) AS Cost,
    SUM(impression) as impression,
    SUM(click) as click
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
      Cost,
      impressions as impression,
      clicks as click
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
       CAST(FORMAT_DATE('%Y%m%d', date) AS INT64) as date_key,
       campaign_name as campaign,
       CASE
        WHEN lower(campaign_name) LIKE '%app%' OR campaign_name LIKE '%_app_%' THEN 'Apps'
        ELSE 'Others'
       END AS vertical, 
       ROUND(SUM(spend), 0) AS Cost,
       SUM(impressions) as impression,
       SUM(clicks) as click
FROM `tiki-dwh.vision.facebook_campaign_stats` 
WHERE date >= Date(2019,03,01)
  AND date <= DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY)
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
  a.customer_id
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
  EXTRACT(DATE FROM TIMESTAMP(install_time)) as date_key,
  campaign,
  Case
    when android_id != 'null' then android_id
    when advertising_id != 'null' then advertising_id
    when idfa != 'null' then idfa
    when idfv != 'null' then idfv
  end as device_id
FROM `tiki-dwh.appsflyer.installs`
where lower(campaign) like "%app\\_%"
and DATE(_PARTITIONTIME) >= '2019-03-01'
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
  count(distinct customer_id) as act
FROM raw pd
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
  CAST (NULL AS int64) AS install,
  CAST (NULL AS int64) as impression,
  CAST (NULL AS int64) as click
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
  CAST (NULL AS int64) AS install,
  impression,
  click
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
  install,
  CAST (NULL AS int64) as impression,
  CAST (NULL AS int64) as click
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
sum(install) as install,
FORMAT_DATE('%m',date) as month,
FORMAT_DATE('%V',date) as week,
FORMAT_DATE('%Y',date) as year,
SPLIT(campaign, '_')[SAFE_OFFSET(8)] as platform,
sum(impression) as impression,
sum(click) as click
FROM g
WHERE date >= DATE_SUB(CURRENT_DATE("+7"), INTERVAL 30 DAY)
GROUP BY 1,2,4,10,11,12
UNION ALL
SELECT
CAST(NULL as date) as date,
channel,
sum(cost) as cost,
campaign,
sum(num_order) as num_order,
sum(cmv) as cmv,
sum(nmv) as nmv,
sum(act) as act,
sum(install) as install,
FORMAT_DATE('%m',date) as month,
CAST(NULL AS string) as week,
FORMAT_DATE('%Y',date) as year,
SPLIT(campaign, '_')[SAFE_OFFSET(8)] as platform,
sum(impression) as impression,
sum(click) as click
FROM g
WHERE date < DATE_SUB(CURRENT_DATE("+7"), INTERVAL 30 DAY)
GROUP BY 1,2,4,10,11,12
order by 1 DESC