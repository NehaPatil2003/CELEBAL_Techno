 ---Level A (Assignment):
--- HumanResource = empl info
---production     = product info
---person         =employee worker
---purchase       = purchasing

---1 ) List of all coustomer
select * from [AdventureWorks2022].[Sales].Customer;


---2) List of all customers where company name ending in N
select * from [AdventureWorks2022].Sales.Store where Name Like '%N'

---3)List of all customers who live in berlin or london
select * from [AdventureWorks2022].Person.StateProvince s
JOIN [AdventureWorks2022].Person.CountryRegion c
on s.CountryRegionCode=c.CountryRegionCode
where c.Name IN ('Berlin','London');

---4)List of all coustomers who live in uk or usa 
select * from [AdventureWorks2022].Sales.Customer where TerritoryID IN (1 , 2 ,3 ,4 ,10)

---5)list of all products sorted by product name 
select * from  [AdventureWorks2022].Production.Product order by Name

---6)list of all products where product name starts with an A
select * from  [AdventureWorks2022].Production.Product where Name Like 'A%'

---7)list of customers who ever placed an order 
SELECT *
FROM [AdventureWorks2022].Sales.Customer c
JOIN [AdventureWorks2022].Sales.SalesOrderHeader soh
ON c.CustomerID = soh.CustomerID;


---8) list of customers who live in london and have bought chai
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName, a.City
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
WHERE pr.Name = 'Chai' AND a.City = 'London';

---9)list of customers who never place an order
SELECT *
FROM [AdventureWorks2022].Sales.Customer c
JOIN [AdventureWorks2022].Sales.SalesOrderHeader soh
ON c.CustomerID = soh.CustomerID;

---10)list of customers who order Tofu
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE pr.Name = 'Tofu';

---11)Details of first order of system
select top 1 * from AdventureWorks2022.Purchasing.PurchaseOrderDetail

---12)find the details of most expensive order data
select top 1 * from AdventureWorks2022.Purchasing.PurchaseOrderHeader
order by TotalDue DESC

---13)For each order get the OrderID and Average quantity of items in that order
select PurchaseOrderID,Avg(OrderQty) from AdventureWorks2022.Purchasing.PurchaseOrderDetail
GROUP BY PurchaseOrderID;

---14)For each order get the orderID , minimum quantity and max quantity for that order
SELECT PurchaseOrderID, MAX(OrderQty) AS MaxOrderQty
FROM Purchasing.PurchaseOrderDetail
GROUP BY PurchaseOrderID;

---15)Get a lisr of all managers and total number of employees who report to them
SELECT 
    m.BusinessEntityID AS ManagerID,
    m.JobTitle AS ManagerJobTitle,
    p.FirstName AS ManagerFirstName,
    p.LastName AS ManagerLastName,
    COUNT(e.BusinessEntityID) AS NumberOfDirectReports
FROM 
    HumanResources.Employee e
JOIN 
    HumanResources.Employee m ON e.BusinessEntityID = m.BusinessEntityID
JOIN 
    Person.Person p ON m.BusinessEntityID = p.BusinessEntityID
GROUP BY 
    m.BusinessEntityID, m.JobTitle, p.FirstName, p.LastName
ORDER BY 
    NumberOfDirectReports DESC;


---16)Get the orderID and total quantity for each order that has a total quantity of greater than 300
select PurchaseOrderID,ReceivedQty from AdventureWorks2022.Purchasing.PurchaseOrderDetail
where ReceivedQty>300;




---17)list of all orders placed on or after 1996/12/31
SELECT *
FROM Purchasing.PurchaseOrderHeader
WHERE OrderDate >= '1996-12-31';

---18))list of all orders shipped to canada
select * from  AdventureWorks2022.Sales.SalesOrderHeader s
where TerritoryID IN (6)

---19))list of all orders with order total>200
select * from AdventureWorks2022.Purchasing.PurchaseOrderHeader
where SubTotal>200

