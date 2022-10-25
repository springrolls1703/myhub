#standardSQL
with 
purchase_data as(
SELECT 
  distinct
  install_time,
  PARSE_DATE('%Y-%m-%d',FORMAT_DATETIME('%Y-%m-%d',PARSE_DATETIME('%Y%m%d',purchase_time))) AS date,
  campaign,
  device_id,
  order_code as original_order
FROM `tiki-dwh.appsflyer.purchase_event_2*`
where is_retargeting = 'false'
and device_id is not null
and _table_suffix >= '0190301'
and lower(campaign) like '%app\\_%'
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
      FROM `tiki-dwh.fna.fna_customer_activation_2019*`
      where _table_suffix >= '0190301'
    )
  where rn = 1
),

activation_raw as(
select
  date,
  campaign,
  order_code,
  customer_id
from purchase_data
left join activation_data on original_order = order_code
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
),

raw as (
select 
  *,
  cmv,
  nmv
--   a.customer_id
from data_sale pd
-- join data_sale on original_order = original_code
-- join activation_raw a on original_order = order_code
),
install_data as(
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

select
  pd.date,
  pd.campaign,
--   t.new_channel,
--   t.cost,
--   count(distinct i.device_id) as install,
--   count(distinct original_order) as num_order,
  sum(cmv) as cmv,
  sum(nmv) as nmv
--   count(distinct customer_id) as act
FROM raw pd
-- join temp t on pd.campaign = t.campaign and pd.date=t.date
-- join install_data i on pd.campaign = i.campaign and pd.date = i.date_key
-- WHERE pd.date >= DATE_SUB(CURRENT_DATE("+7"), INTERVAL 30 DAY)
-- group by 1,2,3,4
order by 1 DESC
