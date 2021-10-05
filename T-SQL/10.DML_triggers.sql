/*******************************************************************/
------ DML Triggers
--1. Data Manipulation Events(INSERT,UPDATE and DELETE)
--2. Create AFTER and INSTEAD OF Triggers
--3. Inserted and Deleted Tables
--4. Validate data using Triggers
/*******************************************************************/
USE Movies
GO
-- AFTER, INSERT/UPDATE/DELETE
ALTER TRIGGER trgActorsChanged
ON tblActor
AFTER INSERT,UPDATE,DELETE
AS
BEGIN
	PRINT 'Data was changed in the Actor table'
END

GO

-- INSTEAD OF INSERT
CREATE TRIGGER trgActorInserted
ON tblActor
INSTEAD OF INSERT
AS
BEGIN
	RAISERROR ('No more actors can be inserted', 16,1)
END
GO

ALTER TRIGGER trgActorInserted
ON tblActor
INSTEAD OF INSERT
AS
BEGIN
	SELECT * FROM inserted
END
GO

-- Turn off row counts
SET NOCOUNT ON

--Insert a new record
INSERT INTO tblActor(ActorID, ActorName) VALUES (999, 'New Actor')
--Update a record
UPDATE tblActor SET ActorDOB = GETDATE() WHERE ActorID = 999
--Delete a record
DELETE FROM tblActor WHERE ActorID = 999


SELECT * FROM tblActor WHERE ActorID = 999

-- Validate data
CREATE TRIGGER trgCastMemberAdded
ON tblCast
AFTER INSERT 
AS
BEGIN
	IF EXISTS(
		SELECT * FROM tblActor AS a
		INNER JOIN inserted AS i
		ON a.ActorID = i.CastActorID
		WHERE ActorDOB IS NOT NULL)
	BEGIN
		RAISERROR('Sorry, that actor has expired',16,1)
		ROLLBACK TRANSACTION
		RETURN
	END
END
GO

INSERT INTO tblCast(CastID, CastActorID, CastFilmID, CastCharacterName)
VALUES(9998,1,333,'Random Red Shirt')