---20))list of countries and sales made in each country
SELECT st.CountryRegionCode AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.CountryRegionCode;

---21)List of customer ContactNumber and Number of orders they placed 
select PhoneNumber,OrderQty from AdventureWorks2022.Person.PersonPhone p ----- phno , businessEntity ID
JOIN AdventureWorks2022.Sales.PersonCreditCard s
ON p.BusinessEntityID=s.BusinessEntityID
JOIN AdventureWorks2022.Sales.SalesOrderHeader c
ON c.CreditCardID=s.BusinessEntityID
JOIN AdventureWorks2022.Sales.SalesOrderDetail o
ON o.SalesOrderID=c.SalesOrderID

---22)List of customer contactnames who have placed more than 3 orders
select * from AdventureWorks2022.Person.Person p  ---person name ,buENID
select * from AdventureWorks2022.Sales.SalesOrderDetail s  ----orderqty,salesorderid
select * from AdventureWorks2022.Sales.PersonCreditCard c---- buENID,Credit card
select * from AdventureWorks2022.Sales.SalesOrderHeader h ----- salesorderid

select FirstName, LastName ,OrderQty from AdventureWorks2022.Person.Person p 
JOIN AdventureWorks2022.Sales.PersonCreditCard s
ON p.BusinessEntityID=s.BusinessEntityID
JOIN AdventureWorks2022.Sales.SalesOrderHeader c
ON c.CreditCardID=s.BusinessEntityID
JOIN AdventureWorks2022.Sales.SalesOrderDetail o
ON o.SalesOrderID=c.SalesOrderID
where OrderDate>3;

---23)List of discountinued products which were orderes bet 1/1/1997 and 1/1/1998
select * from AdventureWorks2022.Sales.SalesOrderHeader
select * from AdventureWorks2022.Sales.SalesOrderDetail
select * from AdventureWorks2022.Production.Product


SELECT p.Name,
       CASE WHEN p.DiscontinuedDate IS NOT NULL THEN 'Discontinued' ELSE 'Active' END AS Discontinued_Product,
       p.DiscontinuedDate,
       h.OrderDate
FROM Production.Product p
JOIN Sales.SalesOrderDetail s ON p.ProductID = s.ProductID
JOIN Sales.SalesOrderHeader h ON h.SalesOrderID = s.SalesOrderID
WHERE h.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';
select * from Person.Person

---24)List of empl firstname , lastname , superviser firstname, lastname 
SELECT e.FirstName AS EMP_FirstName, e.LastName AS EMP_LastName, 
       s.FirstName AS SP_FirstName, s.LastName AS SP_LastName
FROM Person.Person e 
LEFT JOIN Person.Person s ON s.BusinessEntityID = e.BusinessEntityID
WHERE e.PersonType = 'EM' OR s.PersonType = 'SP';


---25)list of empl id and total sale conducted by emp
SELECT
    e.BusinessEntityID AS EmployeeID,
    SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN HumanResources.Employee e ON soh.SalesPersonID = e.BusinessEntityID
GROUP BY e.BusinessEntityID
ORDER BY TotalSales DESC;


---26)list of emp whose firstname contains charcter a
select FirstName from Person.Person where FirstName LIKE '%a%';

---27)list of managers who have more than 6 people reporting to them 

---28)list of oreders and prodctnames
select s.ProductID,p.Name,s.OrderQty from Production.Product p
JOIN Sales.SalesOrderDetail s
on s.ProductID=p.ProductID


---29)list of orders place by the best customer

WITH BestCustomer AS (
    SELECT TOP 1
        c.CustomerID,
        SUM(soh.TotalDue) AS TotalSpent
    FROM Sales.Customer c
    JOIN Sales.SalesOrderHeader soh ON soh.CustomerID = c.CustomerID
    GROUP BY c.CustomerID
    ORDER BY TotalSpent DESC
)
SELECT
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue,
    c.CustomerID
   
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN BestCustomer bc ON c.CustomerID = bc.CustomerID
ORDER BY soh.OrderDate;

