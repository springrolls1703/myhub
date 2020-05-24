#standardSQL
with 
channel_data as (
SELECT 
  distinct
  original_code,
  order_code,
  product_id,
  CASE
    WHEN campaign LIKE '%DIS_%_COC%' THEN 'coc coc' 
    WHEN Lower(source) in ('tiki.vn','products','pipe.tikicdn.com','hotro.tiki.vn','tiki.gotadi.com','vcdn.tikicdn.com','quay.tiki.vn',
    'mapi.tiki.vn','dzut.tiki.vn','hotel.tiki.vn','payment.tiki.vn','facebook.tiki.vn','tuyendung.tiki.vn') THEN 'possible internal links'
    WHEN (LOWER(source) LIKE '%google%' OR LOWER(source) LIKE '%bing%' OR LOWER(source) LIKE '%yahoo%') AND medium LIKE 'organic'   THEN 'organic search'
    WHEN LOWER(source) LIKE '%google%' THEN 'google'
    WHEN source LIKE '(direct)' AND medium IN('(none)' ,'(not set)') THEN 'direct'
    WHEN (LOWER(source) LIKE '%tiki.vn%' OR source LIKE '%product%')AND medium LIKE '%referrer%' THEN 'apps'
    WHEN LOWER(medium) LIKE '%referral%' THEN 'referral'
    WHEN LOWER(source) LIKE '%criteo%' AND LOWER(medium) LIKE '%cpc%' THEN 'retargeting criteo'
    WHEN (LOWER(source) LIKE '%insider%' OR LOWER(source) LIKE '%noti%') AND (LOWER(medium) LIKE '%ios%' OR LOWER(medium) LIKE '%android%'
            OR LOWER(medium) LIKE '%web%' OR LOWER(medium) LIKE '%app%') THEN 'push noti'
    WHEN (LOWER(source) LIKE '%facebook%'
            OR (LOWER(source) = '(not set)' AND LOWER(medium) = 'dpas')
            OR (LOWER(source) = 'fb' AND LOWER(medium) = 'post')
            OR (LOWER(source) = 'fanpage' AND LOWER(medium) = 'partner')) THEN 'facebook'
    WHEN LOWER(source) LIKE '%admicro%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'ldn admicro'
    WHEN LOWER(source) LIKE '%adtima%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'ldn adtima'
    WHEN LOWER(source) LIKE '%chin%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'ldn chin'
    WHEN LOWER(source) LIKE '%pmax%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'ldn pmax'
    WHEN LOWER(source) LIKE '%24h%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'ldn 24h'
    WHEN (LOWER(source) LIKE '%medihub%' OR LOWER(source) LIKE '%coccoc_newtab_media%')
    AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'ldn others'
    WHEN LOWER(source) LIKE '%rtbhouse%' AND LOWER(medium) LIKE '%retarge%' THEN 'retargeting rtbhouse'
    WHEN (LOWER(source) like '%email%' or LOWER(medium) LIKE '%email%') THEN 'email'
    WHEN LOWER(source) LIKE '%accesstrade%' THEN 'affiliate accesstrade'
    WHEN LOWER(source) LIKE '%ecomobi%' THEN 'affiliate ecomobi'
    WHEN LOWER(source) LIKE '%masoffer%' THEN 'affiliate masoffer'
    WHEN LOWER(source) LIKE '%websosanh%' THEN 'affiliate websosanh'
    WHEN LOWER(source) like '%cityads%' THEN 'affiliate cityads'
    WHEN LOWER(source) = 'zalo' THEN 'zalo'
    WHEN LOWER(Source) = 'youtube' THEN 'youtube'
    ELSE 'others'
  END AS channel,
  CASE
    WHEN platform IN('mobile','mobile-unknown','frontend-mobile-zalo') OR platform LIKE '%_ios' OR platform LIKE '%_android' THEN 'Apps'
    WHEN 
    platform LIKE 'frontend-mobile%' OR platform IN('mobile-polymer','frontend-tablet')
    OR platform LIKE '%_desktop' OR platform = 'frontend' THEN 'Web'
    ELSE 'Others'
   END AS platform_name,
  confirmed_value
FROM `tiki-dwh.fna.fna_nmv_lastclick_2*`
),


clean_channel_data as(
select 
  original_code, channel, platform_name
from( 
    select
      *,
      row_number() over(partition by original_code order by confirmed_value DESC) as rn
    from channel_data
    )
where rn = 1
),

fact_sale_data_origin as (
select
  concat(cast(extract(YEAR from date_key) as string),'-0', cast(extract(QUARTER from date_key) as string)) as year_quarter,
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
and date_key < current_date("+7")

union all

select
  concat(cast(extract(YEAR from date_key) as string),'-0', cast(extract(QUARTER from date_key) as string)) as year_quarter,
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
from `tiki-dwh.dwh.fact_sales_order_nmv_2017` 
left join `tiki-dwh.dwh.dim_sale_channel` using (sale_channel_key)
where sale_channel = 'ONLINE'
),

