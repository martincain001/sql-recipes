/*////////////////////////////////////////////////////////////////////////////////////
//////////////////////// Generate Date Table / Dimension /////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/


CREATE PROCEDURE [dbo].[usp_sel_GenerateDateDimensionTable]	(
			@YearStart INT,
			@YearEnd INT
		)
AS
	
	BEGIN

		IF(OBJECT_ID('tempdb..#YearRangeTable') IS NOT NULL)
			DROP TABLE #YearRangeTable;

		IF(OBJECT_ID('tempdb..#smallIntTable') IS NOT NULL)
			DROP TABLE #smallIntTable;

		CREATE TABLE	#YearRangeTable ([Year] INT PRIMARY KEY CLUSTERED);
		CREATE TABLE	#smallIntTable ([Id] INT PRIMARY KEY CLUSTERED);
		DECLARE			@daysInCalMonth TABLE ( MonthNumber INT, DaysInMonth INT);
		DECLARE			@idStart INT = 1

			WHILE(SELECT ISNULL(MAX([Year]), 0) FROM #YearRangeTable) < @YearEnd
				BEGIN
					INSERT INTO #YearRangeTable ( [Year] )
					VALUES ( @YearStart );

					SET		@YearStart = @YearStart + 1

				END

			WHILE(SELECT COUNT(*) FROM #smallIntTable) < 31
				BEGIN
					INSERT INTO #smallIntTable ( Id )
					VALUES ( @idStart );

					SET		@idStart = @idStart + 1

				END

		INSERT INTO		@daysInCalMonth ( MonthNumber, DaysInMonth )

				SELECT		1, 31	UNION
				SELECT		2, 28	UNION
				SELECT		3, 31	UNION
				SELECT		4, 30	UNION
				SELECT		5, 31	UNION
				SELECT		6, 30	UNION
				SELECT		7, 31	UNION
				SELECT		8, 31	UNION
				SELECT		9, 30	UNION
				SELECT		10, 31	UNION
				SELECT		11, 30	UNION
				SELECT		12, 31	;



		SELECT		CAST(
						CONCAT(		CAST([Year] AS VARCHAR(4)),
									CAST(RIGHT(CAST((100 + MonthNumber) AS VARCHAR(3)), 2) AS VARCHAR(2)),
									CAST(RIGHT(CAST((100 + Id) AS VARCHAR(3)), 2) AS VARCHAR(2))
						) AS INT)																				AS DateKey,
					DATEFROMPARTS(Year, MonthNumber, Id)														AS CalendarDate,
					DATETIMEFROMPARTS(Year, MonthNumber, Id,0,0,0,0)											AS CalendarDateTimeStart,
					DATETIMEFROMPARTS(Year, MonthNumber, Id, 23,59,59,998)										AS CalendarDateTimeEnd,
					Year																						AS CalendarYear,
					CAST(
						CONCAT(			'Q', 
									CAST(DATEPART(QUARTER, DATEFROMPARTS(Year, MonthNumber, Id)) AS VARCHAR(1))			
						) AS VARCHAR(2))																		AS CalendarQuarterName, 
					DATEPART(QUARTER, DATEFROMPARTS(Year, MonthNumber, Id))										AS CalendarQuarterNumber,
					DATENAME(MONTH, DATETIMEFROMPARTS(Year, MonthNumber, Id, 0, 0, 0, 0))						AS CalendarMonthName,
					MonthNumber																					AS CalendarMonthNumber,
					DATENAME(WEEKDAY, DATETIMEFROMPARTS(Year, MonthNumber, Id, 0, 0, 0, 0))						AS DayNameOfWeek,
					Id																							AS DayNumberOfMonth,
					CASE	WHEN DATENAME(WEEKDAY, DATETIMEFROMPARTS(Year, MonthNumber, Id, 0, 0, 0, 0)) IN ('Saturday', 'Sunday') THEN 1 
							ELSE 0 
							END																					AS IsWeekend,
					CASE	WHEN DATENAME(WEEKDAY, DATETIMEFROMPARTS(Year, MonthNumber, Id, 0, 0, 0, 0)) IN ('Saturday', 'Sunday') THEN 0 
							ELSE 1 
							END																					AS IsWeekday,
					CASE	WHEN DATENAME(WEEKDAY, DATETIMEFROMPARTS(Year, MonthNumber, Id, 0, 0, 0, 0)) IN ('Monday') THEN 1 
							ELSE 0 
							END																					AS IsStartOfCalendarWeek
		FROM		#YearRangeTable
		CROSS JOIN	@daysInCalMonth
		JOIN		#smallIntTable ON Id <= DaysInMonth
		ORDER BY	Year, MonthNumber, Id, DaysInMonth
	END
GO
