
select distinct om.outlet_code, om.salesman_code, om.salesman_name
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
