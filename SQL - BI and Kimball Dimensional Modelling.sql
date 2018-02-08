/*//////////////////////////////////////////////////////////////////////////
/////////////////////// KIMBALL / BI MODELLING /////////////////////////////
////////////////////////////////////////////////////////////////////////////
*/

-- Example schema and build of a 'Star Schema' or Kimball BI/Dimensional Model
-- One Fact Table, Two Dimensions, Primary Keys, Foreign Keys, Indexes and Schema Creates



/*//////////////////////////////////////////////////////////////////////////
////////////////////// CREATE DATABASE SCHEMAS /////////////////////////////
////////////////////////////////////////////////////////////////////////////
*/

CREATE SCHEMA [dim]
GO

CREATE SCHEMA [fact]
GO


/*//////////////////////////////////////////////////////////////////////////
////////////////////// CREATE DATABASE TABLES //////////////////////////////
////////////////////////////////////////////////////////////////////////////
*/

CREATE TABLE	[dim].[Date] (
					[DateKey] INT PRIMARY KEY CLUSTERED,
					[Date] DATETIME,
					[Year] INT,
					[QuarterName] VARCHAR(2),
					[QuarterNumberOfYear] INT,
					[MonthName] VARCHAR(20),
					[MonthNumberOfYear] INT,
					[WeekNameOfYear] VARCHAR(3),
					[WeekNumberOfYear] INT,
					[WeekNameOfMonth] INT,
					[WeekNumberOfMonth] INT,
					[DayName] VARCHAR(20),
					[DayNumberOfYear] INT,
					[DayNumberOfMonth] INT,
					[DayNumberOfWeek] INT,
					[IsWeekend] BIT,
					[IsWeekday] BIT
				);

CREATE TABLE	[dim].[Example] (
					[ExampleKey] INT PRIMARY KEY CLUSTERED,
					[BusinessKey] VARCHAR(20),
					[Description] VARCHAR(50)
				);


CREATE TABLE	[fact].[ExampleFactTable]	(
					[Id] BIGINT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
					[DateKey] INT,
					[ExampleKey] INT,
					[FactValueOne] INT,
					[FactValueTwo] DECIMAL(10,2)
				);

/*//////////////////////////////////////////////////////////////////////////
/////////////////// CREATE AND ENABLE FOREIGN KEYS /////////////////////////
////////////////////////////////////////////////////////////////////////////
*/

ALTER TABLE			[fact].[ExampleFactTable]
ADD CONSTRAINT		fk_fact_examplefacttable_dim_date_datekey 
FOREIGN KEY (		[DateKey]		) 
REFERENCES			[dim].[Date] ( [DateKey] );

ALTER TABLE			[fact].[ExampleFactTable]
ADD CONSTRAINT		fk_fact_examplefacttable_dim_example_examplekey
FOREIGN KEY (		[ExampleKey]		) 
REFERENCES			[dim].[Example] ( [ExampleKey] );



/*//////////////////////////////////////////////////////////////////////////
//////////////// CREATE AND ENABLE NCI/NCCSI INDEXES ///////////////////////
////////////////////////////////////////////////////////////////////////////
*/

-- Fact Table
CREATE INDEX nci_fact_examplefacttable_datekey_idx ON [fact].[ExampleFactTable] ([DateKey]);
CREATE INDEX nci_fact_examplefacttable_examplekey_idx ON [fact].[ExampleFactTable] ([ExampleKey]);

-- Dimension Table
-- If NCI is more appropriate...

CREATE INDEX nci_dim_date_date_idx ON [dim].[Date] ([Date]);
CREATE INDEX nci_dim_date_date_hierarchy_idx ON [dim].[Date] ([Year], [QuarterNumberOfYear], [MonthNumberOfYear], [WeekNumberOfYear], [WeekNameOfMonth], [Date]);
CREATE INDEX nci_dim_date_year_idx ON [dim].[Date] ([Year]);

-- If NCCSI is more appropriate...

CREATE NONCLUSTERED COLUMNSTORE INDEX nccsi_dim_date_idx ON [dim].[Date] (Date, Year, QuarterName, QuarterNumberOfYear, MonthName, MonthNumberOfYear, WeekNameOfYear, WeekNumberOfYear, WeekNameOfMonth, WeekNumberOfMonth, DayName, DayNumberOfYear, DayNumberOfMonth, DayNumberOfWeek, IsWeekend, IsWeekday);

/*//////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
*/