---30)list of orders placed by customers who do not havr a fax number
---no fax field is there

---31)List of Postal codes where the product Tofu was shipped
SELECT DISTINCT
    a.PostalCode
FROM
    Production.Product p
JOIN
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN
    Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN
    Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE
    p.Name = 'Tofu';


---32)List of product Names that were shipped to France
select p.ProductID, p.Name,soh.TerritoryID from Production.Product p
JOIN Sales.SalesOrderDetail s ON p.ProductID=s.ProductID
JOIN Sales.SalesOrderHeader soh ON soh.SalesOrderID=s.SalesOrderID
where TerritoryID=7;

---33)List of productNames and Categories for the supplier 'Specialty Biscuits,Ltd.
SELECT 
    p.Name AS ProductName,
    pc.Name AS Category,
    psc.Name AS Subcategory
FROM 
    Purchasing.Vendor v
JOIN 
    Purchasing.ProductVendor pv ON v.BusinessEntityID = pv.BusinessEntityID
JOIN 
    Production.Product p ON pv.ProductID = p.ProductID
JOIN 
    Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN 
    Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE 
    v.Name = 'Specialty Biscuits,Ltd.';


---34)List of product that were never ordered 
select p.ProductID, p.Name, s.OrderQty from Production.Product p
JOIN Sales.SalesOrderDetail s
ON p.ProductID=s.ProductID
where OrderQty=0;

---35)list of products where units in stock is less than 10 and units on order are 0
select Name,SafetyStockLevel from Production.Product
where SafetyStockLevel < 10  

---36)list of top 10 countries by sales
select top 10 * from Sales.SalesTerritory 
order by SalesYTD DESC

---37)Number of orders each emp has taken for customers with customerIDs between A and AO
select * from Sales.Customer

---38)Orderdate of most expensive order 
SELECT TOP 1 o.OrderDate
FROM [AdventureWorks2022].Purchasing.PurchaseOrderHeader o
JOIN [AdventureWorks2022].Purchasing.PurchaseOrderDetail d ON o.PurchaseOrderID = d.PurchaseOrderID
GROUP BY o.OrderDate, o.PurchaseOrderID
ORDER BY SUM(d.UnitPrice * d.OrderQty) DESC;

select * from [AdventureWorks2022].Sales.PersonCreditCard
select * from [AdventureWorks2022].Sales.Customer
select * from [AdventureWorks2022].Sales.CurrencyRate
select * from [AdventureWorks2022].Sales.Currency--- currency
select * from [AdventureWorks2022].Sales.CreditCard
select * from [AdventureWorks2022].Sales.CountryRegionCurrency
select * from [AdventureWorks2022].Sales.SalesOrderDetail
select * from [AdventureWorks2022].Sales.SalesOrderHeader
select * from [AdventureWorks2022].Sales.SalesTerritory
select * from [AdventureWorks2022].Sales.SalesTerritoryHistory
select * from [AdventureWorks2022].Purchasing.PurchaseOrderDetail
select * from [AdventureWorks2022].Purchasing.Vendor

select * from [AdventureWorks2022].Person.StateProvince  
select * from [AdventureWorks2022].Person.Address 
select * from [AdventureWorks2022].Person.CountryRegion
select * from [AdventureWorks2022].Person.PhoneNumberType
select * from [AdventureWorks2022].Person.EmailAddress
select * from [AdventureWorks2022].Person.ContactType

---39)Product Name and total revenue from that product
SELECT 
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS TotalRevenue
FROM 
    Production.Product p
JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY 
    p.Name
ORDER BY 
    TotalRevenue DESC;

---40)Supplierid and number of products offered 
select

---41)Top ten customers based on their bussiness
select TOP 10 * from Sales.Customer c
JOIN Sales.SalesOrderHeader soh
ON  soh.CustomerID=c.CustomerID
order by TotalDue DESC

---42)what is total revenue of company
SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;
