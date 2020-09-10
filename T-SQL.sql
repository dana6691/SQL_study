/*******************************************************************/
-- create database
CREATE DATABASE TestData  
GO  
-- create table
CREATE TABLE dbo.Products
   (ProductID INT PRIMARY KEY NOT NULL,
   ProductName VARCHAR(25) NOT NULL,
   Price MONEY NULL,
   ProductDescription VARCHAR(MAX) NULL)
GO
-- insert
INSERT dbo.Products (ProductID, ProductName, Price, ProductDescription)
VALUES (1, 'Clamp', 12.48, 'Workbench Clamp')

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