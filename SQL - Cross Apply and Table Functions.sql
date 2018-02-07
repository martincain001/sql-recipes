/*////////////////////////////////////////////////////////////////////////////////////
//////////////////////// CROSS APPLY and Table Functions /////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/

CREATE FUNCTION [dbo].[fn_TableFunctionSyntax] (@Variable1 VARCHAR(24))
RETURNS  TABLE
AS RETURN
	(	
			SELECT		@@serverName AS ServerName
	)

GO

--		SELECT			1, 
--						fn_TableFunctionSyntax.ServerName
--		FROM			sys.databases
--		CROSS APPLY		dbo.fn_TableFunctionSyntax('') 
--		Provide column or value to call into function / join by


-- Example use case would be a function accepting a postal code and returning nearest 5 neighbouring postal codes
-- Its more efficient than a cursor as its set based, syntax below
-- i.e. 
--			SELECT			TableImInterestedIn.MyPostcodeColumn,
--							fn_NearestPostcode.Distance,
--							fn_NearestPostcode.Postcode
--			FROM			dbo.TableImInterestedIn
--			CROSS APPLY		dbo.fn_NearestPostcode(TableImInterestedIn.MyPostcodeColumn)