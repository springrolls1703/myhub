
-- customer_id, --d
-- full_name, --d
-- gender, --d
-- first_purchase_date, --d
-- last_purchase_date, --d
-- usual_purchase_time --d
-- total_nmv, --d
-- unique_order_count, --d
-- tikinow_order_count, --d
-- tikinow_product_count, --d
-- top_cate_1, --d
-- top_cate_2, --d
-- top_cate_3, --d
-- max_value_item, --d
-- max_value, --d
-- total_ship_n_discount, --d
-- total_tikixu_discount, --d
-- random_10_5stars, --d
-- approved_review_count, --d
-- online_payment_perc, --d
-- top_warehouse_region1 --d
-- top_warehouse_region2 --d
-- top_warehouse_region3 --d
create or replace table tmp.tntest_fact_customer_campaign
partition by date_key cluster by customer_id
as
-- base table
with dat as (
  select *,
        cast(null as string) subscriber_type,
        cast(null as string)tkn_source,
        cast(null as int64)tikinow_record
        from dwh.fact_sales_order_nmv_2017
union all 
  select * except (subscriber_type,tkn_source,tikinow_record),
        subscriber_type,tkn_source,tikinow_record
        from dwh.fact_sales_order_nmv),

-- purchase products
purProdMax as (select customer_key, max(safe_divide(value,qty)) max_value from dat where is_virtual is not true 
and dat.order_code not in (select distinct order_code from dat
where order_type in(2,3)) group by customer_key),
purProd as (select dat.customer_key, purProdMax.max_value,any_value(dp.product_name) max_value_item, dp.product_key
from dat
join purProdMax
on purProdMax.customer_key=dat.customer_key
and safe_divide(dat.value,dat.qty)=purProdMax.max_value
join dwh.dim_product_full dp
on dat.product_key=dp.product_key
and dp.is_free_gift is not true
where dat.order_code not in (select distinct order_code from dat
where order_type in(2,3))
group by dat.customer_key,purProdMax.max_value, dp.product_key
),

--purchase cate
purCateCnt as (
select 
  dat.customer_key,
  case when dp.cate_report like 'Book%' then 'book'
    when dp.cate_report ='3C' then 'electronics'
    when dp.cate_report ='CG' then 'consumer'
    when dp.cate_report ='Fashion' then 'fashion'
    when dp.cate_report ='Lifestyle' then 'lifestyle'
    when dp.cate_report like 'Digital%' then 'digital'
    else null
  end cate_report, 
  count(distinct dat.order_code) order_count, sum(dat.value) cate_non_discount_value
from  dat
join dwh.dim_product_full dp
on dat.product_key=dp.product_key
and dp.is_free_gift is not true
and dp.cate_report is not null
where dat.order_code not in (select distinct order_code from dat
where order_type in(2,3))
group by dat.customer_key,dp.cate_report
),
purCateRank as (select customer_key, cate_report, order_count, cate_non_discount_value, row_number() over (partition by customer_key 
order by order_count desc,cate_non_discount_value desc) cate_rank
from purCateCnt),

-- purchase time frequency
purTime as(
select customer_key, daytimebucket, count(distinct order_code) order_count
from dat join dwh.dim_time ti
on dat.time_key=ti.time_key
where order_type not in (2,3)
group by customer_key, daytimebucket),
purTimeMax as (select customer_key, max(order_count) max_order_count from purTime group by customer_key),
purTimeTab as (select purTime.customer_key,STRING_AGG(purTime.daytimebucket,'; ') usual_purchase_time, purTimeMax.max_order_count
from purTime join purTimeMax on purTime.customer_key=purTimeMax.customer_key and purTime.order_count=purTimeMax.max_order_count
group by purTime.customer_key,purTimeMax.max_order_count),

--TikiNow order count
cnt as (
    select 
      customer_key, 
      count(distinct order_code) tikinow_order_count
  from dat f
  join dwh.dim_shipping_plan s 
  on s.shipping_plan_key=f.shipping_plan_key
  and s.shipping_type ='2h'
  where f.order_code not in (select distinct order_code from dat
  where order_type in(2,3))
  group by f.customer_key),

