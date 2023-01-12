

with sm_by_route as
(select distinct year_month, distributor_code, customer_code, customer_name, salesman_code
from [BDH].[SALESMAN_ROUTE_BY_MONTH] 
where 1=1
and (trim(salesman_code) <> 'NULL' and salesman_code is not null)
and customer_code in ('C00601072', 'C00197307')
)
, ivy as
(
select sm.year_month , i.*
from sm_by_route sm
join zdta.outlet_master_ivy i 
	on i.outlet_code = sm.customer_code  and sm.salesman_code =i.salesman_code
where 1=1
--and i.outlet_code in ('C00197307', 'C00245964')
)
, acc as
(
select sm.year_month, a.*
from zdta.outlet_master_acc a
join sm_by_route sm 
	on a.outlet_code = sm.customer_code and sm.salesman_code =a.salesman_code
where 1=1
--and a.salesman_code = 'SM06650'
)
, union_all as
(
select * from ivy
union all
select * from acc
)

select ua.* , coalesce(so.gross_amount,0) gross_amount
from union_all ua
left join
	(select concat(year(invoice_dt),format(month(invoice_dt), '00')) year_month
		, customer_code, distributor_code, salesman_code, sum(gross_amount) gross_amount 
	from [ADL].[DAILY_SALES_OUT_TRANSACTION_COMBINATION]
	group by concat(year(invoice_dt),format(month(invoice_dt), '00')), customer_code, distributor_code, salesman_code
	) so
	on ua.year_month = so.year_month and ua.outlet_code = so.customer_code and ua.salesman_code = so.salesman_code
order by year_month, w_created_by, outlet_code asc