fact_sale_data_origin_platform AS (
SELECT
a.* EXCEPT(original_code),
a.original_code,
b.platform_name
FROM fact_sale_data_origin a
left join clean_channel_data b on a.original_code = b.original_code
)

,order_data as (
select 
  * 
from(
    select
      original_code,
      customer_key,
      platform_name,
      SUM(CASE 
            WHEN order_type = 1 THEN IFNULL(value, 0) - (IFNULL(discount, 0) - IFNULL(discount_tikixu, 0)) + (IFNULL(shipping_value, 0) - IFNULL(shipping_discount_value, 0)) + IFNULL(handling_fee, 0)
            ELSE - (IFNULL(value, 0) - (IFNULL(discount, 0) - IFNULL(discount_tikixu, 0)) + (IFNULL(shipping_value, 0) - IFNULL(shipping_discount_value, 0)) + IFNULL(handling_fee, 0))
        END) as nmv
    from fact_sale_data_origin_platform
    group by 1,2,3
    )
Where nmv > 0
),

clean_order_data as(
select 
  original_code, 
  date_key,
  year_quarter
from( 
    select
      *,
      row_number() over(partition by original_code order by date_key DESC) as rn
    from fact_sale_data_origin
    )
where rn = 1
),

data_sale as (
select
  year_quarter,
  date_key,
  a.original_code,
  customer_key,
  channel,
  a.platform_name,
  nmv
from order_data a 
left join clean_channel_data b on a.original_code = b.original_code
left join clean_order_data c on a.original_code = c.original_code
-- remove order have nmv <= 0
),


customer_first_day as (
select * 
from (
  select 
    year_quarter, 
    customer_key,
    channel,
    platform_name,
    row_number() over (partition by customer_key order by date_key) as rn
  from data_sale
     )
Where rn = 1
),

activation_data as (
select 
  ds.year_quarter,
  fd.channel,
  count(distinct ds.customer_key) as num_customer,
  SUM(nmv) as nmv,
  fd.platform_name
from data_sale ds
join customer_first_day fd using(year_quarter, customer_key)
group by 1,2,5
),

#cal_subs
quarter_diff as(
select 
  ds.*,
  fd.year_quarter as first_quarter,
  fd.channel as activation_channel,
  fd.platform_name as platform,
  (cast(substr(ds.year_quarter,1,4) as int64) - cast(substr(fd.year_quarter,1,4) as int64)) * 4 
  + cast(substr(ds.year_quarter,7,1) as int64) - cast(substr(fd.year_quarter,7,1) as int64) as subs
from data_sale ds
left join customer_first_day fd using(customer_key)
),

quarter_diff_agg as (
select 
  year_quarter,
  activation_channel,
  subs,
  first_quarter,
  platform,
  count(distinct customer_key) as num_customer,
  count(distinct original_code) as ord,
  SUM(nmv) as nmv
from quarter_diff
group by 1,2,3,4,5
),

final_data as (
select
  md.first_quarter as fyear_quarter,
  substr(md.first_quarter,1,4) as fyear,
  substr(md.first_quarter,7,1) as fquarter,
  md.year_quarter AS time_series,
  activation_channel,
  substr(md.year_quarter,1,4) as year,
  substr(md.year_quarter,7,1) as quarter,
  md.subs,
  md.num_customer,
  md.ord,
  md.nmv as nmv,
  ifnull(md.num_customer/f.num_customer,0) as customer_rate,
  ifnull(md.nmv/if(f.nmv=0,1,f.nmv),0) as nmv_rate,
  ifnull(md.ord/if(md.num_customer=0,1,md.num_customer),0) as ord_cus,
  ifnull(md.nmv/if(md.num_customer=0,1,md.num_customer),0) as nmv_cus,
  ifnull(md.nmv/if(md.ord=0,1,md.ord),0) as nmv_ord,
  f.num_customer as activation_customer,
  ifnull(md.nmv/if(f.num_customer=0,1,f.num_customer),0) as nmv_activation_customer,
  md.platform
from quarter_diff_agg md
left join activation_data f on md.first_quarter = f.year_quarter and md.activation_channel = f.channel and f.platform_name = md.platform
where substr(md.first_quarter,1,4) >= '2017'
order by fyear, fquarter, subs
)

select
  a.* except(activation_customer, nmv_activation_customer,platform),
  case when high_level_channel_rollup_name in ("direct", "others") or high_level_channel_rollup_name is null then "direct"
  else high_level_channel_rollup_name
  end as high_level_channel_rollup_name,
  activation_customer,
  nmv_activation_customer,
  platform
from final_data a
left join `tiki-dwh.dwh.dim_marketing_channel` on activation_channel = channel_name
