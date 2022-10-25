#standardSQL
WITH
fact_sales_order_2014_current AS (
	SELECT customer_id , order_code , created_at , confirmed_date_key , status, created_date_key , sale_channel , original_code , original_increment_id  
    FROM    `tiki-dwh.fna.fact_sales_order_2*`
    WHERE _TABLE_SUFFIX >= '0140101'
	UNION ALL  
	SELECT customer_id , order_code , created_at , confirmed_date_key , status, created_date_key , sale_channel , original_code , original_increment_id
    FROM    `tiki-dwh.fna.fact_sales_order_current_year`),

fact_sales_order_2010_2013 AS (
	SELECT customer_id , order_code , created_at , confirmed_date_key , status, created_date_key , sale_channel , original_code , original_increment_id 
    FROM    `tiki-dwh.fna.fact_sales_order_2010*`
	WHERE _TABLE_SUFFIX < '0140101'
     ),
    
fact_sales_order_2010_2013_fixed AS (
	SELECT
		customer_id,	
		order_code,	
		created_at,
	CASE
		WHEN confirmed_date_key IS NOT NULL THEN confirmed_date_key
		WHEN confirmed_date_key IS NULL
		AND (status NOT LIKE 'canceled%'
		AND status!='closed') THEN created_date_key
		WHEN confirmed_date_key IS NULL AND (status LIKE 'canceled%' OR status='closed') THEN created_date_key
		END confirmed_date_key
	FROM 	fact_sales_order_2010_2013
	WHERE sale_channel = 'ONLINE'
		AND original_code is null
		AND original_increment_id is null
	),

fact_sales_order AS (
	SELECT 	*	FROM 	fact_sales_order_2010_2013_fixed
	WHERE confirmed_date_key is not null
	UNION ALL
	SELECT
		customer_id,		
		order_code,	
		created_at,
		confirmed_date_key
	FROM 	fact_sales_order_2014_current
	WHERE sale_channel = 'ONLINE'
		AND original_code is null
		AND original_increment_id is null
		AND confirmed_date_key is not null ),
	
temp AS(
	SELECT 
		fso.*,
		ROW_NUMBER() over (PARTITION BY customer_id ORDER BY created_at) AS rn
	FROM fact_sales_order  fso
	),
	
activation AS(
	SELECT 
		customer_id,		
        order_code,
		PARSE_DATE('%Y%m%d', CAST(confirmed_date_key AS STRING)) as date,
    SUBSTR(CAST(confirmed_date_key AS STRING),1,6) AS month,
    EXTRACT(ISOWEEK FROM PARSE_DATE('%Y%m%d', CAST(confirmed_date_key AS STRING))) AS week
	FROM temp
	WHERE rn=1)

