------ DDL Triggers
--1. Data Definition Events(CREATE, ALTER, DROP)
--2. Create DDL Triggers
--3. DDL Server-Scoped Trigger 
--4. Changing the Firing order of Triggers
/*******************************************************************/
USE Movies
GO

-- NO CREATE new table
CREATE OR ALTER TRIGGER trgNoNewTables
ON DATABASE
FOR CREATE_TABLE
AS
BEGIN
	PRINT 'No new tables please'
	ROLLBACK
END

-- Testing a Trigger
CREATE TABLE tblTest(ID INT)
GO

CREATE DATABASE TestDB
GO
USE TestDB
GO
CREATE TABLE tblTest(ID INT)
GO
DROP TABLE tblTest
GO
USE Movies 
GO
DROP DATABASE TestDB


-- Modifying a Trigger
ALTER TRIGGER trgNoNewTables
ON DATABASE
FOR CREATE_TABLE
AS
BEGIN
	PRINT 'No changes to table please'
	ROLLBACK
END
-- Testing a Trigger
CREATE TABLE tblTest(ID INT)
GO

-- Disabling/Enabling a Trigger 
DISABLE TRIGGER trgNoNewTables ON DATABASE
GO
ENABLE TRIGGER trgNoNewTables ON DATABASE
GO
DISABLE TRIGGER ALL ON DATABASE
GO

-- Removing a Trigger
DROP TRIGGER trgNoNewTables ON DATABASE


-- Creating Server-scoped Trigger
CREATE TRIGGER trgNoNewTables
ON ALL SERVER
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
	PRINT 'No change to the tables please'
	ROLLBACK
END

-- Disable/Enable Server-scoped Trigger
ENABLE TRIGGER trgNoNewTables ON ALL SERVER
GO
DISABLE TRIGGER trgNoNewTables ON ALL SERVER
GO
DISABLE TRIGGER ALL ON ALL SERVER
GO


-- Changing the Firing order of Triggers
USE Movies
GO
CREATE TRIGGER trgSecondTrigger ON DATABASE
FOR CREATE_TABLE AS
	PRINT 'This is the second trigger'
GO

CREATE TRIGGER trgFirstTrigger ON DATABASE
FOR CREATE_TABLE AS
	PRINT 'This is the first trigger'
GO

-- Testing 
CREATE TABLE tblTest(ID INT) 
GO
DROP TABLE tblTest 
GO

-- Reordering Triggers
EXEC sp_settriggerorder
	@triggername = 'trgFirstTrigger',
	@order = 'first',
	@stmttype = 'CREATE_TABLE',
	@namespace = 'DATABASE'

CREATE TABLE tblTest(ID INT) 
GO
DROP TABLE tblTest 
GO

EXEC sp_settriggerorder
	@triggername = 'trgFirstTrigger',
	@order = 'last',
	@stmttype = 'CREATE_TABLE',
	@namespace = 'DATABASE'

CREATE TABLE tblTest(ID INT) 
GO
DROP TABLE tblTest 
GO
