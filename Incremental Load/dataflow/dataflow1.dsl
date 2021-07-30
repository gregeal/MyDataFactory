parameters{
	sourcetable as string,
	watermark_field as string
}
source(allowSchemaDrift: true,
	validateSchema: false,
	ignoreNoFilesFound: false,
	wildcardPaths:[($sourcetable)]) ~> source1
source1 aggregate(max_Created_Modified_Date = iif(toString($sourcetable)=='Customer.csv',
max(toTimestamp(toString(byName($watermark_field)), 'dd-MM-yyyy HH:mm')),
max(toTimestamp(byName($watermark_field), 'dd-MM-yyyy HH:mm')))) ~> Aggregate1
Aggregate1 derive(TableName = $sourcetable) ~> DerivedColumn1
DerivedColumn1 alterRow(updateIf(isNull(max_Created_Modified_Date)==false())) ~> AlterRow1
AlterRow1 sink(allowSchemaDrift: true,
	validateSchema: false,
	input(
		Source as string,
		Source_Table as string,
		Dest_Table as string,
		Columns as string,
		Watermark_Column as string,
		Watermark_Value as timestamp,
		Enabled as integer,
		Load_Flag as string,
		Status as string,
		Comment as string
	),
	deletable:false,
	insertable:false,
	updateable:true,
	upsertable:false,
	keys:[(Dest_Table)],
	skipKeyWrites:true,
	format: 'table',
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true,
	errorHandlingOption: 'stopOnFirstError',
	mapColumn(
		Dest_Table = TableName,
		Watermark_Value = max_Created_Modified_Date
	)) ~> sink1