, act AS (
SELECT DISTINCT
	a.customer_id,
	a.date,
  a.month,
  a.week,
	CASE
    WHEN campaign LIKE '%Google_Search_SEM_Gross_Gross_@NBrand Keyword_@CAll%' THEN 'Google Brand'
    WHEN (LOWER(source) LIKE '%tiki.vn%' OR source LIKE '%product%')AND medium LIKE '%referrer%' THEN 'Apps'
    WHEN LOWER(campaign) LIKE '%partnership%' OR campaign LIKE '%PNS%' THEN 'Partnership'
    WHEN campaign LIKE '%Branding%' OR campaign LIKE '%UM020718%' OR campaign LIKE '%Back To School%' OR campaign LIKE '%UM180701%' 
    OR campaign LIKE '%GDN\\_B2S%' OR campaign LIKE '%DCH1808%'
    OR campaign LIKE '%Brand Awareness%' 
    THEN 'Brand'
    ELSE 'Nonbrand' end as strategy,
CASE
  WHEN Lower(source) in ('tiki.vn','products','pipe.tikicdn.com','hotro.tiki.vn','tiki.gotadi.com','vcdn.tikicdn.com','quay.tiki.vn',
  'mapi.tiki.vn','dzut.tiki.vn','hotel.tiki.vn','payment.tiki.vn','facebook.tiki.vn','tuyendung.tiki.vn') THEN 'PILs'
  WHEN (LOWER(source) LIKE '%google%' OR LOWER(source) LIKE '%bing%' OR LOWER(source) LIKE '%yahoo%') AND medium LIKE 'organic'   THEN 'Organic Search'
  WHEN LOWER(source) LIKE '%google%' THEN 'Google'
  WHEN source LIKE '(direct)' AND medium IN('(none)' ,'(not set)') THEN 'Direct'
  WHEN (LOWER(source) LIKE '%tiki.vn%' OR source LIKE '%product%')AND medium LIKE '%referrer%' THEN 'Apps'
  WHEN LOWER(medium) LIKE '%referral%' THEN 'Referral'
  WHEN LOWER(source) LIKE '%criteo%' AND LOWER(medium) LIKE '%cpc%' THEN 'Retargeting Criteo'
  WHEN (LOWER(source) LIKE '%insider%' OR LOWER(source) LIKE '%noti%') AND (LOWER(medium) LIKE '%ios%' OR LOWER(medium) LIKE '%android%' 
    OR LOWER(medium) LIKE '%web%' OR LOWER(medium) LIKE '%app%') THEN 'Push Noti'
  WHEN (LOWER(source) LIKE '%facebook%' 
    OR (LOWER(source) = '(not set)' AND LOWER(medium) = 'dpas') 
    OR (LOWER(source) = 'fb' AND LOWER(medium) = 'post') 
    OR (LOWER(source) = 'fanpage' AND LOWER(medium) = 'partner')) THEN 'Facebook'
    WHEN LOWER(source) LIKE '%admicro%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Admicro'
  WHEN LOWER(source) LIKE '%adtima%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Adtima'
  WHEN LOWER(source) LIKE '%chin%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Chin'
  WHEN LOWER(source) LIKE '%pmax%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Pmax'
  WHEN LOWER(source) LIKE '%24h%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN 24H'
  WHEN (LOWER(source) LIKE '%medihub%' OR LOWER(source) LIKE '%coccoc_newtab_media%') 
   AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Others'
  WHEN LOWER(source) LIKE '%rtbhouse%' AND LOWER(medium) LIKE '%retarge%' THEN 'Retargeting RTBHouse'
  WHEN (LOWER(source) like '%email%' or LOWER(medium) LIKE '%email%') THEN 'Email'
  WHEN LOWER(source) LIKE '%accesstrade%' THEN 'Affiliate Accesstrade'
  WHEN LOWER(source) LIKE '%ecomobi%' THEN 'Affiliate Ecomobi'
  WHEN LOWER(source) LIKE '%masoffer%' THEN 'Affiliate Masoffer'
  WHEN LOWER(source) LIKE '%websosanh%' THEN 'Affiliate Websosanh'
  WHEN LOWER(source) like '%cityads%' THEN 'Affiliate Cityads'
  ELSE 'Others'
  END as channel,
  campaign ,
  source,
  medium
 FROM activation a
LEFT JOIN (
SELECT 
  date,
  original_code ,
  source ,
  medium ,
  campaign 
FROM `tiki-dwh.fna.fna_nmv_lastclick_2*` 
WHERE _TABLE_SUFFIX >= SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), MONTH), INTERVAL 3 MONTH)),2,7)
  AND _TABLE_SUFFIX <= SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY)),2,7)
  AND (sale_channel = 'ONLINE' OR sale_channel = 'B2B' OR sale_channel = 'Bán offline')
  AND (platform != 'external' OR platform is null)
  AND LOWER(source) LIKE '%facebook%'
  AND ((LOWER(medium) = 'dpas') or (LOWER(medium) = 'ads') or (LOWER(campaign) LIKE '%dis_%') ) 
  AND merchant_id not in (25,31)
) lc ON a.order_code = lc.original_code AND a.date = PARSE_DATE('%Y%m%d', CAST(lc.date AS STRING))
WHERE a.date >= DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), MONTH), INTERVAL 3 MONTH)
  AND a.date <= DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY) 
)

, act_f AS (
SELECT 
  date,
  month,
  week,
  strategy,
  channel,
  campaign,
  source,
  medium,
  COUNT(DISTINCT customer_id) AS act,
  NULL AS cmv,
  NULL AS nmv,
  NULL AS org_order,
  NULL AS confirmed_unit
  FROM act
  WHERE source IS NOT NULL 
    AND medium IS NOT NULL
  GROUP BY 1,2,3,4,5,6,7,8
)

, data1 as
(
  SELECT 
        date, 
        d.original_code ,
        d.campaign ,
        d.source ,
        d.medium ,
        d.product_id,
        d.confirmed_value ,
        d.confirmed_discount ,
        d.cancelled_value ,
        d.cancelled_discount ,
        d.rma_val ,
        d.confirmed_qty,
        d.cancelled_qty,
        d.rma_qty
  FROM `tiki-dwh.fna.fna_nmv_lastclick_2*`  d
  WHERE 1=1
    AND (d.sale_channel = 'ONLINE' OR d.sale_channel = 'B2B' OR d.sale_channel = 'Bán offline')
    AND (d.platform != 'external' OR d.platform is null)
    AND LOWER(source) LIKE '%facebook%'
    AND ((LOWER(medium) = 'dpas') or (LOWER(medium) = 'ads') or (LOWER(campaign) LIKE '%dis_%')) 
    AND d.merchant_id not in (25,31)
    AND _TABLE_SUFFIX >= SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), MONTH), INTERVAL 4 MONTH)),2,7)
    AND _TABLE_SUFFIX <= SUBSTR(FORMAT_DATE('%Y%m%d',DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY)),2,7)
)

