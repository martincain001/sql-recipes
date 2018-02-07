/*////////////////////////////////////////////////////////////////////////////////////
//////////////////////// Generate Time Table / Dimension /////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/

CREATE PROCEDURE [dbo].[usp_sel_GenerateTimeDimensionTable]	
AS
	BEGIN

		DECLARE			@idStart INT;
		SET				@idStart = 0;
		DECLARE			@idTable TABLE ([Id] INT);

		WHILE(SELECT COUNT(*) FROM @idTable) < 1000
			BEGIN 
				INSERT INTO @idTable ( Id )
				SELECT		@idStart;
				SET			@idStart = @idStart + 1;
			END;


		WITH		cte_Hours
		AS
			(		SELECT	IdTable.Id AS [Hour]
					FROM	@idTable AS IdTable
					WHERE	IdTable.Id BETWEEN 0 AND 23		),

					cte_Minutes
		AS
			(		SELECT	IdTable.Id AS [Minutes]
					FROM	@idTable AS IdTable
					WHERE	IdTable.Id BETWEEN 0 AND 59		),

					cte_Seconds
		AS
			(		SELECT	IdTable.Id AS [Seconds]
					FROM	@idTable AS IdTable
					WHERE	IdTable.Id BETWEEN 0 AND 59		)
			
		SELECT		DATEDIFF(SECOND,
								DATETIMEFROMPARTS(2000,1,1,0, 0, 0, 0),
								DATETIMEFROMPARTS(2000,1,1,cte_Hours.Hour, cte_Minutes.Minutes, cte_Seconds.Seconds, 0)

								)																	AS [TimeKeySecondFormat],
					CAST(
						CONCAT(		RIGHT(CAST(100 + cte_Hours.Hour AS VARCHAR(3)), 2),
									RIGHT(CAST(100 + cte_Minutes.Minutes AS VARCHAR(3)), 2),
									RIGHT(CAST(100 + cte_Seconds.Seconds AS VARCHAR(3)), 2)
							)
						AS INT)																		AS [TimeKeyLogicalFormat],
					TIMEFROMPARTS(cte_Hours.Hour, cte_Minutes.Minutes, cte_Seconds.Seconds, 0, 0)	AS [TimeValue],
					cte_Hours.Hour																	AS [HourOfDay],
					TIMEFROMPARTS(cte_Hours.Hour, 0, 0, 0, 0)										AS [BandedHourOfDayStart],
					TIMEFROMPARTS(cte_Hours.Hour, 59, 59, 0, 0)										AS [BandedHourOfDayEnd],
					cte_Minutes.Minutes																AS [MinuteOfHour],
					TIMEFROMPARTS(cte_Hours.Hour, cte_Minutes.Minutes, 0, 0, 0)						AS [BandedMinuteOfHourStart],
					TIMEFROMPARTS(cte_Hours.Hour, cte_Minutes.Minutes, 59, 0, 0)					AS [BandedMinuteOfHourEnd],
					cte_Seconds.Seconds																AS [SecondOfMinute],
					CASE WHEN cte_Hours.Hour < 12	THEN 'AM' ELSE 'PM' END							AS [TimePeriodOfDay],
					CASE WHEN cte_Hours.Hour < 6	THEN 'P1' 
						 WHEN cte_Hours.Hour < 12	THEN 'P2'
						 WHEN cte_Hours.Hour < 18	THEN 'P3'
						 ELSE 'P4' END																AS [QuarterOfDay],
					CASE WHEN TIMEFROMPARTS(cte_Hours.Hour, cte_Minutes.Minutes, cte_Seconds.Seconds, 0, 0) BETWEEN '09:00:00' AND '17:30:00' THEN 1 
						 ELSE 0 
						 END																		AS [IsWithinBusinessHours]
		FROM		cte_Hours 
		CROSS JOIN	cte_Minutes
		CROSS JOIN	cte_Seconds
		ORDER BY	TIMEFROMPARTS(cte_Hours.Hour, cte_Minutes.Minutes, cte_Seconds.Seconds, 0, 0)
	END
GO