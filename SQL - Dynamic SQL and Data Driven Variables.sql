/*////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/////////////// USING DMVs TO BUILD DYNAMIC SQL OR FOR ETL VARIABLES /////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/

-- ALL DATABASES ON THE INSTANCE
USE SelectedDatabaseName
GO

SELECT		QUOTENAME(db.name) AS DatabaseName
FROM		sys.databases AS db
WHERE		(		(	db.name LIKE '%%'	)
				OR	(	db.name = ''		)	)


-- ALL SCHEMAS WITHIN THE INITIAL CATALOG
SELECT		QUOTENAME(sch.name) AS SchemaName
FROM		sys.schemas AS sch
WHERE		(		(	sch.name LIKE '%%'	)
				OR	(	sch.name = ''		)	)



/*//////////////////////////////////////////////////////////////////////////////////////
///////////////////////// GENERIC FF CURSOR STATEMENTS//////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
*/

DECLARE				@variable INT

DECLARE				cursor_name		CURSOR FAST_FORWARD READ_ONLY 
FOR		
		select_statement

OPEN				cursor_name

FETCH NEXT FROM		cursor_name		INTO		@variable

WHILE @@FETCH_STATUS = 0
BEGIN
    

    FETCH NEXT FROM cursor_name INTO @variable
END

CLOSE cursor_name
DEALLOCATE cursor_name



/*//////////////////////////////////////////////////////////////////////////////////////
///////////////////////// EXAMPLE FF CURSOR STATEMENTS//////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
*/


/* USE CASE & SCENARIO: OUTPUT TABLE NAME AND COUNTS FROM ALL TABLES IN THE SCHEMA    */

DECLARE				@schemaName VARCHAR(100),
					@tableName	VARCHAR(100)

DECLARE				cur_TableCountsInSchema CURSOR FAST_FORWARD READ_ONLY 
FOR 

		SELECT		QUOTENAME(schemas.name) AS SchemaName,
					QUOTENAME(tables.name) AS TableName
		FROM		sys.tables 
		JOIN		sys.schemas ON schemas.schema_id = tables.schema_id

OPEN cur_TableCountsInSchema

FETCH NEXT FROM cur_TableCountsInSchema INTO @schemaName, @tableName

WHILE @@FETCH_STATUS = 0
BEGIN
    
	DECLARE			@DYNAMICSQL NVARCHAR(2000);
	SET				@DYNAMICSQL = '	select '	+	'''' + CONCAT(@schemaName, '.', @tableName) + '''' + ' as Schema_Table_Name,  
												COUNT(*) as RowsInTable
									from '		+ CONCAT(@schemaName, '.', @tableName)

	--Print to be used in debugging
	--PRINT			@DYNAMICSQL

	--Exec to be used in execution and deployment
	EXEC sp_executesql @DYNAMICSQL

    FETCH NEXT FROM cur_TableCountsInSchema INTO @schemaName, @tableName
END

CLOSE cur_TableCountsInSchema
DEALLOCATE cur_TableCountsInSchema