, cmv_nmv AS (
SELECT 
PARSE_DATE('%Y%m%d',CAST(d.date AS STRING)) AS date,
SUBSTR(CAST(d.date AS STRING),1,6) AS month,
EXTRACT(ISOWEEK FROM PARSE_DATE('%Y%m%d',CAST(d.date AS STRING))) AS week,
CASE
    WHEN campaign LIKE '%Google_Search_SEM_Gross_Gross_@NBrand Keyword_@CAll%' THEN 'Google Brand'
    WHEN (LOWER(source) LIKE '%tiki.vn%' OR source LIKE '%product%')AND medium LIKE '%referrer%' THEN 'Apps'
    WHEN LOWER(campaign) LIKE '%partnership%' OR campaign LIKE '%PNS%' THEN 'Partnership'
    WHEN campaign LIKE '%Branding%' OR campaign LIKE '%UM020718%' OR campaign LIKE '%Back To School%' 
    OR campaign LIKE '%UM180701%' OR campaign LIKE '%GDN\\_B2S%' OR campaign LIKE '%DCH1808%'
    OR campaign LIKE '%Brand Awareness%' OR campaign LIKE '%YBR%' THEN 'Brand'
    ELSE 'Nonbrand' end as strategy,
CASE
  WHEN Lower(source) in ('tiki.vn','products','pipe.tikicdn.com','hotro.tiki.vn','tiki.gotadi.com','vcdn.tikicdn.com','quay.tiki.vn',
  'mapi.tiki.vn','dzut.tiki.vn','hotel.tiki.vn','payment.tiki.vn','facebook.tiki.vn','tuyendung.tiki.vn') THEN 'PILs'
  WHEN (LOWER(source) LIKE '%google%' OR LOWER(source) LIKE '%bing%' OR LOWER(source) LIKE '%yahoo%') AND medium LIKE 'organic'   THEN 'Organic Search'
  WHEN LOWER(source) LIKE '%google%' THEN 'Google'
  WHEN source LIKE '(direct)' AND medium IN('(none)' ,'(not set)') THEN 'Direct'
  WHEN (LOWER(source) LIKE '%tiki.vn%' OR source LIKE '%product%')AND medium LIKE '%referrer%' THEN 'Apps'
  WHEN LOWER(medium) LIKE '%referral%' THEN 'Referral'
  WHEN LOWER(source) LIKE '%criteo%' AND LOWER(medium) LIKE '%cpc%' THEN 'Retargeting Criteo'
  WHEN (LOWER(source) LIKE '%insider%' OR LOWER(source) LIKE '%noti%') AND (LOWER(medium) LIKE '%ios%' OR LOWER(medium) LIKE '%android%' 
    OR LOWER(medium) LIKE '%web%' OR LOWER(medium) LIKE '%app%') THEN 'Push Noti'
  WHEN (LOWER(source) LIKE '%facebook%' 
    OR (LOWER(source) = '(not set)' AND LOWER(medium) = 'dpas') 
    OR (LOWER(source) = 'fb' AND LOWER(medium) = 'post') 
    OR (LOWER(source) = 'fanpage' AND LOWER(medium) = 'partner')) THEN 'Facebook'
    WHEN LOWER(source) LIKE '%admicro%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Admicro'
  WHEN LOWER(source) LIKE '%adtima%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Adtima'
  WHEN LOWER(source) LIKE '%chin%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Chin'
  WHEN LOWER(source) LIKE '%pmax%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Pmax'
  WHEN LOWER(source) LIKE '%24h%' AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN 24H'
  WHEN (LOWER(source) LIKE '%medihub%' OR LOWER(source) LIKE '%coccoc_newtab_media%') 
   AND (LOWER(medium) LIKE '%displa%' OR LOWER(medium) LIKE '%cpc%') THEN 'LDN Others'
  WHEN LOWER(source) LIKE '%rtbhouse%' AND LOWER(medium) LIKE '%retarge%' THEN 'Retargeting RTBHouse'
  WHEN (LOWER(source) like '%email%' or LOWER(medium) LIKE '%email%') THEN 'Email'
  WHEN LOWER(source) LIKE '%accesstrade%' THEN 'Affiliate Accesstrade'
  WHEN LOWER(source) LIKE '%ecomobi%' THEN 'Affiliate Ecomobi'
  WHEN LOWER(source) LIKE '%masoffer%' THEN 'Affiliate Masoffer'
  WHEN LOWER(source) LIKE '%websosanh%' THEN 'Affiliate Websosanh'
  WHEN LOWER(source) like '%cityads%' THEN 'Affiliate Cityads'
  ELSE 'Others'
  END as channel,
  campaign,
  source,
  medium,
  NULL AS act,
  SUM(confirmed_value) AS cmv ,
  SUM(confirmed_value- confirmed_discount- cancelled_value+ cancelled_discount- rma_val) as nmv,
  COUNT(DISTINCT original_code) AS org_order,
  SUM(confirmed_qty) AS confirmed_unit
FROM data1 d
WHERE PARSE_DATE('%Y%m%d',CAST(d.date AS STRING)) >= 
      DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE('+7'), INTERVAL 1 DAY), MONTH), INTERVAL 4 MONTH)
