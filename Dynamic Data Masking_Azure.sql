/*

	Dynamic Data Masking 
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	http://www.kursysql.pl

*/



/*
	Azure SQL Database
*/

DROP TABLE IF EXISTS dbo.Users

-- Tabela na dane testowe, kolumna na email zamaskowana
CREATE TABLE dbo.Users
  (ID int IDENTITY PRIMARY KEY,
   FirstName nvarchar(100) ,
   LastName nvarchar(100),
   ModifiedDate datetime, 
   PhoneNumber nvarchar(25),
   EmailAddress nvarchar(100) MASKED WITH (FUNCTION = 'email()'),
   AddressLine nvarchar(60),
   City nvarchar(30),
   PostalCode nvarchar(30)
)

INSERT Users (FirstName, LastName, ModifiedDate, PhoneNumber, EmailAddress, AddressLine, City, PostalCode)
SELECT TOP 10 c.FirstName, c.LastName, c.ModifiedDate, c.Phone, 
	c.EmailAddress, a.AddressLine1, a.City, a.PostalCode
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca ON ca.CustomerID = c.CustomerID
JOIN SalesLT.Address AS a ON a.AddressID = ca.AddressID



-- Rick i Cliff maj¹ uprawnienia do czytania tabeli Users
CREATE USER Rick WITHOUT LOGIN
GRANT SELECT ON Users TO Rick

CREATE USER Cliff WITHOUT LOGIN
GRANT SELECT ON Users TO Cliff


-- Sprawdzamy co Rick widzi w tabeli -> kolumna EmailAddress
EXECUTE AS USER = 'Rick'
	SELECT * FROM Users
REVERT;



-- Zamaskowanie kolejnych kolumn
ALTER TABLE Users ALTER COLUMN FirstName ADD MASKED WITH (FUNCTION = 'partial(1,"XXXXXXX",0)')
ALTER TABLE Users ALTER COLUMN LastName ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",0)')
ALTER TABLE Users ALTER COLUMN PhoneNumber ADD MASKED WITH (FUNCTION = 'default()')

-- Usuwanie Dynamic Data Masking
ALTER TABLE Users ALTER COLUMN FirstName DROP MASKED
ALTER TABLE Users ALTER COLUMN LastName DROP MASKED
ALTER TABLE Users ALTER COLUMN PhoneNumber DROP MASKED


-- portal.azure.com -->>

EXECUTE AS USER = 'Rick';
	SELECT * FROM Users;
REVERT;

EXECUTE AS USER = 'Cliff';
	SELECT * FROM Users;
REVERT;




ALTER TABLE Users ALTER COLUMN FirstName DROP MASKED
ALTER TABLE Users ALTER COLUMN LastName DROP MASKED
ALTER TABLE Users ALTER COLUMN PhoneNumber DROP MASKED
ALTER TABLE Users ALTER COLUMN EmailAddress DROP MASKED


EXECUTE AS USER = 'Rick'
	SELECT * FROM Users
REVERT



DROP USER Rick
