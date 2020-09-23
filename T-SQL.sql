/*******************************************************************/
-- create database
USE master
GO
IF NOT EXISTS(
    SELECT name FROM sys.databases
    WHERE name = N'TestData'
)
CREATE DATABASE TestData  
GO  
-- create table
USE TestData
IF OBJECT_ID('dbo.Products','U') IS NOT NULL
DROP TABLE dbo.Products
GO
CREATE TABLE dbo.Products
   (ProductID INT PRIMARY KEY NOT NULL,
   ProductName VARCHAR(25) NOT NULL,
   Price MONEY NULL,
   ProductDescription VARCHAR(MAX) NULL);
GO
-- insert rows
INSERT dbo.Products (ProductID, ProductName, Price, ProductDescription)
VALUES 
    (1, 'Clamp', 12.48, 'Workbench Clamp'),
    (2, 'sdfd',13.50, 'wdlfkd cl')
GO
-- update
UPDATE dbo.Products
    SET ProductName = 'Flat Head'
    WHERE ProductID = 50
GO
-- read data; WHERE clause
SELECT ProductID, ProductName, Price, ProductDescription  
    FROM dbo.Products
    WHERE ProductID < 60    
GO 
-- create view
CREATE VIEW vw_Names AS
    SELECT ProductName, Price
    FROM Products;
GO
SELECT * FROM vw_Names;  
GO  
-- create a stored procedure
CREATE PROCEDURE pr_Names @VarPrice money  
   AS  
   BEGIN    
      PRINT 'Products less than ' + CAST(@VarPrice AS varchar(10));  
      SELECT ProductName, Price FROM vw_Names  
            WHERE Price < @varPrice;  
   END  
GO  
EXECUTE pr_Names 10.00;  
GO  
/*******************************************************************/
-- create SQL login
CREATE LOGIN [computer_name\Mary]
    FROM windows
    WITH DEFAULT_DATABASE = [TestData];
GO
-- grant access to a database
USE [TestData];  
GO  
CREATE USER [Mary] FOR LOGIN [computer_name\Mary];  
GO  
-- grant permission to stored procedure
GRANT EXECUTE ON pr_Names TO Mary;  
GO  