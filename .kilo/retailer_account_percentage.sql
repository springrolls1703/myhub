WITH raw AS
(
SELECT DISTINCT
user_id,
EXTRACT(DATE FROM event_time) as account_date
FROM `kilo-data-prod-data-warehouse.amplitude.retailer_events` e
CROSS JOIN UNNEST(event_properties) as p
LEFT JOIN `kilo-data-prod-data-warehouse.kilo.user_retailers` u ON e.user_id = CAST(u.id AS STRING)
WHERE (
event_type LIKE '%login complete%' or event_type LIKE '%signup success%') and (key = 'source') and (user_id IS NOT NULL) and (EXTRACT(DATE FROM event_time) > '2021-12-31') and (lower(value) = 'ios' or lower(value) = 'android')
)

, retailer_app_account AS ( 
SELECT DISTINCT date, (SELECT COUNT(DISTINCT user_id) as app_account FROM raw WHERE account_date <= date) as no_app_account FROM UNNEST(GENERATE_DATE_ARRAY('2022-01-01', CURRENT_DATE())) AS date
)

, retailer_total_account AS (
SELECT DISTINCT date, (SELECT COUNT(DISTINCT id) as total_account FROM `kilo-data-prod-data-warehouse.kilo.user_retailers` WHERE EXTRACT(DATE FROM created_at) <= date) as total_account
FROM UNNEST(GENERATE_DATE_ARRAY('2022-01-01', CURRENT_DATE())) AS date
)

SELECT a.date, no_app_account,total_account, ROUND((no_app_account/total_account),4) as app_account_percentage
FROM retailer_app_account a
LEFT JOIN retailer_total_account t ON a.date=t.date
ORDER BY 1 DESC


