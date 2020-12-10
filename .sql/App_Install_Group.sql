#standardSQL
with
cleaning_data as (
SELECT
    install_time,
    CASE
    WHEN android_id = 'null' THEN null 
    ELSE android_id END as install_android_id,
    
    CASE
    WHEN advertising_id = 'null' THEN null 
    ELSE advertising_id END as install_advertising_id,
    
    CASE
    WHEN idfa = 'null' THEN null 
    ELSE idfa END as install_idfa,
    
    CASE
    WHEN idfv = 'null' THEN null 
    ELSE idfv END as install_idfv,
    CAST (NULL AS string) AS uninstall_android_id,
    CAST (NULL AS string) AS uninstall_advertising_id,
    CAST (NULL AS string) AS uninstall_idfa,
    CAST (NULL AS string) AS uninstall_idfv,
        
    CASE
    WHEN Media_Source IN ('googleadwords_int','Facebook Ads','criteonew_int','liftoff_int','rtbhouse_int') AND (Campaign LIKE '%_App%' or Campaign LIKE '%_APP_%') THEN 'Paid'
    WHEN Media_Source IN ('App Push Email','App Push Source','Email') AND (Campaign LIKE '%_App%' or Campaign LIKE '%_APP_%') THEN 'Managed'
    WHEN Media_Source IN ('organic', 'Organic','ORGANIC') THEN 'Organic'
    ELSE 'Other'
    END AS Install_Category,
    
    CASE 
    WHEN Media_Source IN ('googleadwords_int') AND (Campaign LIKE '%_App%' or Campaign LIKE '%_APP_%') THEN 'Google_APP'
    WHEN Media_Source IN ('Facebook Ads') AND (Campaign LIKE '%_App%' or Campaign LIKE '%_APP_%') THEN 'Facebook_APP'
    WHEN Media_Source IN ('criteonew_int') AND (Campaign LIKE '%_App%' or Campaign LIKE '%_APP_%') THEN 'Criteo_APP'
    WHEN Media_Source IN ('liftoff_int') AND (Campaign LIKE '%_App%' or Campaign LIKE '%_APP_%') THEN 'Liftoff_APP'
    WHEN Media_Source IN ('rtbhouse_int') AND (Campaign LIKE '%_App%' or Campaign LIKE '%_APP_%') THEN 'RTBHouse_APP'
    WHEN Media_Source IN ('App Push Email','Email') THEN 'Email'
    WHEN Media_Source IN ('App Push Source') THEN 'Push'
    WHEN Media_Source IN ('organic', 'Organic','ORGANIC') THEN 'Organic'
    ELSE 'Other'
    END AS Install_Source
    
FROM `tiki-dwh.appsflyer.installs_20*`
UNION ALL
SELECT
    CAST (string_field_3 AS TIMESTAMP) AS install_time,
    CAST (NULL AS string) AS install_android_id,
    CAST (NULL AS string) AS install_advertising_id,
    CAST (NULL AS string) AS install_idfa,
    CAST (NULL AS string) AS install_idfv,
    CASE
    WHEN string_field_64 = 'null' THEN null 
    ELSE string_field_64 END as uninstall_android_id,
    
    CASE
    WHEN string_field_65 = 'null' THEN null 
    ELSE string_field_65 END as uninstall_advertising_id,
    
    CASE
    WHEN string_field_67 = 'null' THEN null 
    ELSE string_field_67 END as uninstall_idfa,
    
    CASE
    WHEN string_field_68 = 'null' THEN null 
    ELSE string_field_68 END as uninstall_idfv,
    
    CASE
    WHEN string_field_15 IN ('googleadwords_int','Facebook Ads','criteonew_int','liftoff_int','rtbhouse_int') AND (string_field_19 LIKE '%_App%' or string_field_19 LIKE '%_APP_%') THEN 'Paid'
    WHEN string_field_15 IN ('App Push Email','App Push Source','Email') AND (string_field_19 LIKE '%_App%' or string_field_19 LIKE '%_APP_%') THEN 'Managed'
    WHEN string_field_15 IN ('organic', 'Organic','ORGANIC') THEN 'Organic'
    ELSE 'Other'
    END AS Install_Category,
    
    CASE 
    WHEN string_field_15 IN ('googleadwords_int') AND (string_field_19 LIKE '%_App%' or string_field_19 LIKE '%_APP_%') THEN 'Google_APP'
    WHEN string_field_15 IN ('Facebook Ads') AND (string_field_19 LIKE '%_App%' or string_field_19 LIKE '%_APP_%') THEN 'Facebook_APP'
    WHEN string_field_15 IN ('criteonew_int') AND (string_field_19 LIKE '%_App%' or string_field_19 LIKE '%_APP_%') THEN 'Criteo_APP'
    WHEN string_field_15 IN ('liftoff_int') AND (string_field_19 LIKE '%_App%' or string_field_19 LIKE '%_APP_%') THEN 'Liftoff_APP'
    WHEN string_field_15 IN ('rtbhouse_int') AND (string_field_19 LIKE '%_App%' or string_field_19 LIKE '%_APP_%') THEN 'RTBHouse_APP'
    WHEN string_field_15 IN ('App Push Email','Email') THEN 'Email'
    WHEN string_field_15 IN ('App Push Source') THEN 'Push'
    WHEN string_field_15 IN ('organic', 'Organic','ORGANIC') THEN 'Organic'
    ELSE 'Other'
    END AS Install_Source
    
FROM `tiki-dwh.appsflyer.uninstalls_20*`

),

ready_data as(
select 
install_time,
Install_Category,
Install_Source,
COALESCE(install_android_id,install_advertising_id) as device_id_android,
COALESCE(install_idfa, install_idfv) as device_id_ios,
COALESCE(uninstall_android_id,uninstall_advertising_id) as uninstall_device_id_android,
COALESCE(uninstall_idfa, uninstall_idfv) as uninstall_device_id_ios,
from cleaning_data),



month_d as(
select
"month" as type,
format_date("%Y%m", date(install_time)) as time,
Install_Category,
Install_Source,
count(distinct device_id_android) as num_install_android,
count(distinct device_id_ios) as num_install_ios,
count(distinct uninstall_device_id_android) as num_uninstall_android,
count(distinct uninstall_device_id_ios) as num_uninstall_ios
from ready_data
group by 1,2,3,4
order by 1,2,3,4),

Week_d as(
select
"Week" as type,
format_date("%Y%V", date(install_time)) as time,
Install_Category,
Install_Source,
count(distinct device_id_android) as num_install_android,
count(distinct device_id_ios) as num_install_ios,
count(distinct uninstall_device_id_android) as num_uninstall_android,
count(distinct uninstall_device_id_ios) as num_uninstall_ios
from ready_data
group by 1,2,3,4
order by 1,2,3,4),

day_d as(
select
"day" as type,
format_date("%Y%m%d", date(install_time)) as time,
Install_Category,
Install_Source,
count(distinct device_id_android) as num_install_android,
count(distinct device_id_ios) as num_install_ios,
count(distinct uninstall_device_id_android) as num_uninstall_android,
count(distinct uninstall_device_id_ios) as num_uninstall_ios
from ready_data
WHERE date(install_time) >= DATE_SUB(CURRENT_DATE('+7'), INTERVAL 30 DAY)
group by 1,2,3,4
order by 1,2,3,4)

select * from month_d
UNION ALL
select * from week_d
UNION ALL
select * from day_d