
--functions
---create a function that takes input an parameter type detetime and returns the date in the format
-- MM/DD/YYYY. for examples it I pass in '2006-11-21 23:34:o5.920',
---the output of the functions should be 11/21/2006

 SELECT dbo.formatDate('2006-11-21 23:34:05.920') AS FormattedDate;


Create FUNCTION formatDate (@datetime DATETIME)
RETURNS varchar(10)
AS
Begin
       Return convert(VARCHAR(10), @datetime,101)    --- we will used conert here 
END


---create a funtion that takes an input parameter type datetime and returns 
---the date in the format YYYYMMDD

create FUNCTION dateFromate ( @datetime DATETIME)
RETURNS varchar(10)
AS 
BEGIN
  Return convert (VARCHAR(10), @datetime,112)
  END

  select dbo.dateFromate('2006-11-21 23:34:05.920') as date_formated

 --- Views

---1.Create a view vwCustomerOrders which returns CompanyName. OrderID, OrderDate, ProductID, ProductName. Quantity, UnitPrice. Quantity * od. Unit Price


---select * from AdventureWorks2022.Sales.SalesOrderDetail --- ProductID , salesorderid , unitprice,orderqty,, salesorderdetailid
---select * from AdventureWorks2022.Production.Product---ProductID,ProductName
---select * from AdventureWorks2022.Purchasing.PurchaseOrderDetail---orderqty,productID,
select * from AdventureWorks2022.Purchasing.PurchaseOrderHeader---orderdate,PurchaseorderID,
---select * from AdventureWorks2022.Purchasing.Vendor ---comapny name , businessEntityID
---select * from AdventureWorks2022.Purchasing.ProductVendor---businessEntityID,ProductID
Create View vwCustomerOrders 
as 
select v.Name as Company_Name ,poh.PurchaseOrderID,poh.OrderDate,pro.ProductID, pro.Name, s.OrderQty,s.UnitPrice , s.OrderQty * s.UnitPrice as Total_price
from AdventureWorks2022.Purchasing.ProductVendor pv 
JOIN  AdventureWorks2022.Purchasing.Vendor v
on pv.BusinessEntityID=v.BusinessEntityID 
Join AdventureWorks2022.Sales.SalesOrderDetail s on pv.ProductID=s.ProductID
Join AdventureWorks2022.Production.Product pro on s.ProductID=pro.ProductID
JOIN AdventureWorks2022.Purchasing.PurchaseOrderDetail pu on pu.ProductID=pro.ProductID
JOIN  AdventureWorks2022.Purchasing.PurchaseOrderHeader poh on pu.PurchaseOrderID=poh.PurchaseOrderID

select * from vwCustomerOrders;

---2.Create a copy of the above view and modify it so that it only returns the above information for orders that were placed yesterday
select * from vwCustomerOrders
WHERE OrderDate = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);


---3.Use a CREATE VIEW statement to create a view called MyProducts. Your view should contain the ProductID, ProductName, Quantity PerUnit and Unit Price columns from 
---the Products table. It should also contain the CompanyName column from the Suppliers table and the CategoryName column from the Categories table. Your view should only 
---contain products that are not discontinued.

Create View vwNotDiscontinuedProducts 
as 
select v.Name as Company_Name ,pro.ProductID, pro.Name, s.OrderQty,s.UnitPrice , s.OrderQty * s.UnitPrice as Total_price
from AdventureWorks2022.Purchasing.ProductVendor pv 
JOIN  AdventureWorks2022.Purchasing.Vendor v
on pv.BusinessEntityID=v.BusinessEntityID 
Join AdventureWorks2022.Sales.SalesOrderDetail s on pv.ProductID=s.ProductID
Join AdventureWorks2022.Production.Product pro on s.ProductID=pro.ProductID
JOIN AdventureWorks2022.Purchasing.PurchaseOrderDetail pu on pu.ProductID=pro.ProductID
JOIN  AdventureWorks2022.Purchasing.PurchaseOrderHeader poh on pu.PurchaseOrderID=poh.PurchaseOrderID
where FinishedGoodsFlag=1;

select * from vwNotDiscontinuedProducts;

--- YET TO COMPLETE THE BELOW PART WHICH WILL BE THE NEXT WEEK TASK.



---Stored Procedures.(Use Adventure Works Database)
---1.Create a procedure InsertOrderDetails that takes OrderID, ProductID, Unit Price, Quantiy. 
---Discount as input parameters and inserts that order information in the Order Details table.
---After each order inserted, check the @@@@rowcount value to make sure that order was inserted properly. 
---If for any reason the order was not inserted, print the message: Failed to place the order. Please try again.
---Also your procedure should have these functionalities.
---Make the UnitPrice and Discount parameters optional
---If no UnitPrice is given, then use the UnitPrice value from the product table.
---If no Discount is given, then use a discount of 0.
---Adjust the quantity in stock (UnitsInStock) for the product by subtracting the quantity sold from inventory. However, if there is not enough of a product in stock, then abort the stored procedure
---without making any changes to the database. Print a message if the quantity in stock of a product drops below its Reorder Level as a result of the update.
---2.Create a procedure UpdateOrderDetails that takes OrderID, ProductID, Unit Price, 
---Quantity, and discount, and updates these values for that ProductID in that Order.
---All the parameters except the OrderID and ProductID should be optional so that if
---the user wants to only update Quantity she should be able to do so without providing
---the rest of the values. You need to also make sure that if any of the values. are 
---being passed in as NULL, then you want to retain the original value instead of 
---overwriting it with NULL. To accomplish this, look for the ISNULL() function in 
---google or sql server books online. Adjust the UnitsInStock value in products 
---table accordingly.
---3.Create a procedure GetOrderDetails that takes OrderID as 
---input parameter and returns all the records for that OrderID. If no records are
---found in Order Details table, then it should print the line: "The OrderID XXXX does
---not exits", where XXX should be the OrderlD entered by user and the procedure should 
---RETURN the value 1.






---Triggers

---1.If someone cancels an order in northwind database, then you want to delete that order from the Orders table. But you will not be able to delete that Order before deleting the records from 
---Order Details table for that particular order due to referential integrity constraints. Create an Instead of Delete trigger on Orders table so that if some one tries to delete an Order that
---trigger gets fired and that trigger should first delete everything in order details table and then delete that order from the Orders table

---2.When an order is placed for X units of product Y, we must first check the Products table to ensure that there is sufficient stock to fill the order. This trigger will operate on the
---Order Details table. If sufficient stock exists, then fill the order and decrement X units from the UnitsInStock column in Products. If insufficient stock. exists, then refuse 
---the order (ie. do not insert it) and notify the user that the order could not be filled because of insufficient stock.

---Note: Based on the understanding candidate has to create a sample data to perform these queries.