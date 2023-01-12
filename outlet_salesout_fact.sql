
select top 100
t2.year_dim, t2.year_month_id, t2.year_month_dim, t2.this_month, t2.L1M, t2.L3M, t2.L6M, t2.L9M, t2.L1Y, t2.L2Y, t2.L3Y
, t1.region_code, t1.area_code, t1.customer_code, t1.customer_name, t1.distributor_branch_code
, sum(t1.gross_amount)/1.08 monthly_amount
, sum(t1.box_qty) volume_qty
from
	(
	select db.region_code, db.area_code
		, so.transaction_id, so.invoice_no
		, so.distributor_code, so.distributor_name, so.distributor_id
		, so.salesman_code, sp.distributor_branch_code
		, so.customer_code, so.cust_name customer_name
		, so.invoice_key, so.invoice_due_dt, so.so_no
		, so.w_batch_id, so.w_created_dt
		, concat(year(invoice_dt),format(month(invoice_dt), '00')) year_month_id
		, so.invoice_dt, so.so_dt, so.delivery_dt
		, so.material_group_1, so.material_group_2, so.material_group_3    --brand & subrand
		, so.product_code
		, (so.product_qty / psm.product_content) box_qty
		, COALESCE(so.gross_amount,0) gross_amount

	From [ADL].[DAILY_SALES_OUT_TRANSACTION_COMBINATION] so
	left join [ADL].[DIM_PRODUCT_SALES_MASTER] psm
		on so.product_code = psm.product_code
	join [BDH].[CATEGORY] cat
		on psm.cate_id = cat.cat_id
	left join [BDH].[SALES_PERSON] sp
		on so.salesman_code = sp.sales_key
	left join [BDH].[DISTRIBUTOR_BRANCH] db
		on sp.distributor_code = db.distributor_code and sp.distributor_branch_code = db.branch_code
	where 1=1
		and so.invoice_dt BETWEEN '2022-01-01' and '2022-11-30'
		--and so.customer_code = 'C00075005'
		and so.selling_type = 'S' -- selling_type = 'S' if this is "Hàng bán"
		and sp.channel = 'GTDC'  --channel = MT or GTDC / B2B / NUDC... 
		and db.region_code <> '5. MT' --4 regions are North / South East / South / Mekong & 5.MT (means channel MT)
	group by db.region_code,db.area_code, so.transaction_id, so.invoice_no
		, so.distributor_code, so.distributor_name, so.distributor_id, sp.distributor_branch_code
		, so.salesman_code
		, so.customer_code, so.cust_name
		, so.invoice_key, so.invoice_due_dt, so.so_no
		, so.w_batch_id, so.w_created_dt
		, concat(year(invoice_dt),format(month(invoice_dt), '00'))
		, so.invoice_dt, so.so_dt, so.delivery_dt, so.material_group_1, so.material_group_2, so.material_group_3
		, so.product_code
		, so.product_qty, gross_amount,psm.product_content
	) t1
LEFT JOIN [ADL].[ASO_DIM_MONTH_DIAGNOSTIC] t2
	on t1.year_month_id = t2.year_month_id
group by t2.year_dim, t2.year_month_id, t2.year_month_dim, t2.this_month, t2.L1M, t2.L3M, t2.L6M, t2.L9M, t2.L1Y, t2.L2Y, t2.L3Y
, t1.year_month_id, t1.customer_code, t1.customer_name, t1.distributor_branch_code, t1.region_code, t1.area_code
