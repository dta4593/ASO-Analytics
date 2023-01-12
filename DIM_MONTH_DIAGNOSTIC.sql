declare @todate datetime = getdate()
declare @yyyy int = year(@todate)
declare @eom datetime = EOMONTH(GETDATE())

INSERT ADL.DIM_MONTH_DIAGNOSTIC

select distinct d.year year_dim, 
[year_month] year_month_id
, concat(year(date),'-',format(month(date), '00')) year_month_dim
, case when month(date) = month(GETDATE()) and year(date) = year(GETDATE()) then 1 else 0 end as 'this_month'
, case when date between DATEADD(day,1,dateadd(month, -2, @eom)) and dateadd(month, -1, @eom) then 1 else 0 end as 'L1M'
, case when date between DATEADD(day,1,dateadd(month, -4, @eom)) and dateadd(month, -1, @eom) then 1 else 0 end as 'L3M'
, case when date between DATEADD(day,1,dateadd(month, -7, @eom)) and dateadd(month, -1, @eom) then 1 else 0 end as 'L6M'
, case when date between DATEADD(day,1,dateadd(month, -10, @eom)) and dateadd(month, -1, @eom) then 1 else 0 end as 'L9M'
, case when date between DATEADD(day,1,dateadd(month, -13, @eom)) and dateadd(month, -1, @eom) then 1 else 0 end as 'L1Y'
, case when date between DATEADD(day,1,dateadd(month, -25, @eom)) and dateadd(month, -1, @eom) then 1 else 0 end as 'L2Y'
, case when date between DATEADD(day,1,dateadd(month, -37, @eom)) and dateadd(month, -1, @eom) then 1 else 0 end as 'L3Y'
from [ADL].[DIM_DATE] d
where d.date BETWEEN '2021-01-01' and @todate
group by [year], [year_month], date
--order by year_month desc

--SELECT * FROM ADL.DIM_MONTH_DIAGNOSTIC