--Purchase dates, order_count, online_payment_perc
purDate as(
  select customer_key, 
      min(date_key) first_purchase_date, 
      max(date_key) last_purchase_date,
      count(distinct order_code) unique_order_count,
      safe_divide(sum(case when lower(dm.payment_method) not in ('cod','free') then 1 else 0 end),count(distinct order_code))*100 online_payment_perc
    from (select distinct order_code, customer_key, date_key,payment_method_key from  dat) data
    join dwh.dim_payment_method dm
    on dm.payment_method_key= data.payment_method_key
    where order_code not in (select distinct order_code from dat
    where order_type in(2,3))
    group by customer_key
), 

--NMV,discounts, tikiNow_product_count
sales as (
select customer_key,
    sum(
        case when order_type=1 
            then (ifnull(Value,0) - (ifnull(Discount,0) - ifnull(Discount_TikiXu,0)) + (ifnull(Shipping_Value,0) - ifnull(Shipping_Discount_Value,0)) + ifnull(Handling_Fee,0))
        else 0
        end) -- order type 1 cmv
    -
    sum(
        case when order_type=2 
            then (ifnull(Value,0) - (ifnull(Discount,0) - ifnull(Discount_TikiXu,0)) + (ifnull(Shipping_Value,0) - ifnull(Shipping_Discount_Value,0)) + ifnull(Handling_Fee,0))
        else 0 
        end) -- order type 2 cancel
    -
    sum(
        case when order_type=3 
            then (ifnull(Value,0) - (ifnull(Discount,0) - ifnull(Discount_TikiXu,0)) + (ifnull(Shipping_Value,0) - ifnull(Shipping_Discount_Value,0)) + ifnull(Handling_Fee,0))
        else 0
        end) --order type 3 rma
        total_nmv,
     sum(
        case when order_type=1 
            then (ifnull(Discount,0) + ifnull(Shipping_Discount_Value,0))
        else 0
        end) -- order type 1 cmv
    -
    sum(
        case when order_type=2 
            then (ifnull(Discount,0) + ifnull(Shipping_Discount_Value,0))
        else 0 
        end) -- order type 2 cancel
    -
    sum(
        case when order_type=3 
            then (ifnull(Discount,0) + ifnull(Shipping_Discount_Value,0))
        else 0
        end) --order type 3 rma
        total_ship_n_discount,
    sum(
        case when order_type=1 
            then ifnull(Discount_TikiXu,0)
        else 0
        end) -- order type 1 cmv
    -
    sum(
        case when order_type=2 
            then  ifnull(Discount_TikiXu,0)
        else 0 
        end) -- order type 2 cancel
    -
    sum(
        case when order_type=3 
            then ifnull(Discount_TikiXu,0)
        else 0
        end) --order type 3 rma
        total_tikixu_discount,
    sum(
        case when order_type=1 and s.shipping_type ='2h'
            then 1
        else 0
        end) -- order type 1 cmv
    -
    sum(
        case when order_type=2 and s.shipping_type ='2h'
            then  1
        else 0 
        end) -- order type 2 cancel
    -
    sum(
        case when order_type=3 and s.shipping_type ='2h'
            then 1
        else 0
        end) --order type 3 rma
    tikinow_product_count
from dat
join dwh.dim_shipping_plan s 
on s.shipping_plan_key=dat.shipping_plan_key
group by customer_key),
-- image path
-- image_path as
-- (select distinct product_id, any_value(case when replace((value),'\n','') is null or replace((value),'\n','')='' then null 
--           when STRPOS(lower(value),'https:')>0 then replace(replace((value),'\n',''),' ','')
--           when STRPOS(lower(value),'product') + STRPOS(lower(value),'tmp')>0 then concat('https://salt.tikicdn.com/cache/w1200/ts/',replace(replace((value),'\n',''),' ',''))
--           else concat('https://salt.tikicdn.com/cache/w1200/media/catalog/product',replace(replace((value),'\n',''),' ',''))
--           end) image 
--           from `tiki-dwh.ecom.catalog_product_entity_varchar` 
--           where value is not null and  value <>'' 
--           and attribute_code = 'image' group by product_id),
--review and rating
rev as (select customer_id,countif( status = 1) approved_review_count
from (select distinct customer_id, id, status from `tiki-dwh.ecom.review_20*`)  
group by customer_id),
rating as( select t1.customer_id, dp.product_key, dp.product_erp_id, row_number() over(partition by t1.customer_id) r
--, row_number() over(partition by t1.customer_id order by t3.review_id desc) prod_rank
FROM (select distinct customer_id, id from `tiki-dwh.ecom.review_20*`) t1 
LEFT JOIN (select distinct review_id, product_id, rating_point from `tiki-dwh.ecom.rating`
where rating_point=5) t3 
ON t1.id = t3.review_id
left join dwh.dim_product_full dp
on t3.product_id=dp.product_key
group by t1.customer_id, dp.product_key, dp.product_erp_id
),
rating_prod as(select customer_id, string_agg(cast(product_key as string),";") rating_5stars_product
from rating where r<4 group by customer_id),

