/*//////////////////////////////////////////////////////////////////////////
////////// INCREMENTAL WITHOUT CDC OR DATE - USING HASHBYTES ///////////////
////////////////////////////////////////////////////////////////////////////
*/

-- Spot changes between two tables (i.e. newly loaded staging and the current live)
-- Useful when there isn't a solid update key or change data capture
-- Can minimise impact and load times

/*//////////////////////////////////////////////////////////////////////////
////////////////////// CREATE VIEWS ON BOTH TABLES /////////////////////////
////////////////////////////////////////////////////////////////////////////
*/

-- Live Table
CREATE VIEW	[dim].[vw_Example_RowHash]
AS

	SELECT		BusinessKey,
				HASHBYTES('SHA1',			
					--	CONCAT(		
							--	Use CAST/CONVERT within a CONCAT to capture all moving data fields (all attributes excpet PK / Business Key typically)

							Description 

							-- Or Single value if a pair (i.e. Business Key, Descrpition ONLY) 
							-- Typically when 3NF tables

						-- ) 
					) AS RowHash
	FROM		dim.Example
GO


-- Stage Table
CREATE VIEW [staging].[vw_Example_RowHash]
AS

	SELECT		BusinessKey,
				HASHBYTES('SHA1',			
					--	CONCAT(		
							--	Use CAST/CONVERT within a CONCAT to capture all moving data fields (all attributes excpet PK / Business Key typically)

							Description 

							-- Or Single value if a pair (i.e. Business Key, Descrpition ONLY) 
							-- Typically when 3NF tables

						-- ) 
					) AS RowHash
	FROM		staging.Example
GO

/*//////////////////////////////////////////////////////////////////////////
//////////////// COMPARE VIEWS AND CREATE LISTS TO PROCESS /////////////////
////////////////////////////////////////////////////////////////////////////
*/

-- Identify New Records (Now in staging, Not In Live)
SELECT		staging.BusinessKey
FROM		staging.vw_Example_RowHash AS Staging
LEFT JOIN	dim.vw_Example_RowHash AS Live ON vw_Example_RowHash.BusinessKey = vw_Example_RowHash.BusinessKey
WHERE		Live.BusinessKey IS NULL


-- Identify Updated Records (In both Staging and Live, however, the row values differ and hash is different)
SELECT		staging.BusinessKey
FROM		staging.vw_Example_RowHash AS Staging
LEFT JOIN	dim.vw_Example_RowHash AS Live ON vw_Example_RowHash.BusinessKey = vw_Example_RowHash.BusinessKey
WHERE		Live.RowHash != Staging.RowHash


-- Identify Deleted Records (In Live, Not in Staging)
SELECT		Live.BusinessKey 
FROM		dim.vw_Example_RowHash AS Live

	EXCEPT

SELECT		Staging.BusinessKey 
FROM		Staging.vw_Example_RowHash AS Staging


/*//////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
*/