group by 1,2,3,4,5,6,7,8
)

,
a1 AS
(
    SELECT
        date,
        month,
        week,
        campaign ,
        safe_cast(REGEXP_EXTRACT(campaign, r"_Z.(.+?$)") as int64) as ad_id,
        source,
        medium,
        SUM(act)            AS act,
        SUM(cmv)            AS cmv,
        SUM(nmv)            AS nmv,
        SUM(org_order)      AS org_order,
        SUM(confirmed_unit) AS confirmed_unit,
        MAX(date) AS latest_date
        FROM (
        SELECT * FROM act_f
        UNION ALL
        SELECT * FROM cmv_nmv)
        WHERE date >= DATE_SUB(DATE_TRUNC(CURRENT_DATE('+7'), MONTH), INTERVAL 1 MONTH)
        GROUP BY 1,2,3,4,5,6,7
       
        )


, b1 AS
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
),
cost_and_cmv AS (
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
        cmv, 
        nmv, 
        act,
        org_order,
        CAST(NULL AS FLOAT64) AS spend, 
        CAST(NULL AS INT64) AS unique_clicks,
        CAST(NULL AS INT64) AS impressions 
  FROM a1
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
        CAST(NULL AS INT64) AS org_order,
        spend, 
        unique_clicks,
        impressions

  FROM b1
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
                        campaign
                       ,ad_id
                       ,CASE 
                            WHEN ad_name LIKE 'DIS%' THEN ad_name
                            WHEN ad_name NOT LIKE 'DIS%' AND campaign LIKE 'DIS%' THEN campaign
                            WHEN account_name LIKE 'App' AND Upper(campaign_name) LIKE '%ANDROID%' THEN 'DIS_APP_FB_ALL_ALL_ALL_ALL_ALL_AND_UNK'
                            WHEN account_name LIKE 'App' AND Upper(campaign_name) LIKE '%IOS%' THEN 'DIS_APP_FB_ALL_ALL_ALL_ALL_ALL_IOS_UNK'
                            WHEN account_name LIKE '%PNS%' OR campaign_name LIKE '%PNS%' THEN 'DIS_PNS_FB_ALL_ALL_ALL_ALL_ALL_UNK_UNK'
                            ELSE 'DIS_NBR_FB_ALL_ALL_ALL_ALL_ALL_UNK_UNK' 
                        END AS ad_name
                       ,IF(account_name IS NULL, 0, 1) AS plus
                 FROM  cost_and_cmv
                )
      )
      WHERE rank_get_name = 1 
      ) WHERE rank_adname = 1
)

SELECT 
      t1.date,
      FORMAT_DATE("%D", t1.date) as e_date,
      FORMAT_DATE("%V", t1.date) as week,
      FORMAT_DATE("%m", t1.date) as month,
      FORMAT_DATE("%G", t1.date) as year,
      t2.account_name, 
      t2.adset_name, 
      t2.ad_name, 
      t2.campaign_name, 
      t2.campaign, 
      t2.ad_id, 
      t2.source, 
      t2.medium, 
      SUM(cmv) as cmv, 
      SUM(nmv) as nmv, 
      SUM(act) as act,
      SUM(org_order) as org_order,
      SUM(spend) as spend, 
      SUM(unique_clicks) as unique_clicks,
      SUM(impressions) as impressions,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(1)] spend_strategy,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(3)] ad_type,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(4)] campaign_type,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(7)] category,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(10)] camp_name,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(11)] camp_code,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(12)] Audience_list,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(13)] Time_retention,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(14)] Gender,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(15)] Age,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(16)] Placement,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(17)] Destination,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(18)] Banner,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(19)] Content,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(20)] Optimize,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(21)] Bidding_event,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(22)] Objective,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(23)] Cate_level,
      SPLIT(t2.ad_name, '_')[SAFE_OFFSET(24)] Strategy
FROM cost_and_cmv AS t1
     LEFT JOIN get_campaign_name AS t2
     ON t1.ad_id = t2.ad_id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39
