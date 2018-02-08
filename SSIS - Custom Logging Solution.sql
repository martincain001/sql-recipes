/*//////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////// CUSTOM SSIS LOGGING SOLUTION - BASIC / FRAMEWORK ////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
*/

-- Optional: Create a schema for logging and configs
CREATE SCHEMA [config]
GO

-- Create a table to stash the logs in.
CREATE TABLE [config].[tbl_SSIS_CustomLogs] (
				[EntryId] BIGINT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
				[ParentEntryId] BIGINT,
				[PackageName] VARCHAR(255),
				[OperationName] VARCHAR(50),
				[LogTime] DATETIME,
				[Message] VARCHAR(255)
			)
GO


/*//////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/// STORED PROCEDURES TO BE CALLED / EXECUTED IN SSIS FED WITH VARIABLES ///
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
*/

/*//////////////////////////////////////////////////////////////////////////
*/

-- Creates a parent record 
-- Run this in an Execute SQL Task, returns a Parent Id and map to a variable in SSIS
-- This will be used later on when inserting children events

/*//////////////////////////////////////////////////////////////////////////
*/

CREATE PROCEDURE [config].[usp_SSIS_CustomLoggingProcessStart](
				@PackageName VARCHAR(255),
				@OperationName VARCHAR(50),
				@Message VARCHAR(255)
			)
AS
		SET NOCOUNT ON;
		DECLARE			@ParentEntryId BIGINT;
		
		INSERT INTO [config].[tbl_SSIS_CustomLogs] ( 
						ParentEntryId, 
						PackageName, 
						OperationName, 
						LogTime, 
						Message 
			)

		SELECT			CAST(NULL AS BIGINT),
						@PackageName,
						@OperationName,
						GETDATE(),
						@Message;

		SET				@ParentEntryId = SCOPE_IDENTITY();

		UPDATE			[config].[tbl_SSIS_CustomLogs]
		SET				ParentEntryId = @ParentEntryId
		WHERE			EntryId = @ParentEntryId;

		SELECT			@ParentEntryId;
		SET NOCOUNT OFF;
GO

/*//////////////////////////////////////////////////////////////////////////
*/

--Example usage at the header of a package, first component.
--
--EXEC	[config].[usp_SSIS_CustomLoggingProcessStart] 
--			@PackageName = 'My SSIS Package From SSIS Variable', 
--			@OperationName = 'Inserting Data, Copy, Trunc, etc', 
--			@Message = 'Successful load... Inserted X Records, etc.'
--GO
--

/*//////////////////////////////////////////////////////////////////////////
*/

-- Inserts a child record 
-- Run this in an Execute SQL Task, provide ParentEntryId returned from [usp_SSIS_CustomLoggingProcessStart]
-- Should be held as a variable as per the above
-- You can use this Stored Proc quite flexibly, at the start and end or flows, certain events, errors only, etc.
-- Generic "Message" field enables this and you could also compose counts from SSIS for the Insert if passed in as VARCHAR

/*//////////////////////////////////////////////////////////////////////////
*/

CREATE PROCEDURE [config].[usp_SSIS_CustomLoggingProcessInMotion](
				@ParentEntryId BIGINT,
				@PackageName VARCHAR(255),
				@OperationName VARCHAR(50),
				@Message VARCHAR(255)
			)
AS
		SET NOCOUNT ON;
		INSERT INTO [config].[tbl_SSIS_CustomLogs] ( 
						ParentEntryId, 
						PackageName, 
						OperationName, 
						LogTime, 
						Message 
			)

		SELECT			@ParentEntryId,
						@PackageName,
						@OperationName,
						GETDATE(),
						@Message;

		SET NOCOUNT OFF;
GO


/*//////////////////////////////////////////////////////////////////////////
*/

--Example usage at the header of a package, first component.
--
--EXEC config.usp_SSIS_CustomLoggingProcessInMotion 
--		@ParentEntryId	= 1	
--		-- This would be the parent fed back to SSIS from the above stored procedure
--	,	@PackageName	= 'My SSIS Package From SSIS Variable'
--	,	@OperationName	= 'Second Step - Load Staging'
--	,	@Message		= 'Starting Step'			
--
--
--EXEC config.usp_SSIS_CustomLoggingProcessInMotion 
--		@ParentEntryId	= 1	
--	,	@PackageName	= 'My SSIS Package From SSIS Variable'
--	,	@OperationName	= 'Second Step - Load Staging'
--	,	@Message		= 'Finished Step
--

/*//////////////////////////////////////////////////////////////////////////
*/