-- warehouse location
whcount as (select customer_key,processing_warehouse_id,count(distinct dat.order_code) whcnt
from dat where order_code not in (select distinct order_code from dat
where order_type in(2,3))
group by customer_key,processing_warehouse_id),
customerwhcnt as (select dat.customer_key, count(distinct dat.order_code) cnt, countif(upper(dp.business_type) like "%CB%")*100/count(distinct dat.order_code) crossborder,countif(upper(dp.business_type) like "%CB%") crossborder_cnt
from dat
left join dwh.dim_product_full dp
on dat.product_key=dp.product_key
and upper(dp.business_type) like "%CB%"
where dat.order_code not in (select distinct order_code from dat
where dat.order_type in(2,3))
group by dat.customer_key),
wh as (
select
whcount.customer_key,
--   reg.name warehouse_region_name, 
--   sum(whcount.whcnt) order_count,
--   round(sum(whcount.whcnt/customerwhcnt.cnt)*100) whregion_perc,
--   row_number() over(partition by whcount.customer_key order by sum(whcount.whcnt) DESC ) whrank
round(sum(case when reg.name='Hải Phòng' then (whcount.whcnt/customerwhcnt.cnt)*100 else 0 end)) location_Hai_Phong,
round(sum(case when reg.name='Cần Thơ' then (whcount.whcnt/customerwhcnt.cnt)*100 else 0 end)) location_Can_Tho,
round(sum(case when reg.name='Khánh Hòa' then (whcount.whcnt/customerwhcnt.cnt)*100 else 0 end)) location_Khanh_Hoa,
round(sum(case when reg.name='Hà Nội' then (whcount.whcnt/customerwhcnt.cnt)*100 else 0 end)) location_Ha_Noi,
round(sum(case when reg.name='Đà Nẵng' then (whcount.whcnt/customerwhcnt.cnt)*100 else 0 end)) location_Da_Nang,
round(sum(case when reg.name='Hồ Chí Minh' then (whcount.whcnt/customerwhcnt.cnt)*100 else 0 end)) location_Ho_Chi_Minh,
round(sum(case when reg.name='Hưng Yên' then (whcount.whcnt/customerwhcnt.cnt)*100 else 0 end)) location_Hung_Yen,
round(sum(case when reg.name='Bình Dương' then (whcount.whcnt/customerwhcnt.cnt)*100 else 0 end)) location_Binh_Duong,
round(sum(case when reg.name='Ninh Thuận' then (whcount.whcnt/customerwhcnt.cnt)*100 else 0 end)) location_Ninh_Thuan,
round(customerwhcnt.crossborder) location_quoc_te
from whcount
join customerwhcnt on customerwhcnt.customer_key=whcount.customer_key
join ecom.tools_erp_warehousing_warehouse w
on whcount.processing_warehouse_id = w.id
join ecom.config_country_region reg
on reg.tiki_code=substr(w.tiki_code,1,5)
group by whcount.customer_key,customerwhcnt.crossborder)
--Main table
select 
current_date('+7') date_key,purDate.customer_key,
cust.id customer_id, cust.full_name, 
case  when cust.gender=1 then 'Male'
      when cust.gender=0 then 'Female'
      else null end gender,
