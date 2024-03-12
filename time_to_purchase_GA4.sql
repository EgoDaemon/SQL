WITH common AS (
-- вытаскиваем юзеров по первому касанию и первой покупке
SELECT
user_first_touch_timestamp,
MIN(event_timestamp) event_timestamp,
user_id
FROM
(
    SELECT
    EXTRACT(YEAR FROM CAST((TIMESTAMP_ADD(TIMESTAMP_MICROS(user_first_touch_timestamp), INTERVAL 3 HOUR)) as DATETIME)) year_ft,
    EXTRACT(MONTH FROM CAST((TIMESTAMP_ADD(TIMESTAMP_MICROS(user_first_touch_timestamp), INTERVAL 3 HOUR)) as DATETIME)) month_ft,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S',CAST((TIMESTAMP_ADD(TIMESTAMP_MICROS(user_first_touch_timestamp), INTERVAL 3 HOUR)) as DATETIME)) as user_first_touch_timestamp,
    FORMAT_DATETIME('%Y-%m-%d %H:%M:%S',CAST((TIMESTAMP_ADD(TIMESTAMP_MICROS(event_timestamp), INTERVAL 3 HOUR)) as DATETIME)) as event_timestamp, 
    -- event_name,
    -- traffic_source.source,
    -- user_pseudo_id,
    user_id,
    -- ecommerce.purchase_revenue,
    -- geo.city,
    -- geo.country
    FROM `firebase-flowwow.analytics_150948805.events_*`
    WHERE 1=1 
    AND stream_id="3464829917"
    AND event_name = 'purchase'
    AND user_first_touch_timestamp IS NOT NULL
    AND _TABLE_SUFFIX between '20231201' AND '20240311'
)
WHERE  month_ft = 12 -- те, кто зашел впервые в месяц N
AND year_ft = 2023 -- и год 2024
GROUP BY 1,3
),
-- считаем в периодах часы, дни и месяцы
common2 AS (
SELECT
*,
DATE_DIFF(CAST(event_timestamp as DATETIME), CAST(user_first_touch_timestamp as DATETIME), HOUR) hours,
ROUND((DATE_DIFF(CAST(event_timestamp as DATETIME), CAST(user_first_touch_timestamp as DATETIME), HOUR) / 24),1) as days,
CASE WHEN ROUND((DATE_DIFF(CAST(event_timestamp as DATETIME), CAST(user_first_touch_timestamp as DATETIME), HOUR) / 24),1) > 30 THEN 
ROUND(((DATE_DIFF(CAST(event_timestamp as DATETIME), CAST(user_first_touch_timestamp as DATETIME), HOUR) / 24) / 30),1) ELSE NULL END months
FROM common
),

itog AS (
--ставим флаг для разделения на кластеры: часы, дни, месяцы
SELECT
*,
CASE 
WHEN months IS NOT NULL THEN 'month'
WHEN days >= 1 THEN 'day'
ELSE 'hour'
END as flag
FROM common2
)

SELECT
flag,
CASE 
WHEN flag = 'hour' then AVG(hours) 
WHEN flag = 'day' then AVG(days)
WHEN flag = 'month' then AVG(months)
END avg_means,
COUNT(DISTINCT user_id) users
FROM itog
GROUP by 1