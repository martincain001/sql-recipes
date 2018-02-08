/*//////////////////////////////////////////////////////////////////////////
//////// USING SEQUENCES TO CREATE UNIQUE VALUES OR GUARANTEE IT ///////////
////////////////////////////////////////////////////////////////////////////
*/

-- Create a new sequence
CREATE SEQUENCE dbo.NewSequenceName AS INT
START WITH 1
INCREMENT BY 1;

--An example of using them for insertion on a row-by-row basis:
DECLARE		@NextID INT;
SET			@NextID = NEXT VALUE FOR dbo.NewSequenceName;
INSERT		dbo.testTable (OrderID, Name, Qty)
VALUES (	@NextID, 'Rim', 2) ;

/*//////////////////////////////////////////////////////////////////////////
/ Fill a table from sequence either with the value or to generate integers /
////////////////////////////////////////////////////////////////////////////
*/

IF(OBJECT_ID('tempdb..#intTable') IS NOT NULL)
	DROP TABLE #intTable;

CREATE TABLE #intTable (	
				[Id] INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
				[SequenceId] INT	
			);

WHILE(SELECT ISNULL(MAX(Id),0) FROM #intTable) < 1000
	INSERT INTO #intTable ( SequenceId )
	SELECT NEXT VALUE FOR NewSequenceName

GO

--SELECT * FROM #intTable