case when cust.group_id=27 then true else false end is_reseller,
purDate.first_purchase_date, 
purDate.last_purchase_date,
date_diff('2020-02-29',purDate.first_purchase_date, DAY) account_age,
case  when purTimeTab.usual_purchase_time ='Late Night (00:00 AM To 02:59 AM)' then 'late_night'
      when purTimeTab.usual_purchase_time ='Early Morning(03:00 AM To 6:59 AM)' then 'early_morning'
      when purTimeTab.usual_purchase_time ='AM Peak (7:00 AM To 8:59 AM)' then 'am_peak'
      when purTimeTab.usual_purchase_time ='Mid Morning (9:00 AM To 11:59 AM)' then 'mid_morning'
      when purTimeTab.usual_purchase_time ='Lunch (12:00 PM To 13:59 PM)' then 'lunch'
      when purTimeTab.usual_purchase_time ='Mid Afternoon (14:00 PM To 15:59 PM)' then 'mid_afternoon'
      when purTimeTab.usual_purchase_time ='PM Peak (16:00 PM To 17:59 PM)' then 'pm_peak'
      when purTimeTab.usual_purchase_time ='Evening (18:00 PM To 23:59 PM)' then 'evening'
      else 'random' end usual_purchase_time,
sales.total_nmv, 
purDate.unique_order_count,
purDate.online_payment_perc,
sales.total_ship_n_discount, 
sales.total_tikixu_discount,
cnt.tikinow_order_count, 
sales.tikinow_product_count,
purCateRank1.cate_report top_cate_1,
purCateRank2.cate_report top_cate_2,
purCateRank3.cate_report top_cate_3,
purProd.max_value_item,
purProd.max_value,
purProd.product_key max_value_item_id,
rev.approved_review_count,
rating_prod.rating_5stars_product,
wh.location_Hai_Phong,
wh.location_Can_Tho,
wh.location_Khanh_Hoa,
wh.location_Ha_Noi,
wh.location_Da_Nang,
wh.location_Ho_Chi_Minh,
wh.location_Hung_Yen,
wh.location_Binh_Duong,
wh.location_Ninh_Thuan,
wh.location_quoc_te,
current_timestamp() created_date
from ecom.customer cust
join purDate
on purDate.customer_key=cust.backend_id
join sales
on sales.customer_key=cust.backend_id
left join cnt
on cnt.customer_key=cust.backend_id
left join purTimeTab on purTimeTab.customer_key=cust.backend_id
left join purCateRank purCateRank1 on purCateRank1.customer_key=cust.backend_id and purCateRank1.cate_rank=1
left join purCateRank purCateRank2 on purCateRank2.customer_key=cust.backend_id and purCateRank2.cate_rank=2
left join purCateRank purCateRank3 on purCateRank3.customer_key=cust.backend_id and purCateRank3.cate_rank=3
left join purProd on purProd.customer_key=cust.backend_id
left join wh wh on wh.customer_key=cust.backend_id
left join rating_prod on rating_prod.customer_id=cust.id
left join rev on rev.customer_id=cust.id
-- left join rating_prod rating_prod4 on rating_prod4.customer_id=cust.id and rating_prod1.prod_rank=4
-- left join rating_prod rating_prod5 on rating_prod5.customer_id=cust.id and rating_prod1.prod_rank=5
-- left join rating_prod rating_prod6 on rating_prod6.customer_id=cust.id and rating_prod1.prod_rank=6
-- left join rating_prod rating_prod7 on rating_prod7.customer_id=cust.id and rating_prod1.prod_rank=7
-- left join rating_prod rating_prod8 on rating_prod8.customer_id=cust.id and rating_prod1.prod_rank=8
-- left join rating_prod rating_prod9 on rating_prod9.customer_id=cust.id and rating_prod1.prod_rank=9
-- left join rating_prod rating_prod10 on rating_prod1.customer_id=cust.id and rating_prod1.prod_rank=10





