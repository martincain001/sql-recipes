/*////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// SCHEMA SWITCH ARCHITECTURE ////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
*/

CREATE SCHEMA [staging]		-- pull raw data from sources into this schema and process all etl in these tables
GO

CREATE SCHEMA [shadow]		-- this is the working area where we take a clone/copy of live, apply the new data etc from staging and create a new 'live table'
GO

CREATE SCHEMA [live]		-- this is the real live schema and final outputs
GO

CREATE SCHEMA [switch]		-- this is used in the triangular movement needed in schema switching
GO

ALTER SCHEMA		switch		TRANSFER		shadow.table1;	-- move the shadow table into the swtich schema, leaving shadow free
ALTER SCHEMA		shadow		TRANSFER		live.table1;	-- move the live table into the shadow schema, in the space just created above.
ALTER SCHEMA		live		TRANSFER		switch.table1;	-- the original shadow table, currently waiting in Switch, can now be moved over into Live


-- Now, the passive shadow table hich has the new ETL and/or data applied, is the live table.
-- From here, either sync the two tables from "new live" to "old live" (which is now shadow)... or drop shadow and rebuild with a SELECT INTO, etc.