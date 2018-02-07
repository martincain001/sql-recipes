/*////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
///////////// USING DATA TABLES TO DRIVE ETL AND SSIS CONNECTION MANAGERS ////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/


/*////////////////////////////////////////////////////////////////////////////////////
CREATE TABLE WITHIN ETL, CENTRALISED OR STAGING DATABASE TO CONTAIN ALL VARIABLE VALUES
//////////////////////////////////////////////////////////////////////////////////////
*/


CREATE TABLE [dbo].[tbl_EnvironmentVariables]	(
				[ID]				INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
				[variable_name]		VARCHAR(255)	NOT NULL,
				[sensitive]			BIT				NOT NULL,
				[description]		VARCHAR(255)	NULL,
				[environment_name]	VARCHAR(255)	NOT NULL,
				[folder_name]		VARCHAR(255)	NOT NULL,
				[value]				SQL_VARIANT		NOT NULL,
				[datatype]			VARCHAR(255)	NOT NULL
			) 
GO


/*////////////////////////////////////////////////////////////////////////////////////
SCRIPT SYNONYMS TO THE SSISDB IN THE EVENT THAT THIS IS REMOTE TO THE ETL OR CENTRAL DB
//////////////////////////////////////////////////////////////////////////////////////
*/

CREATE SYNONYM		[dbo].[syn_SSISDB_catalog_create_environment_variable]		FOR [SSISDB].[catalog].[create_environment_variable]
GO

CREATE SYNONYM		[dbo].[syn_SSISDB_catalog_environment_variables]			FOR [SSISDB].[catalog].[environment_variables]
GO

CREATE SYNONYM		[dbo].[syn_SSISDB_catalog_environments]						FOR [SSISDB].[catalog].[environments]
GO

CREATE SYNONYM		[dbo].[syn_SSISDB_catalog_folders]							FOR [SSISDB].[catalog].[folders]
GO

CREATE SYNONYM		[dbo].[syn_SSISDB_internal_environment_variables]			FOR [SSISDB].[internal].[environment_variables]
GO

/*////////////////////////////////////////////////////////////////////////////////////
CREATE A STORED PROCEDURE TO ANALYSE THE DATA, CREATE NEW VARIABLES OR UPDATE EXISTING
//////////////////////////////////////////////////////////////////////////////////////
*/

