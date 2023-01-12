with outlet_acc as
	(
	select distinct 'ACC' as w_created_by
		, t1.outlet_master_id, t1.outlet_code, t1.outlet_name, t1.cust_status
		, t1.segmentation, t1.shopper_channel, t1.program_classification 
		, t1.distributor_code, t1.salesman_code, t1.salesman_name
		, t1.gps_latitude, t1.gps_longtitude, t1.address detail_address
		, trim(replace((case when gps_latitude is null then t1.address3 else t1.address4 end), '(old)','')) as ward_name
		, trim(replace((case when gps_latitude is null then t1.address4 else t1.address5 end), '(old)','')) as district_name
		
	from [BDH].[OUTLET_MASTER] t1
	join (select outlet_code, max(w_created_dt) w_created_dt from BDH.Outlet_master group by outlet_code) t2
		on t1.outlet_code = t2.outlet_code and t1.w_created_dt = t2.w_created_dt
	)

, outlet_ivy AS
	(
	select distinct 'IVY' as w_created_by
		, t1.retailer_ivy_id as outlet_master_id, t1.customer_code as outlet_code, t1.customer_name as outlet_name, t1.customer_status as cust_status
		, t1.program_classification as segmentation, t1.shopper_channel, t1.segmentation as program_classification
		, t1.distributor_code, t1.salesman_code, right(t1.salesman_name, len(t1.salesman_name) - charindex('-', t1.salesman_name) - 1) salesman_name
		, coalesce(t1.gps_latitude, t3.gps_latitude) gps_latitude, coalesce(t1.gps_longitude, t3.gps_longtitude) gps_longitude
		, coalesce(t1.address_1, t3.detail_address) detail_address , coalesce(t1.address_2, t3.ward_name) ward_name, coalesce(t1.address_3, t3.district_name) district_name
		
	from [BDH].[RETAILER_MASTER_IVY_DMS] t1
	left join [ADL].[ASO_OUTLET_MAPPING] t2
		on t1.customer_code = t2.outlet_code_ivy
	left join outlet_acc
		 t3
		on t2.outlet_code_acc = t3.outlet_code 
		--and t1.gps_latitude = t3.gps_latitude and t1.gps_longitude = t3.gps_longtitude
	where t1.w_is_current_flg = 'Y'
	--and t1.customer_code = 'C00023935'
	--and coalesce(t1.address_2, t3.ward_name) is not null
	)
, master AS
	(select * from outlet_acc
	union all
	select * from outlet_ivy
	)


select distinct t2.outlet_type_name, t2.segmentation_name, t3.program_classification_name
	, t1.* 
from MASTER t1
left join 
	(
	select distinct t1.channel_code, t1.outlet_type_code, outlet_type_name
	, t2.segmentation_code, t2.segmentation_name
	from [BDH].[OUTLET_TYPE] t1
	left join [BDH].[OUTLET_SEGMENTATION] t2
		on t1.outlet_type_code = t2.outlet_type_code
	) t2
	on t1.segmentation = t2.segmentation_code
left join [BDH].[OUTLET_CLASSIFICATION] t3
	on t1.program_classification = t3.program_classification_code
where t1.outlet_code = 'C00000005'