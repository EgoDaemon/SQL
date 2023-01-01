select
t1.id,
t1.department,
t1.first_name,
max_s.gross_salary
from windows_functions.salary as t1
join
	(select department,
	max(gross_salary) as gross_salary 
	from windows_functions.salary group by 1) as max_s
using(department, gross_salary);


select
t1.id,
t1.department,
t1.first_name,
max(t1.gross_salary) over (partition by t1.department) as max_salary
from windows_functions.salary as t1;

select 
max_s.id,
max_s.department,
max_s.first_name,
max_s.max_salary
from
(
	select
	id,
	department,
	first_name,
	gross_salary,
	max(gross_salary) over (partition by department) as max_salary
	from windows_functions.salary
) as max_s
where max_s.max_salary = max_s.gross_salary
order by 4 desc;

with gross_sum_by_dep as (
	select 
	department,
	sum(gross_salary) as dep_sum
	from windows_functions.salary
	group by 1)
select
	id,
	department,
	first_name,
	gross_salary,
	round(gross_salary * 1.0 / dep_sum, 3)*100 as concl,
	round(gross_salary * 1.0 / (select sum(gross_salary)  from windows_functions.salary), 3)*100 as total
from windows_functions.salary
join gross_sum_by_dep
using (department);


-- OR  WITH over 

select
	id,
	department,
	first_name,
	gross_salary,
	round(gross_salary * 1.0 / sum(gross_salary) over(partition by department), 3)*100 as of_dep,
	round(gross_salary * 1.0 / sum(gross_salary) over(), 3)*100 as of_company
from windows_functions.salary
order by 6 desc;

-- ����� ������� �� -  LAST_VALUE, � ������ FIRST_VALUE
select
	id,
	department,
	gross_salary,
	first_name,
	FIRST_VALUE(first_name) 
    OVER(
	PARTITION BY department
        ORDER BY gross_salary
        RANGE BETWEEN 
            UNBOUNDED PRECEDING AND 
            UNBOUNDED FOLLOWING
    )  as name_result
from windows_functions.salary;

select
	id,
	department,
	gross_salary,
	first_name,
	LAST_VALUE(first_name) 
    OVER(
	PARTITION BY department
        ORDER BY gross_salary
        RANGE BETWEEN 
            UNBOUNDED PRECEDING AND 
            UNBOUNDED FOLLOWING
    )  as name_result
from windows_functions.salary;

---������������ ����� (����������� ����) � ����������� �������

select
month,
change_in_followers,
sum(change_in_followers) over(order by month asc) as summ_itog,
round(avg(change_in_followers) over(order by month asc), 2) as avg_itog
from windows_functions.social_media
where username = 'instagram';

select
month,
username,
change_in_followers,
sum(change_in_followers) over(partition by username order by month asc) as summ_itog,
round(avg(change_in_followers) over(partition by username order by month asc), 2) as avg_itog
from windows_functions.social_media;

select
username,
posts,
month,
FIRST_VALUE(posts) 
    OVER(
	PARTITION BY username
        ORDER BY posts -- ���� ���� �� �������� � ������� ������ (FIRST), � ������ ����������� ������
        RANGE BETWEEN 
            UNBOUNDED PRECEDING AND 
            UNBOUNDED FOLLOWING
    )
from windows_functions.social_media;

select
username,
posts,
month,
LAST_VALUE(posts) 
    OVER(
	PARTITION BY username
        ORDER BY posts -- ���� ���� �� �������� � ������� ��������� (LAST), � ������ ������������ ������
        RANGE BETWEEN 
            UNBOUNDED PRECEDING AND 
            UNBOUNDED FOLLOWING
    )
from windows_functions.social_media;

-- LEAD & LAG - ����� ������� ����� ����.������� � �����������

