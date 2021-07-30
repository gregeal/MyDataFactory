-- create a config table to show tables that will be load as full load or incremental load

DROP TABLE IF EXISTS dbo.config

CREATE TABLE dbo.config(

[Source] varchar(max) NULL,
[Source_Table] varchar(max) NULL,
[Dest_Table] varchar(max) NOT NULL,
[Columns] varchar(max) NOT NULL,
[Watermark_Column] varchar(max) NULL,
[Watermark_Value] datetime,
[Enabled] int NOT NULL,
[Load_Flag] varchar(max) NULL,
[Status] varchar(max) NULL,
[Comment] varchar(max) NULL

)
-- add all the tables you want to load in your pipeline
insert into dbo.config([Source], [Source_Table], [Dest_Table], [Columns], [Watermark_Column], [Watermark_Value], [Enabled], [Load_Flag] )
values
('FileSystem', 'Product Category File', 'Product_Category_Subcategory.csv', '*', '', '1900-01-01 00:00:00', 1, 'Full')

insert into dbo.config([Source], [Source_Table], [Dest_Table], [Columns], [Watermark_Column], [Watermark_Value], [Enabled], [Load_Flag])
values
('gregvm', 'dbo.customer', 'customer.csv', '*', 'Created_Modified_Date', '1900-01-01 00:00:00', 1, 'Incremental')

insert into dbo.config([Source], [Source_Table], [Dest_Table], [Columns], [Watermark_Column], [Watermark_Value], [Enabled], [Load_Flag] )
values
('gregvm', 'dbo.transactions', 'transactions.csv', '*', 'tran_date', '1900-01-01 00:00:00', 1, 'Incremental')


select * from dbo.config
truncate table dbo.config

--sudo code to understand the logic for your data pipeline design
/*
1. Get tables from config where enabled flag = 1
	select records where source = gregvm, it could be vm or on-prem sources
	For each source table
		if config table Load_flag = 'Incremental'
			get current watermark value from config table
			retrieve all records from source whose date_modified > watermark_value (fetched above)
			Load these incremental records into data lake storage
			retrieve the maximum of date_modified from the file loaded in data lake
			update config table watermark_value with this max date_modified
			update config table status column to Succeed and add any comment to the comment column
		else
			copy the entire data from source to data lake storage
			update config table status column to Succeed and add any comment to the comment column
	end loop

2. select records where source = FileSystem
	Copy the entire data from source to data lake storage
	update config table status column to Succeed and add any comment to the comment column
Task 1 and 2 will run in parallel
*/
SELECT * FROM dbo.config
WHERE enabled = 1