CREATE PROCEDURE [dbo].[usp_upd_SSISDB_EnvironmentVariables] 
AS
		SET NOCOUNT ON;

		DECLARE			@variable_name		NVARCHAR(255), 
						@sensitive			BIT,
						@description		NVARCHAR(255),
						@environment_name	NVARCHAR(255),
						@folder_name		NVARCHAR(255),
						@value				SQL_VARIANT,
						@datatype			NVARCHAR(255);

		DECLARE create_variables_cursor CURSOR FAST_FORWARD READ_ONLY FOR 

				SELECT			CAST(variable_name		AS NVARCHAR(255))	AS variable_name, 
								CAST(sensitive			AS BIT)				AS sensitive,
								CAST(description		AS NVARCHAR(255))	AS description,
								CAST(environment_name	AS NVARCHAR(255))	AS environment_name,
								CAST(folder_name		AS NVARCHAR(255))	AS folder_name,
								CAST(value				AS SQL_VARIANT)		AS value,
								CAST(datatype			AS NVARCHAR(255))	AS datatype
				FROM			dbo.tbl_EnvironmentVariables
				ORDER BY		variable_name;

		OPEN create_variables_cursor

		FETCH NEXT FROM create_variables_cursor INTO @variable_name, @sensitive, @description, @environment_name, @folder_name, @value,	@datatype			

			WHILE @@fetch_Status = 0
				BEGIN
    
					DECLARE		@ExistsInCatalog BIT;
					DECLARE		@UpdateCheck BIT;

					SELECT		@ExistsInCatalog = ISNULL(COUNT(*), 0)
					FROM		[dbo].[syn_SSISDB_catalog_environment_variables] AS environment_variables
					JOIN		[dbo].[syn_SSISDB_catalog_environments] AS environments ON environments.environment_id = environment_variables.environment_id
					JOIN		[dbo].[syn_SSISDB_catalog_folders] AS folders ON folders.folder_id = environments.folder_id
					WHERE		environment_variables.name	= @variable_name
					AND			environment_variables.value	= @value
					AND			environment_variables.TYPE	= @datatype
					AND			environments.NAME			= @environment_name
					AND			folders.NAME				= @folder_name;

					SELECT		@UpdateCheck = ISNULL(COUNT(*), 0)
					FROM		[dbo].[syn_SSISDB_catalog_environment_variables] AS environment_variables
					JOIN		[dbo].[syn_SSISDB_catalog_environments] AS environments  ON environments.environment_id = environment_variables.environment_id
					JOIN		[dbo].[syn_SSISDB_catalog_folders] AS folders ON folders.folder_id = environments.folder_id
					WHERE		environment_variables.name	= @variable_name
					AND			environment_variables.value	!= @value
					AND			environment_variables.TYPE	= @datatype
					AND			environments.NAME			= @environment_name
					AND			folders.NAME				= @folder_name;
	
					IF(@ExistsInCatalog < 1 AND @UpdateCheck = 0)
						BEGIN
					
							DECLARE			@SensitiveAsBoolean VARCHAR(5);
							SET				@SensitiveAsBoolean = CASE WHEN @sensitive = 1 THEN 'True' ELSE 'False' END;

							IF(@datatype = 'String')
								BEGIN

									DECLARE		@NvarcharMagicVariable NVARCHAR(255); --New change
									SELECT		@NvarcharMagicVariable = CAST(@value AS NVARCHAR(255)); -- New Change

									EXEC	[dbo].[syn_SSISDB_catalog_create_environment_variable]
											   @variable_name		=		@variable_name, 
											   @sensitive			=		@SensitiveAsBoolean, 
											   @description			=		@description, 
											   @environment_name	=		@environment_name, 
											   @folder_name			=		@folder_name, 
											   @value				=		@NvarcharMagicVariable, -- This is the new variable
											   @data_type			=		@datatype;

									PRINT('Created: "' + @variable_name + '" in the "' + @environment_name + ' > ' + @folder_name + '" SSISDB environment variable folders')
								END

							IF(@datatype LIKE '%Int%')
								BEGIN

									DECLARE		@IntValue INT;
									SET			@IntValue = (SELECT CAST(@value AS INT));

									EXEC	[dbo].[syn_SSISDB_catalog_create_environment_variable]
											   @variable_name		=		@variable_name, 
											   @sensitive			=		@SensitiveAsBoolean, 
											   @description			=		@description, 
											   @environment_name	=		@environment_name, 
											   @folder_name			=		@folder_name, 
											   @value				=		@IntValue, 
											   @data_type			=		@datatype;

									PRINT('Created: "' + @variable_name + '" in the "' + @environment_name + ' > ' + @folder_name + '" SSISDB environment variable folders')
								END

							IF(@datatype LIKE '%Bool%')
								BEGIN

									DECLARE		@BitValue INT;
									SET			@BitValue = (SELECT CAST(@value AS BIT));

									EXEC	[dbo].[syn_SSISDB_catalog_create_environment_variable]
											   @variable_name		=		@variable_name, 
											   @sensitive			=		@SensitiveAsBoolean, 
											   @description			=		@description, 
											   @environment_name	=		@environment_name, 
											   @folder_name			=		@folder_name, 
											   @value				=		@BitValue, 
											   @data_type			=		@datatype;

									PRINT('Created: "' + @variable_name + '" in the "' + @environment_name + ' > ' + @folder_name + '" SSISDB environment variable folders')
								END


						END

					IF(@UpdateCheck = 1)
						BEGIN

							UPDATE		[dbo].[syn_SSISDB_internal_environment_variables]
							SET			[syn_SSISDB_internal_environment_variables].Value		=	@value
							FROM		[dbo].[syn_SSISDB_internal_environment_variables] AS environment_variables 
							JOIN		[dbo].[syn_SSISDB_catalog_environments] AS environments ON environments.environment_id = environment_variables.environment_id 
							JOIN		[dbo].[syn_SSISDB_catalog_folders] AS folders ON folders.folder_id = environments.folder_id
							WHERE		environment_variables.name		=	@variable_name
							AND			environment_variables.type		=	@datatype
							AND			environments.Name				=	@environment_name
							AND			folders.Name					=	@folder_name;

							PRINT('Updated: "' + @variable_name + '" in the "' + @environment_name + ' > ' + @folder_name + '" SSISDB environment variable folders... Value is now: ' + CAST(@value AS VARCHAR(255)));
						END 

					ELSE
				
						PRINT('No change: "' + @variable_name + '" already exists in the "' + @environment_name + '" environment as "' + CAST(@value AS VARCHAR(255)) + '"')

					FETCH NEXT FROM create_variables_cursor INTO @variable_name, @sensitive, @description, @environment_name, @folder_name, @value,	@datatype		
				END

			CLOSE	create_variables_cursor
		DEALLOCATE	create_variables_cursor


GO