select artist, week, streams_millions,
LAG(streams_millions, 1, 0.0) over (order by week ASC)  as prev_week_result 
-- �������� ����.���������� ������ � ����� 1 ||  (streams_millions, 1, 0) -  - ��� ���, 0.0 - ��� ������ ������ NULL (�������� ������ 0, ������� ��� �� NULL)
-- 0.0 ������ ��� �������� ������ float
from windows_functions.streams

select artist, week, streams_millions,
LAG(streams_millions, 2, 0.0) over (order by week ASC)  as prev_2_week_result 
-- ��� 2
from windows_functions.streams
where artist = 'Lady Gaga';

select artist, week, streams_millions,
LAG(streams_millions::text, 2, '��� ��������') over (order by week ASC)  as prev_2_week_result 
-- �����
from windows_functions.streams
where artist = 'Lady Gaga';

--�������� ��������� ������� ����.������ � ������� ������
select artist, week, streams_millions,
streams_millions - LAG(streams_millions, 1, 0.0) over (order by week ASC)  as dynamic_over_week 
from windows_functions.streams;

--�������� ��������� ������� ����.������ � ������� ������� 
select artist, week, streams_millions,
streams_millions - LAG(streams_millions, 1, streams_millions) over (partition by artist order by week ASC)  as raiting,
chart_position,
LAG(chart_position, 1, chart_position) over (partition by artist order by week ASC) - chart_position  as chart_pos_change
from windows_functions.streams;

--LEAD
select artist, week, streams_millions,
streams_millions - LEAD(streams_millions, 1, streams_millions) over (partition by artist order by week ASC)  as Next_week_raiting,
chart_position,
LEAD(chart_position, 1, chart_position) over (partition by artist order by week ASC) - chart_position  as Next_week_chart_pos_change
from windows_functions.streams;


--ROW_NUMBER

select artist, week, streams_millions,
row_number () over (order by streams_millions asc) as row_num
from windows_functions.streams;

--������� ������� �� ����.������� (���� ������) = 30 �������, ��������

with gigi as
(select artist, week, streams_millions,
row_number () over (order by streams_millions asc) as row_num
from windows_functions.streams)
select * from gigi where row_num = 30;

-- RANK -- ����� ���������� ��������� streams_millions �������������� ���������� ����/ RANK ���������� ��������, ����� ���� ���������� ��������
-- DENSE_RANK ����� �������� �� ������

select artist, week, streams_millions,
RANK () over (order by streams_millions asc) as rank_result
from windows_functions.streams;

-- �������� ��� ������  ��� � ���� ����������� � ������� ���� ������� ������
with minim as (select department, first_name, gross_salary,
RANK() over (partition by department order by gross_salary) as min_salary
from windows_functions.salary)
select * from minim where min_salary = 1;

with maxim as (select department, first_name, gross_salary,
RANK() over (partition by department order by gross_salary DESC) as max_salary
from windows_functions.salary)
select * from maxim where max_salary = 1;

select artist, week, streams_millions,
dense_rank () over (order by streams_millions asc) as dense_rank_result
from windows_functions.streams;

--�� ���� ������ partition by week , ������ ��� �������� ������� ��� �� ������ ������ (���������� �� ������ ������). ����� ������� �� �����_��� � ��������
-- ���������� � ������ ������
select artist, week, streams_millions,
dense_rank () over (partition by week order by streams_millions asc) as rank_result,
dense_rank () over (partition by week order by streams_millions asc) as dense_rank_result
from windows_functions.streams;

-- NTILE
-- �� ����������� streams_millions �� ������� � ������� �� 4 ������. ��������
select artist, week, streams_millions,
ntile (4) over (order by streams_millions DESC) as ntile_res
from windows_functions.streams;

--� partition by week �� �������� ������ �� ������ ������ � ������ ��� ������ ������ �������� �� 2 ������, ��������
select artist, week, streams_millions,
ntile (5) over (partition by week order by streams_millions DESC) as ntile_res
from windows_functions.streams;



