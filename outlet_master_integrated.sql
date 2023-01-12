SELECT distinct t1.year_month, t1.w_created_by, t1.outlet_master_id, t1.outlet_code outlet_code_current
		, coalesce(t4.outlet_code_acc, t1.outlet_code) outlet_code_original
		, t1.outlet_name, t1.cust_status
		, t1.segmentation, t2.segmentation_name
		, t1.shopper_channel, t3.channel channel_name
		, t1.program_classification, t3.program_classification_name
		, t2.outlet_type_name
		, t1.distributor_code, t1.salesman_code, t1.salesman_name
		, t1.gps_latitude, t1.gps_longitude, t1.detail_address, t1.ward_name, t1.district_name
FROM [ZDTA].[OUTLET_MASTER_INTEGRATED] t1
left join 
	(
	select distinct t1.channel_code, t1.outlet_type_code, outlet_type_name
		, t2.segmentation_code, t2.segmentation_name
	from [BDH].[OUTLET_TYPE] t1
	left join [BDH].[OUTLET_SEGMENTATION] t2
		on t1.outlet_type_code = t2.outlet_type_code
	) t2
	on t1.segmentation = t2.segmentation_code
left join 
	(select distinct program_classification_code, program_classification_name
			, substring(program_classification_name, 1
					, case when charindex('_',program_classification_name)-1 > 0 then charindex('_',program_classification_name)-1 
							when charindex('-',program_classification_name)-1 > 0 then charindex('-',program_classification_name)-1
								else len(program_classification_name) end
									) channel 
	from [BDH].[OUTLET_CLASSIFICATION]
	) t3
	on t1.program_classification = t3.program_classification_code
left join [ADL].[ASO_OUTLET_MAPPING] t4
	on t1.outlet_code = t4.outlet_code_ivy and t1.w_created_by = 'IVY'
where 1=1
--and outlet_name like N'Hương Toàn%'
--and outlet_name = N'Hương Toàn - triều đông - cổ đông - st'