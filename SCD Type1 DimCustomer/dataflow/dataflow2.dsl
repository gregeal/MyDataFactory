source(output(
		customer_Id as string,
		DOB as string,
		Gender as string,
		city_code as string,
		Customer_Name as string,
		Created_Modified_Date as string
	),
	allowSchemaDrift: true,
	validateSchema: false,
	ignoreNoFilesFound: false) ~> StagingDataLake
source(output(
		customer_key as integer,
		customer_Id as integer,
		customer_name as string,
		DOB as string,
		city_code as string,
		gender as string
	),
	allowSchemaDrift: true,
	validateSchema: false,
	isolationLevel: 'READ_UNCOMMITTED',
	format: 'table') ~> DimCustomer
StagingDataLake, DimCustomer exists(toInteger(StagingDataLake@customer_Id) == DimCustomer@customer_Id,
	negate:true,
	broadcast: 'auto')~> Exists1
Exists1 derive(customer_Id = toInteger(customer_Id)) ~> DerivedColumn1
StagingDataLake, DimCustomer exists(toInteger(StagingDataLake@customer_Id) == DimCustomer@customer_Id,
	negate:false,
	broadcast: 'auto')~> Exists2
DerivedColumn2 alterRow(updateIf(true())) ~> AlterRow1
Exists2 derive(customer_Id = toInteger(customer_Id)) ~> DerivedColumn2
DerivedColumn1 sink(allowSchemaDrift: true,
	validateSchema: false,
	input(
		customer_key as integer,
		customer_Id as integer,
		customer_name as string,
		DOB as string,
		city_code as string,
		gender as string
	),
	deletable:false,
	insertable:true,
	updateable:false,
	upsertable:false,
	format: 'table',
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true,
	errorHandlingOption: 'stopOnFirstError',
	mapColumn(
		gender = Gender,
		customer_name = Customer_Name,
		DOB,
		city_code,
		customer_Id
	)) ~> sink1
AlterRow1 sink(allowSchemaDrift: true,
	validateSchema: false,
	input(
		customer_key as integer,
		customer_Id as integer,
		customer_name as string,
		DOB as string,
		city_code as string,
		gender as string
	),
	deletable:false,
	insertable:false,
	updateable:true,
	upsertable:false,
	keys:['customer_Id'],
	format: 'table',
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true,
	errorHandlingOption: 'stopOnFirstError',
	mapColumn(
		customer_Id,
		customer_name = Customer_Name,
		DOB,
		city_code,
		gender = Gender
	)) ~> sink2