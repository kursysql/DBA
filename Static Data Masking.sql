/*

	Static Data Masking 
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	http://www.kursysql.pl

*/

--DROP DATABASE IF EXISTS SensitiveDataDB
--GO

--CREATE DATABASE SensitiveDataDB
--GO

--USE SensitiveDataDB
--GO

USE AdventureWorks2014
GO


DROP TABLE IF EXISTS dbo.Users


CREATE TABLE dbo.Users
  (ID int IDENTITY CONSTRAINT PK_Users PRIMARY KEY,
   FirstName nvarchar(100) ,
   LastName nvarchar(100),
   FullName nvarchar(200),
   ModifiedDate datetime, 
   PhoneNumber nvarchar(25),
   EmailAddress nvarchar(100),
   AddressLine nvarchar(60),
   City nvarchar(30),
   PostalCode nvarchar(30)
)


INSERT Users (FirstName, LastName, FullName, ModifiedDate, PhoneNumber, EmailAddress, AddressLine, City, PostalCode)
SELECT TOP 10 p.FirstName, p.LastName, CONCAT(p.FirstName, ' ', p.LastName), p.ModifiedDate, pp.PhoneNumber, ea.EmailAddress, ad.AddressLine1, ad.City, ad.PostalCode
FROM Person.Person AS p
JOIN Person.PersonPhone AS pp ON pp.BusinessEntityID = p.BusinessEntityID
JOIN Person.EmailAddress AS ea ON ea.BusinessEntityID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress AS bea ON bea.BusinessEntityID = p.BusinessEntityID
JOIN Person.Address AS ad ON ad.AddressID = bea.AddressID


SELECT * FROM Users




