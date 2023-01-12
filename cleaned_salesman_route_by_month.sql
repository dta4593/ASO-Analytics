select distinct 
--t2.salesman_code sales_acc, t3.salesman_code sales_ivy, 
t1.*
from [BDH].[SALESMAN_ROUTE_BY_MONTH] t1
left join [BDH].[DAILY_ITINERARY] t2
	on t1.customer_code = t2.outlet_code and t1.salesman_code = t2.salesman_code
left join [BDH].[DISTRIBUTOR_MCP_IVY_DMS] t3
	on t1.customer_code = t3.outlet_code and t1.salesman_code = t3.salesman_code
where 1=1
and trim(t1.salesman_code) <> 'NULL' and t1.salesman_code is not null 
--and (t2.salesman_code is not null or t3.salesman_code is not null)

and t1.customer_code in ('C00601072', 'C00197307')
order by t1.yyyymm, t1.customer_code
------------------------------------------
select distinct 
--t2.salesman_code sales_acc, t3.salesman_code sales_ivy, 
t1.*
from [BDH].[SALESMAN_ROUTE_BY_MONTH] t1
left join [BDH].[DAILY_ITINERARY] t2
	on t1.customer_code = t2.outlet_code and t1.salesman_code = t2.salesman_code
left join [BDH].[DISTRIBUTOR_MCP_IVY_DMS] t3
	on t1.customer_code = t3.outlet_code and t1.salesman_code = t3.salesman_code
where 1=1
and trim(t1.salesman_code) <> 'NULL' and t1.salesman_code is not null and (t2.salesman_code is not null or t3.salesman_code is not null)

and t1.customer_code in ('C00601072', 'C00197307')
order by t1.yyyymm, t1.customer_code
--------------------------------------



select top 100 * from [BDH].[DAILY_ITINERARY] where outlet_code in ('C00601072', 'C00197307')

select top 100 * FROM [BDH].[DISTRIBUTOR_MCP_IVY_DMS] where outlet_code in ('C00601072', 'C00197307')


select 'acc' as type, year_month, count(distinct outlet_code) outlet_qty from [BDH].[DAILY_ITINERARY] group by year_month
union all

select 'ivy' as type, year_month, count(distinct outlet_code) outlet_qty from [BDH].[DISTRIBUTOR_MCP_IVY_DMS] group by year_month