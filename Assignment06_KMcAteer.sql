--*************************************************************************--
-- Title: Assignment06
-- Author: KMcAteer
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-02-24,KMcAteer,Created File
--2021-02-24,KMcAteer,Created Base Views
--2021-02-24,KMcAteer,Set Permissions
--2021-02-24,Create various reporting views
--2021-02-24,Select from views
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KMcAteer')
	 Begin 
	  Alter Database [Assignment06DB_KMcAteer] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KMcAteer;
	 End
	Create Database Assignment06DB_KMcAteer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KMcAteer;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
--NOTES------------------------------------------------------------------------------------ 
 --1) You can use any name you like for you views, but be descriptive and consistent
 --2) You can use your working code from assignment 5 for much of this assignment
 --3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!



go
Create View vCategories
WITH SCHEMABINDING
AS
 Select CategoryID, CategoryName From dbo.Categories;
 go


 go
 Create View vProducts
 WITH SCHEMABINDING
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
  go

  go 
  Create View vEmployees
  WITH SCHEMABINDING
  AS
   Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
   go

   go
   Create View vInventories
   WITH SCHEMABINDING
   AS
    Select InventoryID, InventoryDate, EmployeeID, ProductID, Count From dbo.Inventories;
	go



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_KMcAteer;
Deny Select On Categories to Public;
Grant Select On vCategories to Public;

Deny Select On Products to Public;
Grant Select On vProducts to Public;

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

go
Create View vProductsbyCategory
AS 
Select TOP 100000000000
CategoryName, ProductName,UnitPrice
From vCategories T0
Inner Join vProducts T1
ON T0.CategoryID = T1.CategoryID
Order By CategoryName, ProductName;
go


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

go
Create View vInventoryByDate
AS
Select TOP 100000000000
ProductName, InventoryDate, Count
FROM vProducts T0 INNER JOIN vInventories T1
ON T0.ProductID = T1.ProductID
ORDER BY ProductName, InventoryDate, Count;
go

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

go
Create View vInventoryByEmployee
AS
Select DISTINCT TOP 100000000000
InventoryDate, ConCAT(EmployeeFirstName, ' ', EmployeeLastName) AS 'EmployeeName'
FROM vEmployees T0 Inner JOIN vInventories T1
ON T0.EmployeeID = T1.EmployeeID
Order By InventoryDate;
go


-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

go
Create View vCategoryAndProductByInventoryDate
AS
Select TOP 100000000000
CategoryName, ProductName, InventoryDate, Count
FROM vCategories T0 INNER JOIN vProducts T1
ON T0.CategoryID = T1.CategoryID
INNER JOIN vInventories T2
ON T1.ProductID = T2.ProductID
Order By CategoryName, ProductName, InventoryDate, Count;
go


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!



go
Create View vInventoryCountByEmployee
AS
Select TOP 100000000000
CategoryName, ProductName, InventoryDate, Count, CONCAT(EmployeeFirstName, ' ', EmployeeLastName) AS 'EmployeeName'
FROM vCategories T0 INNER JOIN vProducts T1
ON T0.CategoryID = T1.CategoryID
INNER JOIN vInventories T2
ON T1.ProductID = T2.ProductID
INNER JOIN vEmployees T3
ON T3.EmployeeID = T2.EmployeeID
Order By InventoryDate, CategoryName, ProductName, EmployeeName;
go



-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

go
Create View vInventoryChaiAndChang
AS
Select 
CategoryName, ProductName, InventoryDate, Count, CONCAT(EmployeeFirstName, ' ', EmployeeLastName) AS 'EmployeeName'
From vCategories T0 Inner Join vProducts T1
ON T0.CategoryID = T1.CategoryID
Inner JOIN vInventories T2
ON T1.ProductID = T2.ProductID
Inner JOIN vEmployees T3
ON T2.EmployeeID = T3.EmployeeID
Where T1.ProductID IN (Select ProductID From Products Where ProductName = 'Chai' OR ProductName = 'Chang');
go


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

go
Create View vEmployeesWithManagerName
AS
Select TOP 100000000000
CONCAT(Mgr.EmployeeFirstName, ' ', Mgr.EmployeeLastName) AS 'Manager', CONCAT(Emp.EmployeeFirstName, ' ', Emp.EmployeeLastName) AS 'Employee'
FROM vEmployees Mgr Inner Join vEmployees Emp
ON Emp.ManagerID = Mgr.EmployeeID
Order BY Manager;
go


-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

go
Create View vInventoriesAll
AS
Select T0.CategoryID, CategoryName, T1.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, T3.EmployeeID, 
CONCAT(T3.EmployeeFirstName, ' ', T3.EmployeeLastName) AS 'Employee', 
CONCAT(Mgr.EmployeeFirstName, ' ', Mgr.EmployeeLastName) AS 'Manager'
From vCategories T0 Inner Join vProducts T1
ON T0.CategoryID = T1.CategoryID
Inner Join vInventories T2
ON T1.ProductID = T2.ProductID
Inner Join vEmployees T3
ON T2.EmployeeID = T3.EmployeeID
Inner Join vEmployees Mgr
ON T3.EmployeeID = Mgr.EmployeeID;
go


-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsbyCategory]
Select * From [dbo].[vInventoryByDate]
Select * From [dbo].[vInventoryByEmployee]
Select * From [dbo].[vCategoryAndProductByInventoryDate]
Select * From [dbo].[vInventoryCountByEmployee]
Select * From [dbo].[vInventoryChaiAndChang]
Select * From [dbo].[vEmployeesWithManagerName]
Select * From [dbo].[vInventoriesAll]
/***************************************************************************************/