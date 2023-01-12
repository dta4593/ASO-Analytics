with t1 AS --outlet_salesout_fact
	(
	select 
	t2.year_dim, t2.year_month_id, t2.year_month_dim, t2.this_month, t2.L1M, t2.L3M, t2.L6M, t2.L9M, t2.L1Y, t2.L2Y, t2.L3Y
	, t1.region_code, t1.area_code, t1.customer_code, t1.customer_name, t1.salesman_code, t1.distributor_branch_code
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
			and so.customer_code = 'C00082403'
			and so.selling_type = 'S'
			and sp.channel = 'GTDC'
			and db.region_code <> '5. MT'
		group by db.region_code,db.area_code, so.transaction_id, so.invoice_no
			, so.distributor_code, so.distributor_name, so.distributor_id, sp.distributor_branch_code
			, so.salesman_code
			, so.customer_code, so.cust_name
			, so.invoice_key, so.invoice_due_dt, so.so_no
			, so.w_batch_id, so.w_created_dt
			, concat(year(invoice_dt),format(month(invoice_dt), '00'))
			, so.invoice_dt, so.so_dt, so.delivery_dt, so.material_group_1, so.material_group_2, so.material_group_3
			, so.product_qty, gross_amount,psm.product_content
		) t1
	LEFT JOIN [ADL].[ASO_DIM_MONTH_DIAGNOSTIC] t2
		on t1.year_month_id = t2.year_month_id
	group by t2.year_dim, t2.year_month_id, t2.year_month_dim, t2.this_month, t2.L1M, t2.L3M, t2.L6M, t2.L9M, t2.L1Y, t2.L2Y, t2.L3Y
	, t1.year_month_id, t1.customer_code, t1.customer_name, t1.salesman_code , t1.distributor_branch_code, t1.region_code, t1.area_code
	)
	
, t2 AS --outlet_master_dimension
	(
	select distinct om.outlet_code, om.outlet_name, om.salesman_code, om.salesman_name
		, os.outlet_type_code as customer_type_lvl1_dim , os.segmentation_name as customer_type_lvl2_dim
		, sc.root_channel_code, sc.vn_channel_decs
		, se.se_code, se_name, asm.asm_name, asm.asm_code, rsm.rsm_name , rsm.rsm_code
		, om.gps_latitude, om.gps_longtitude, om.address address_1, om.address2 address_2, om.address3 address_3, om.address4 address_4
		, lh.province_name, lh.area_code, lh.region_code
	from 
		(
		select t1.* 
		from [BDH].[OUTLET_MASTER] t1
		join (select outlet_code, max(w_created_dt) w_created_dt from BDH.Outlet_master group by outlet_code) t2
			on t1.outlet_code = t2.outlet_code and t1.w_created_dt = t2.w_created_dt
		) om
	left join 
		( select distinct outlet_type_code, segmentation_code, segmentation_name,  status
			from [BDH].[OUTLET_SEGMENTATION]
			-- where w_created_dt < '2022-08-01'
		) os
		on om.segmentation = os.segmentation_code
	left join [ADL].[DIM_SALESFORCE_HIERARCHY] sf
		on om.salesman_code = sf.sales_key and sf.w_is_current_flg = 'Y'
	left join [BDH].[SALES_CHANNEL] sc
		on sf.sales_channel_id = sc.sales_channel_id
	left join [BDH].[RSM] rsm 
		on sf.rsm_id = rsm.rsm_id and rsm.w_is_current_flg = 'Y'
	left join [BDH].[ASM] asm 
		on sf.asm_id = asm.asm_id and asm.w_is_current_flg = 'Y'
	left join [BDH].[SUPERVISOR] se
		on sf.supervisor_id = se.supervisor_id and se.w_is_current_flg = 'Y'
	left join [ADL].[DIM_LOCATION_HIERARCHY] lh
		on sf.region_id = lh.region_id and sf.area_id = lh.area_id and sf.province_id = lh.province_id
	where 1=1
	and om.outlet_code = 'C00082403' 
	)
	
	select t2.*, t1.year_dim, t1.year_month_id, t1.year_month_dim
	, t1.distributor_branch_code
	, t1.monthly_amount
	, t1.volume_qty
	from t2
	left join t1
		on t2.outlet_code = t1.customer_code and t2.salesman_code = t1.salesman_code
	