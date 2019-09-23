/*

	Dynamic Data Masking 
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	http://www.kursysql.pl

*/



/*
	Wprowadzenie
*/



USE AdventureWorks2014





SELECT *
FROM Person.Person AS p
JOIN Person.PersonPhone AS pp ON pp.BusinessEntityID = p.BusinessEntityID
JOIN Person.EmailAddress AS ea ON ea.BusinessEntityID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress AS bea ON bea.BusinessEntityID = p.BusinessEntityID
JOIN Person.Address AS ad ON ad.AddressID = bea.AddressID


DROP TABLE IF EXISTS dbo.Users

-- Tabela na dane testowe, kolumna na email zamaskowana
CREATE TABLE dbo.Users
  (ID int IDENTITY PRIMARY KEY,
   FirstName nvarchar(100) ,
   LastName nvarchar(100),
   ModifiedDate datetime, 
   PhoneNumber varchar(25),
   EmailAddress nvarchar(100) MASKED WITH (FUNCTION = 'email()'),
   AddressLine nvarchar(60),
   City nvarchar(30),
   PostalCode int
)


-- 
INSERT Users (FirstName, LastName, ModifiedDate, PhoneNumber, EmailAddress, AddressLine, City, PostalCode)
SELECT TOP 10 p.FirstName, p.LastName, p.ModifiedDate, pp.PhoneNumber, ea.EmailAddress, ad.AddressLine1, ad.City, ad.PostalCode
FROM Person.Person AS p
JOIN Person.PersonPhone AS pp ON pp.BusinessEntityID = p.BusinessEntityID
JOIN Person.EmailAddress AS ea ON ea.BusinessEntityID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress AS bea ON bea.BusinessEntityID = p.BusinessEntityID
JOIN Person.Address AS ad ON ad.AddressID = bea.AddressID


-- Rick i Cliff mają uprawnienia do czytania tabeli Users
DROP USER IF EXISTS Rick 
DROP USER IF EXISTS Cliff 


CREATE USER Rick WITHOUT LOGIN
GRANT SELECT ON Users TO Rick
GO

CREATE USER Cliff WITHOUT LOGIN
GRANT SELECT ON Users TO Cliff
GO


-- Sprawdzamy co Rick i Cliff widzą w tabeli -> kolumna EmailAddress
EXECUTE AS USER = 'Rick';
	SELECT * FROM Users;
REVERT;

EXECUTE AS USER = 'Cliff';
	SELECT * FROM Users;
REVERT;



-- Zamaskowanie kolejnych kolumn
ALTER TABLE Users ALTER COLUMN FirstName ADD MASKED WITH (FUNCTION = 'partial(1,"XXXXXXX",0)')
ALTER TABLE Users ALTER COLUMN LastName ADD MASKED WITH (FUNCTION = 'partial(2,"XXX",0)')
ALTER TABLE Users ALTER COLUMN PhoneNumber ADD MASKED WITH (FUNCTION = 'default()')



EXECUTE AS USER = 'Rick';
	SELECT * FROM Users;
REVERT;

-- Zmiana sposobu maskowania numeru telefonu - pokaż 2 ostatnie cyfry
ALTER TABLE Users ALTER COLUMN PhoneNumber varchar(25) MASKED WITH (FUNCTION = 'partial(0,"XXXX",2)')
EXECUTE AS USER = 'Rick'
	SELECT * FROM Users
REVERT


-- Uprawnienie UMASK - dostęp do zamaskowanych danych
GRANT UNMASK TO Cliff;
GO
EXECUTE AS USER = 'Cliff'
	SELECT * FROM Users
REVERT; 






-- Operacja UPDATE
GRANT UPDATE ON Users TO Rick

EXECUTE AS USER = 'Rick'
	SELECT * FROM Users
REVERT


EXECUTE AS USER = 'Cliff'
	SELECT * FROM Users
REVERT

EXECUTE AS USER = 'Rick'
	UPDATE Users SET LastName = 'Kowalska' WHERE ID = 1
	SELECT * FROM Users
REVERT



-- Które kolumny mają ustawione maskowanie
SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function  
FROM sys.masked_columns AS c  
JOIN sys.tables AS tbl   
    ON c.object_id = tbl.object_id  
WHERE is_masked = 1;  



-- Jak złamać system
SELECT * FROM Users

EXECUTE AS USER = 'Rick'
	SELECT * FROM Users WHERE LastName = 'Ramirez'
REVERT




-- Usuwanie Dynamic Data Masking
ALTER TABLE Users ALTER COLUMN FirstName DROP MASKED
ALTER TABLE Users ALTER COLUMN LastName DROP MASKED
ALTER TABLE Users ALTER COLUMN PhoneNumber DROP MASKED
ALTER TABLE Users ALTER COLUMN EmailAddress DROP MASKED


EXECUTE AS USER = 'Rick'
	SELECT * FROM Users
REVERT






/*
	Funkcje
*/



EXECUTE AS USER = 'Rick'
	SELECT * FROM Users
REVERT


-- Default
-- * Łańuchy znaków (FirstName)

EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT
ALTER TABLE Users ALTER COLUMN Firstname nvarchar(100) MASKED WITH (FUNCTION = 'default()')
EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT

ALTER TABLE Users ALTER COLUMN FirstName DROP MASKED


-- Default
-- * Wartości liczbowe (PostalCode, PhoneNumber)

EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT
ALTER TABLE Users ALTER COLUMN PostalCode int MASKED WITH (FUNCTION = 'default()')
EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT

ALTER TABLE Users ALTER COLUMN PostalCode DROP MASKED



-- Default
-- * Daty (ModifiedDate)

EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT
ALTER TABLE Users ALTER COLUMN ModifiedDate datetime MASKED WITH (FUNCTION = 'default()')
EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT

ALTER TABLE Users ALTER COLUMN ModifiedDate DROP MASKED



-- Email
-- * Adresy e-mail (EmailAddress)

EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT
ALTER TABLE Users ALTER COLUMN EmailAddress nvarchar(100) MASKED WITH (FUNCTION = 'email()')
EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT

ALTER TABLE Users ALTER COLUMN EmailAddress DROP MASKED

-- !!!
ALTER TABLE Users ALTER COLUMN PostalCode int MASKED WITH (FUNCTION = 'email()')



-- Random
-- * Wartości liczbowe zastępowane losową wartością z zadanego zakresu

EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT
ALTER TABLE Users ALTER COLUMN PostalCode int MASKED WITH (FUNCTION = 'random(100, 200)')
EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT

ALTER TABLE Users ALTER COLUMN PostalCode DROP MASKED



-- partial (CustomString)
-- Wartości tekstowe - odkryte jest X znaków przed (prefix) i Y znaków po (suffix)
-- partial(prefix,[padding],suffix)

EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT
ALTER TABLE Users ALTER COLUMN Lastname nvarchar(100) MASKED WITH (FUNCTION = 'partial(1, "XX", 1)')
EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT

ALTER TABLE Users ALTER COLUMN Lastname DROP MASKED


EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT
ALTER TABLE Users ALTER COLUMN Lastname nvarchar(100) MASKED WITH (FUNCTION = 'partial(3, "XX", 2)')
EXECUTE AS USER = 'Rick'
	SELECT TOP 3 * FROM Users
REVERT


ALTER TABLE Users ALTER COLUMN Lastname DROP MASKED





