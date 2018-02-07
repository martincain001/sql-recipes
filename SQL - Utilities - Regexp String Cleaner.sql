/*////////////////////////////////////////////////////////////////////////////////////
//////////////////////// Utilities: Regexp / String Cleaner //////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/

CREATE FUNCTION [dbo].[fn_RegexpStringCleaner] ( @Input VARCHAR(64), @patternType VARCHAR(64))
RETURNS VARCHAR(1000)
    BEGIN
        DECLARE @pos INT
        SET @pos = PATINDEX(@patternType, @Input)
        WHILE @pos > 0
            BEGIN
                SET @Input = STUFF(@Input, @pos, 1, '')
                SET @pos = PATINDEX(@patternType, @Input)
            END
        RETURN @Input
    END
GO

-- Example #1: Remove any numerical values
-- SELECT dbo.fn_RegexpStringCleaner('Martin', '%[0-9]%')

-- Example #2: Remove anything that isn't numerical
-- SELECT dbo.fn_RegexpStringCleaner('Martin', '%[^0-9]%')