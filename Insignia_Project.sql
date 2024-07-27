--data model

USE InsigniaDB;

CREATE TABLE Customer_Dim (
    Customer_ID INT PRIMARY KEY IDENTITY(1,1),
    Customer_Name VARCHAR(255),
    Customer_Address VARCHAR(255),
    Lineage_Id BIGINT,
    Effective_Start_Date DATETIME,
    Effective_End_Date DATETIME,
    Is_Current BIT
);


CREATE TABLE Product_Dim (
    Product_ID INT PRIMARY KEY IDENTITY(1,1),
    Product_Name VARCHAR(255),
    Product_Category VARCHAR(255),
    Lineage_Id BIGINT,
    Effective_Start_Date DATETIME,
    Effective_End_Date DATETIME,
    Is_Current BIT
);


CREATE TABLE Geography_Dim (
    Geography_ID INT PRIMARY KEY IDENTITY(1,1),
    Country VARCHAR(255),
    State VARCHAR(255),
    City VARCHAR(255),
    Population INT,
    Lineage_Id BIGINT,
    Effective_Start_Date DATETIME,
    Effective_End_Date DATETIME,
    Is_Current BIT
);


CREATE TABLE Date_Dim (
    DateKey INT PRIMARY KEY,
    Date DATE,
    Day_Number INT,
    Month_Name VARCHAR(20),
    Short_Month VARCHAR(3),
    Calendar_Month_Number INT,
    Calendar_Year INT,
    Fiscal_Month_Number INT,
    Fiscal_Year INT,
    Week_Number INT
);

-- Populate Date_Dim with dates from 2000 to 2023
DECLARE @Date DATE = '2000-01-01';
WHILE @Date <= '2023-12-31'
BEGIN
    INSERT INTO Date_Dim
    (DateKey, Date, Day_Number, Month_Name, Short_Month, Calendar_Month_Number, Calendar_Year, Fiscal_Month_Number, Fiscal_Year, Week_Number)
    VALUES
    (CONVERT(INT, FORMAT(@Date, 'yyyyMMdd')), @Date,
     DAY(@Date), FORMAT(@Date, 'MMMM'), FORMAT(@Date, 'MMM'),
     MONTH(@Date), YEAR(@Date),
     CASE WHEN MONTH(@Date) >= 7 THEN MONTH(@Date) - 6 ELSE MONTH(@Date) + 6 END,
     CASE WHEN MONTH(@Date) >= 7 THEN YEAR(@Date) ELSE YEAR(@Date) - 1 END,
     DATEPART(WEEK, @Date));
    SET @Date = DATEADD(DAY, 1, @Date);
END;



CREATE TABLE Sales_Fact (
    Sales_ID INT PRIMARY KEY IDENTITY(1,1),
    Customer_ID INT,
    Product_ID INT,
    Geography_ID INT,
    DateKey INT,
    Sales_Amount DECIMAL(18, 2),
    Quantity_Sold INT,
    Lineage_Id BIGINT,
    FOREIGN KEY (Customer_ID) REFERENCES Customer_Dim(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product_Dim(Product_ID),
    FOREIGN KEY (Geography_ID) REFERENCES Geography_Dim(Geography_ID),
    FOREIGN KEY (DateKey) REFERENCES Date_Dim(DateKey)
);



CREATE TABLE Lineage (
    Lineage_Id BIGINT PRIMARY KEY IDENTITY(1,1),
    Source_System VARCHAR(100),
    Load_Stat_Datetime DATETIME,
    Load_EndDatetime DATETIME,
    Rows_at_Source INT,
    Rows_at_destination_Fact INT,
    Load_Status BIT
);


--ETL creation

USE InsigniaDB;

-- Creating a copy of the Insignia_staging table
SELECT * INTO Insignia_staging_copy FROM [Insignia_staging 2 - Insignia_staging 2];



-- Insert incremental data into Insignia_staging_copy
INSERT INTO Insignia_staging_copy
SELECT * FROM Insignia_incremental2 ;



-- Example SQL for SCD Type 2 (Inserting new and updated records)
MERGE INTO Customer_Dim AS Target
USING (SELECT DISTINCT CustomerName, CustomerAddress FROM Insignia_staging_copy) AS Source
ON Target.Customer_Name = Source.CustomerName
AND Target.Customer_Address = Source.CustomerAddress
WHEN MATCHED AND Target.Is_Current = 1 THEN
    UPDATE SET Target.Is_Current = 0, Target.Effective_End_Date = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (Customer_Name, Customer_Address, Effective_Start_Date, Is_Current, Lineage_Id)
    VALUES (Source.CustomerName, Source.CustomerAddress, GETDATE(), 1, [Lineage_Id]);


-- Example SQL for SCD Type 1 (Updating existing records)
MERGE INTO Product_Dim AS Target
USING (SELECT DISTINCT ProductID, ProductName, ProductCategory FROM Insignia_staging_copy) AS Source
ON Target.Product_ID = Source.ProductID
WHEN MATCHED THEN
    UPDATE SET Target.Product_Name = Source.ProductName, Target.Product_Category = Source.ProductCategory
WHEN NOT MATCHED THEN
    INSERT (Product_Name, Product_Category, Lineage_Id)
    VALUES (Source.ProductName, Source.ProductCategory, [Lineage_Id]);



-- Example SQL for SCD Type 3 (Updating population)
MERGE INTO Geography_Dim AS Target
USING (SELECT DISTINCT Country, State, City, Population FROM Insignia_staging_copy) AS Source
ON Target.Country = Source.Country
AND Target.State = Source.State
AND Target.City = Source.City
WHEN MATCHED THEN
    UPDATE SET Target.Population = Source.Population
WHEN NOT MATCHED THEN
    INSERT (Country, State, City, Population, Lineage_Id)
    VALUES (Source.Country, Source.State, Source.City, Source.Population, [Lineage_Id]);



-- Example SQL to load Sales Fact Table
INSERT INTO Sales_Fact (Customer_ID, Product_ID, Geography_ID, DateKey, Sales_Amount, Quantity_Sold, Lineage_Id)
SELECT c.Customer_ID, p.Product_ID, g.Geography_ID, d.DateKey, s.SalesAmount, s.QuantitySold, [Lineage_Id]
FROM Insignia_staging_copy s
JOIN Customer_Dim c ON s.CustomerName = c.Customer_Name
JOIN Product_Dim p ON s.ProductID = p.Product_ID
JOIN Geography_Dim g ON s.City = g.City AND s.State = g.State AND s.Country = g.Country
JOIN Date_Dim d ON s.OrderDate = d.Date


-- Truncate the Insignia_staging_copy table
TRUNCATE TABLE Insignia_staging_copy;



-- Record lineage data for the ETL process
INSERT INTO Lineage (Source_System, Load_Stat_Datetime, Load_EndDatetime, Rows_at_Source, Rows_at_destination_Fact, Load_Status)
VALUES ('Insignia', GETDATE(), GETDATE(), (SELECT COUNT(*) FROM Insignia_staging), (SELECT COUNT(*) FROM Sales_Fact), 1);



