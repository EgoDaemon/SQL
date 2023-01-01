select 
first_dt,
year,

SUM(CASE WHEN senior =0 THEN 1 ELSE 0 END) AS New_per_week,
SUM(CASE WHEN senior =1 THEN 1 ELSE 0 END) AS week_1,
SUM(CASE WHEN senior =2 THEN 1 ELSE 0 END) AS week_2,
SUM(CASE WHEN senior =3 THEN 1 ELSE 0 END) AS week_3,
SUM(CASE WHEN senior =4 THEN 1 ELSE 0 END) AS week_4,
SUM(CASE WHEN senior =5 THEN 1 ELSE 0 END) AS week_5,
SUM(CASE WHEN senior =6 THEN 1 ELSE 0 END) AS week_6,
SUM(CASE WHEN senior =7 THEN 1 ELSE 0 END) AS week_7,
SUM(CASE WHEN senior =8 THEN 1 ELSE 0 END) AS week_8,
SUM(CASE WHEN senior =9 THEN 1 ELSE 0 END) AS week_9,
SUM(CASE WHEN senior =10 THEN 1 ELSE 0 END) AS week_10,
SUM(CASE WHEN senior =11 THEN 1 ELSE 0 END) AS week_11,
SUM(CASE WHEN senior =12 THEN 1 ELSE 0 END) AS week_12,
SUM(CASE WHEN senior =13 THEN 1 ELSE 0 END) AS week_13,
SUM(CASE WHEN senior =14 THEN 1 ELSE 0 END) AS week_14,
SUM(CASE WHEN senior =15 THEN 1 ELSE 0 END) AS week_15,
SUM(CASE WHEN senior =16 THEN 1 ELSE 0 END) AS week_16,
SUM(CASE WHEN senior =17 THEN 1 ELSE 0 END) AS week_17,
SUM(CASE WHEN senior =18 THEN 1 ELSE 0 END) AS week_18,
SUM(CASE WHEN senior =19 THEN 1 ELSE 0 END) AS week_19,
SUM(CASE WHEN senior =20 THEN 1 ELSE 0 END) AS week_20,
SUM(CASE WHEN senior =21 THEN 1 ELSE 0 END) AS week_21,
SUM(CASE WHEN senior =22 THEN 1 ELSE 0 END) AS week_22,
SUM(CASE WHEN senior =23 THEN 1 ELSE 0 END) AS week_23,
SUM(CASE WHEN senior =24 THEN 1 ELSE 0 END) AS week_24,
SUM(CASE WHEN senior =25 THEN 1 ELSE 0 END) AS week_25,
SUM(CASE WHEN senior =26 THEN 1 ELSE 0 END) AS week_26,
SUM(CASE WHEN senior =27 THEN 1 ELSE 0 END) AS week_27,
SUM(CASE WHEN senior =28 THEN 1 ELSE 0 END) AS week_28,
SUM(CASE WHEN senior =29 THEN 1 ELSE 0 END) AS week_29,
SUM(CASE WHEN senior =30 THEN 1 ELSE 0 END) AS week_30,
SUM(CASE WHEN senior =31 THEN 1 ELSE 0 END) AS week_31,
SUM(CASE WHEN senior =32 THEN 1 ELSE 0 END) AS week_32,
SUM(CASE WHEN senior =33 THEN 1 ELSE 0 END) AS week_33,
SUM(CASE WHEN senior =34 THEN 1 ELSE 0 END) AS week_34,
SUM(CASE WHEN senior =35 THEN 1 ELSE 0 END) AS week_35,
SUM(CASE WHEN senior =36 THEN 1 ELSE 0 END) AS week_36,
SUM(CASE WHEN senior =37 THEN 1 ELSE 0 END) AS week_37,
SUM(CASE WHEN senior =38 THEN 1 ELSE 0 END) AS week_38,
SUM(CASE WHEN senior =39 THEN 1 ELSE 0 END) AS week_39,
SUM(CASE WHEN senior =40 THEN 1 ELSE 0 END) AS week_40,
SUM(CASE WHEN senior =41 THEN 1 ELSE 0 END) AS week_41,
SUM(CASE WHEN senior =42 THEN 1 ELSE 0 END) AS week_42,
SUM(CASE WHEN senior =43 THEN 1 ELSE 0 END) AS week_43,
SUM(CASE WHEN senior =44 THEN 1 ELSE 0 END) AS week_44,
SUM(CASE WHEN senior =45 THEN 1 ELSE 0 END) AS week_45,
SUM(CASE WHEN senior =46 THEN 1 ELSE 0 END) AS week_46,
SUM(CASE WHEN senior =47 THEN 1 ELSE 0 END) AS week_47,
SUM(CASE WHEN senior =48 THEN 1 ELSE 0 END) AS week_48,
SUM(CASE WHEN senior =49 THEN 1 ELSE 0 END) AS week_49,
SUM(CASE WHEN senior =50 THEN 1 ELSE 0 END) AS week_50,
SUM(CASE WHEN senior =51 THEN 1 ELSE 0 END) AS week_51,
SUM(CASE WHEN senior =52 THEN 1 ELSE 0 END) AS week_52
from  (

SELECT
a.dimension1,
year,
a.iso_week,
b.first_dt as first_dt,
CASE 
WHEN a.iso_week < b.first_dt THEN ((52-b.first_dt) + a.iso_week)
ELSE a.iso_week-b.first_dt END AS senior

FROM
  
(SELECT 
extract(isoweek from CAST(date AS DATETIME)) as iso_week,
dimension1
FROM `m2-main.UA_REPORTS.UA_TRAFIC_FULL` 
where landingpagepath LIKE '%nedvizhimost%' AND CAST(date AS DATETIME) >'2021-08-09' GROUP BY 1,2) a,

(SELECT
extract(isoweek from min(CAST(date AS DATETIME))) AS first_dt,

CASE
WHEN extract(isoweek from min(CAST(date AS DATETIME))) = 52 THEN 2021
ELSE extract(year from min(CAST(date AS DATETIME))) END as year,

dimension1
FROM `m2-main.UA_REPORTS.UA_TRAFIC_FULL` where landingpagepath LIKE '%nedvizhimost%' AND CAST(date AS DATETIME) >'2021-08-09'
GROUP BY 3) b
where a.dimension1=b.dimension1 ORDER BY first_dt

) as with_week_number  group by first_dt, year order by year, first_dt;
