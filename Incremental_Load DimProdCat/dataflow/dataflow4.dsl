source(output(
		prod_cat_code as string,
		prod_cat as string,
		prod_sub_cat_code as string,
		prod_subcat as string
	),
	allowSchemaDrift: true,
	validateSchema: false,
	ignoreNoFilesFound: false) ~> StagingDataLake
source(output(
		Prod_Cat_SubCat_Key as integer,
		Product_Cat_Code as integer,
		Product_Category as string,
		Product_SubCat_Code as integer,
		Product_SubCategory as string
	),
	allowSchemaDrift: true,
	validateSchema: false,
	isolationLevel: 'READ_UNCOMMITTED',
	format: 'table') ~> DimprodCat
StagingDataLake, DimprodCat exists(toInteger(prod_cat_code) == Product_Cat_Code
	&& toInteger(prod_sub_cat_code) == Product_SubCat_Code,
	negate:true,
	broadcast: 'auto')~> Exists1
Exists1 derive(prod_cat_code = toInteger(prod_cat_code),
		prod_sub_cat_code = toInteger(prod_sub_cat_code)) ~> DerivedColumn1
DerivedColumn1 sink(allowSchemaDrift: true,
	validateSchema: false,
	input(
		Prod_Cat_SubCat_Key as integer,
		Product_Cat_Code as integer,
		Product_Category as string,
		Product_SubCat_Code as integer,
		Product_SubCategory as string
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
		Product_Cat_Code = prod_cat_code,
		Product_Category = prod_cat,
		Product_SubCat_Code = prod_sub_cat_code,
		Product_SubCategory = prod_subcat
	)) ~> sink1