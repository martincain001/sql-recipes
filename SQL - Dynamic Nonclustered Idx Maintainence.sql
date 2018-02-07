/*////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// DYNAMIC INDEX MAINTAINENCE ////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/

CREATE PROCEDURE [dbo].[usp_upd_NonclusteredIndexMaintainence] (
		@schemaName VARCHAR(255),
		@tableName VARCHAR(255),
		@operationId BIT -- 0 Disable, 1 Rebuild
	)
AS
	BEGIN

		SET			@schemaName =	CASE WHEN LEFT(@schemaName,1) = '[' AND RIGHT(@schemaName,1) =']'	THEN @schemaName	ELSE QUOTENAME(@schemaName) END 
		SET			@tableName =	CASE WHEN LEFT(@tableName,1) = '['	AND RIGHT(@tableName,1) =']'	THEN @tableName		ELSE QUOTENAME(@tableName)	END 
		DECLARE		@indexCommand	NVARCHAR(2000)

		DECLARE		cur_DynamicSQLforIndexRebuild CURSOR FAST_FORWARD READ_ONLY 
		FOR 

			SELECT		'ALTER INDEX ' + QUOTENAME(indexes.name) + ' ON ' + QUOTENAME(schemas.name) + '.' + QUOTENAME(tables.name) + ' ' +
						CASE WHEN @operationId = 0 THEN ' DISABLE;' ELSE ' REBUILD;' END 
			FROM		sys.indexes
			JOIN		sys.tables ON tables.object_id = indexes.object_id
			JOIN		sys.schemas ON schemas.schema_id = tables.schema_id
			WHERE		indexes.type_desc = 'NONCLUSTERED'
			AND			QUOTENAME(tables.name)		= @tableName
			AND			QUOTENAME(schemas.name)		= @schemaName
	
		OPEN		cur_DynamicSQLforIndexRebuild

		FETCH NEXT FROM cur_DynamicSQLforIndexRebuild INTO @indexCommand

		WHILE @@FETCH_STATUS = 0
		BEGIN
    
			-- Debugging
			-- PRINT(@indexCommand)

			-- Live / Deploy
			EXEC sp_executesql @indexCommand

			FETCH NEXT FROM cur_DynamicSQLforIndexRebuild INTO @variable
		END

		CLOSE cur_DynamicSQLforIndexRebuild
		DEALLOCATE cur_DynamicSQLforIndexRebuild

	END
GO

