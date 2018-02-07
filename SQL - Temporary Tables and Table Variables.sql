/*////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// TABLE VARIABLES ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/

DECLARE				@tableVariable TABLE	(
						[Id] INT IDENTITY(1,1) PRIMARY KEY CLUSTERED
					,	[Description] VARCHAR(100)
					,	[IsActive] BIT DEFAULT 0
					)


/*////////////////////////////////////////////////////////////////////////////////////
-- Insert into temp table via Values, SELECT or EXEC USP
//////////////////////////////////////////////////////////////////////////////////////
*/

INSERT INTO			@tableVariable ( 
						[Description], 
						[IsActive] )
VALUES				(	''		-- Description - varchar(100)
					,	1		-- IsActive - bit
);

INSERT INTO			@tableVariable ( Description, IsActive )
SELECT				'', -- Description
					1   -- IsActive

--INSERT INTO		@tableVariable ( Description, IsActive )
--EXEC				usp_StoredProcNameSchemaMustMatch



/*////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// Temporary Tables///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/

-- Can be dropped and rebuilt at run time using the below
IF(OBJECT_ID('tempdb..#tempTableName') IS NOT NULL)
	DROP TABLE #tempTableName;


-- Can be created using standard CREATE
CREATE TABLE		#tempTableName ( 
						[Uniqid] INT IDENTITY(1,1) PRIMARY KEY CLUSTERED
					,	[Description] VARCHAR(100)
					,	[IsActive] BIT DEFAULT 0
			);

-- Can be built using an INTO phrase

SELECT				Column1 AS UNIQID,
					Column2 AS Description,
					1		AS IsActive
INTO				#tempTableName
FROM				dbo.MySourceDatabaseTable
