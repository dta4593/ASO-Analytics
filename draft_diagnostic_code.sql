
SELECT TOP (1000) [segment_code]
      ,[segment_name]
  FROM [ADL].[ASO_VALUE_SEGMENT]
  order by segment_code asc

  insert into [ADL].[ASO_VALUE_SEGMENT]
  values('10','10. 50m to 93.5m')
  ('5','5. 0.5m to 1m'),
  ('6','6. 1m to 2m')

CREATE external table ADL.test
AS
SELECT 1 t1 , 2 t2 , 3 t3
UNION ALL SELECT 4, 5, 6
UNION ALL SELECT 7, 8, 9

select * from ADL.test


CREATE TABLE ADL.DIM_MONTH_DIAGNOSTIC(
year_id int NOT NULL,
year_month_id int NULL,
year_month_dim varchar(50) NULL,
this_month int NULL,
L1M int NULL,
L3M int NULL,
L6M int NULL,
L8M int NULL,
L1Y int NULL,
L2Y int NULL,
L3Y int NULL
)

