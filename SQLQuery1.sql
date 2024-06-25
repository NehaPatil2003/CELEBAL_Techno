

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

CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount FLOAT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorMessage NVARCHAR(200);
    DECLARE @UnitsInStockBefore INT, @UnitsInStockAfter INT;
    DECLARE @ReorderLevel INT;

    -- Check if UnitPrice is NULL, then get it from the Product table
    IF @UnitPrice IS NULL
        SELECT @UnitPrice = UnitPrice FROM Sales.SalesOrderDetail WHERE ProductID = @ProductID;


    IF @UnitsInStockBefore < @Quantity
    BEGIN
        SET @ErrorMessage = 'Failed to place the order. Not enough stock available.';
        PRINT @ErrorMessage;
        RETURN;
    END

    -- Calculate new UnitsInStock
    SET @UnitsInStockAfter = @UnitsInStockBefore - @Quantity;

    -- Check if UnitsInStock drops below ReorderLevel
    IF @UnitsInStockAfter < @ReorderLevel
        PRINT 'Warning: Units in stock for ProductID ' + CAST(@ProductID AS VARCHAR(10))
            + ' dropped below reorder level.';

			SELECT * FROM AdventureWorks2022.Sales.SalesOrderDetail;
    -- Insert into Order Details table
    INSERT INTO Sales.SalesOrderDetail(SalesOrderID, ProductID, UnitPrice, OrderQty)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

    -- Check if the insertion was successful
    IF @@ROWCOUNT = 0
    BEGIN
        SET @ErrorMessage = 'Failed to place the order. Please try again.';
        PRINT @ErrorMessage;
    END
END


---2.Create a procedure UpdateOrderDetails that takes OrderID, ProductID, Unit Price, 
---Quantity, and discount, and updates these values for that ProductID in that Order.
---All the parameters except the OrderID and ProductID should be optional so that if
---the user wants to only update Quantity she should be able to do so without providing
---the rest of the values. You need to also make sure that if any of the values. are 
---being passed in as NULL, then you want to retain the original value instead of 
---overwriting it with NULL. To accomplish this, look for the ISNULL() function in 
---google or sql server books online. Adjust the UnitsInStock value in products 
---table accordingly.

CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount FLOAT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnitsInStockBefore INT, @UnitsInStockAfter INT;
    DECLARE @ReorderLevel INT;

    -- Retrieve current values from OrderDetail for error handling and UnitsInStock update
    SELECT @UnitsInStockBefore = od.OrderQty,
           @UnitPrice = COALESCE(@UnitPrice, od.UnitPrice),
           @Quantity = COALESCE(@Quantity, od.Quantity),
           @Discount = COALESCE(@Discount, od.Discount)
    FROM Sales.SalesOrderDetail od
    WHERE od.SalesOrderID = @OrderID
      AND od.ProductID = @ProductID;

    -- Check if Quantity is NULL, retain original value
    IF @Quantity IS NULL
        SET @Quantity = @UnitsInStockBefore;



    IF @UnitsInStockBefore < @Quantity
    BEGIN
        PRINT 'Failed to update the order. Not enough stock available.';
        RETURN;
    END

    -- Calculate new UnitsInStock
    SET @UnitsInStockAfter = @UnitsInStockBefore - @Quantity;

    -- Check if UnitsInStock drops below ReorderLevel
    IF @UnitsInStockAfter < @ReorderLevel
        PRINT 'Warning: Units in stock for ProductID ' + CAST(@ProductID AS VARCHAR(10))
            + ' dropped below reorder level.';

    -- Update Order Detail
    UPDATE Sales.SalesOrderDetail
    SET UnitPrice = @UnitPrice,
        OrderQty = @Quantity, 
    WHERE SalesOrderID = @OrderID
      


---3.Create a procedure GetOrderDetails that takes OrderID as 
---input parameter and returns all the records for that OrderID. If no records are
---found in Order Details table, then it should print the line: "The OrderID XXXX does
---not exits", where XXX should be the OrderlD entered by user and the procedure should 
---RETURN the value 1.

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if OrderID exists
    IF EXISTS (SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID)
    BEGIN
        -- Return all records for the OrderID
        SELECT * FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID;
    END
    ELSE
    BEGIN
        -- Print message and return 1 if no records found
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist.';
        RETURN 1;
    END
END






/*-- Task 1. You are given a table, Projects, containing three columns: Task ID, Start Date and End Date. It is guaranteed that the difference between the
--End Date and the Start Date is equal to 1 day for each row in the table,
ColumnType
Task ID     Integer
Start Date  Date
End Date    Date
*/
Create Database Assignment_C;
Use Assignment_C;

Create Table Projects (
Task_ID int primary key,
[Start_Date] Date Not Null,
End_Date  Date Not Null

) 

insert into Projects values ( 1, '2015-10-01' , '2015-10-02');
insert into Projects values ( 2, '2015-10-02' , '2015-10-03');
insert into Projects values ( 3, '2015-10-03' , '2015-10-04');
insert into Projects values ( 4, '2015-10-13' , '2015-10-14');
insert into Projects values ( 5, '2015-10-14' , '2015-10-15');
insert into Projects values ( 6, '2015-10-28' , '2015-10-29');
insert into Projects values ( 7, '2015-10-30' , '2015-10-31');


select * from Projects;

/*Task 1 A ( If the End Date of the tasks are consecutive, then they are part of the same project. Samantha is interested in finding the total number
of different projects completed. )*/

WITH ProjectMarkers AS (
    SELECT 
        Task_ID,
        End_Date,
        LAG(End_Date) OVER (ORDER BY End_Date) AS Prev_End_Date,
        CASE 
            WHEN End_Date = DATEADD(day, 1, LAG(End_Date) OVER (ORDER BY End_Date)) THEN 0
            ELSE 1
        END AS Is_New_Project
    FROM Projects
),
ProjectGroups AS (
    SELECT 
        Task_ID,
        End_Date,
        SUM(Is_New_Project) OVER (ORDER BY End_Date) AS Project_Group
    FROM ProjectMarkers
)
SELECT COUNT(DISTINCT Project_Group) AS Total_Projects
FROM ProjectGroups;



/*Task 2 B (Write a query to output the start and end dates of projects listed by the number of days it took to complete the project 
in ascending order. If there is more than one project that have the same number of completion days, then order by the start date of the project.*/
  WITH ProjectMarkers AS (
    SELECT 
        Task_ID,
        Start_Date,
        End_Date,
        LAG(End_Date) OVER (ORDER BY End_Date) AS Prev_End_Date,
        CASE 
            WHEN End_Date = DATEADD(day, 1, LAG(End_Date) OVER (ORDER BY End_Date)) THEN 0
            ELSE 1
        END AS Is_New_Project
    FROM Projects
),
GroupedProjects AS (
    SELECT 
        Task_ID,
        Start_Date,
        End_Date,
        SUM(Is_New_Project) OVER (ORDER BY End_Date) AS Project_Group
    FROM ProjectMarkers
),
ProjectDates AS (
    SELECT 
        Project_Group,
        MIN(Start_Date) AS Project_Start_Date,
        MAX(End_Date) AS Project_End_Date,
        DATEDIFF(day, MIN(Start_Date), MAX(End_Date)) + 1 AS Duration_Days
    FROM GroupedProjects
    GROUP BY Project_Group
)
SELECT 
    Project_Start_Date, 
    Project_End_Date, 
    Duration_Days
FROM ProjectDates
ORDER BY Duration_Days, Project_Start_Date;



/*Task 2 You are given three tables : Students , Friends and Packages . Students contains two
column : ID and Name , Friends contains two Columns : ID and friend_ID(ID of the ONLY Best Friend)
Packages contains two column : ID and Sallary (Offered salary in $ thousands per month).
*/

--student
create table Students (
ID int primary key,
Name nvarchar(50) not null
);

--Friends
create table Friends(
ID int primary key,
Friends_ID int not null,
Foreign key ( Friends_ID ) references Students(ID)

)

--packages
create table Packages (
Sal_ID int ,
Salary Float not null,
Foreign key ( Sal_ID  ) references Students(ID)

) 

Drop table Packages
insert into Students values
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet'); 

insert into Friends values
(1, 2),
(2, 3),
(3, 4),
(4, 1); 

insert into Packages values
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12); 

select * from Students;
select * from Friends;
select * from Packages;

---Tack 2 A : names of students whose friends got higher salary than them. names with
---order by salary amount offered to best friends with no two students with same salary
SELECT s.Name AS StudentName, s_salary.Salary AS StudentSalary, f_salary.Salary AS FriendSalary
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages s_salary ON s.ID = s_salary.Sal_ID
JOIN Packages f_salary ON f.Friends_ID = f_salary.Sal_ID
WHERE f_salary.Salary > s_salary.Salary
ORDER BY f_salary.Salary;

/*Task 3 : Ypu are given a table , functions, containing two columns : X and Y*/

create table Functions (
X int not null,
Y int not null
)

Insert into Functions  values
(20 , 20),
(20,20),
(20,21),
(23,22),
(22,23),
(21,20);
--(X1,Y1) and (X2,Y2) --- X1=Y2,X2=Y1
select Distinct f1.X as X1,f1.Y as Y1 from Functions f1
join Functions  f2 ON f1.X=f2.Y AND f1.Y = f2.X
where f1.X<=f1.Y;


/*Task 4 : Samantha interviews many candidates from different colleges using coding challenges and contests
write a query to print contest_id , hacker_id , name and the sums of total_submissions, total_accepted_submissions
,total views and total_unique_views for each contest sorted by contest_id. Exclude the contest from
the result if all four sums are.*/

-- contests
create table Contests (
contest_id int primary key,
hacker_id int not null,
[Name] nvarchar(100) not null
)

insert into Contests values 
(66406 , 17973 , 'Rose'),
(66556 , 79153 , 'Angela'),
(94828 , 80275 , 'Frank');

select * from Contests;

--colleges
create table Colleges (
college_id int primary key,
contest_id int,
Foreign key (contest_id) references Contests (contest_id)
)

insert into Colleges values 
(11219, 66406),
(32473, 66556),
(56685, 94828);

select * from Colleges;

--challenegs
create table Challenges (
Challenge_id int primary key,
college_id int not null,
Foreign key (college_id) references Colleges (college_id)
)

insert into Challenges values
(18765, 11219),
(47127, 11219),
(60292, 32473),
(72974, 56685);

insert into Challenges values
(75516, 56685)
select * from Challenges;

--view_stats
CREATE TABLE View_Stats (
    Challenge_id1 INT NOT NULL,
    total_views INT NOT NULL,
    total_unique_views INT NOT NULL,
    FOREIGN KEY (Challenge_id1) REFERENCES Challenges (Challenge_id)
);

Drop table View_Stats;

INSERT INTO View_Stats VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);

create table Submission_Stats (
Challenge_id2 int NOT NULL,
total_submissions int NOT NULL,
total_accepted_submissions int NOT NULL,
FOREIGN KEY (Challenge_id2) REFERENCES Challenges (Challenge_id)
);

Drop  table Submission_Stats;


insert into Submission_Stats  values
(75516 , 34 , 12 ),
(47127 , 27 , 10 ),
(47127 , 56 , 18 ),
(75516 , 74 , 12 ),
(75516 , 83 , 8 ),
(72974 , 68 , 24 ),
(72974 , 82 , 14 ),
(47127 , 28 , 11 );

select * from Submission_Stats ;

---Task 4 a) 

SELECT 
    c.contest_id, 
    c.hacker_id, 
    c.[Name],
    COALESCE(SUM(ss.total_submissions), 0) AS sum_total_submissions,
    COALESCE(SUM(ss.total_accepted_submissions), 0) AS sum_total_accepted_submissions,
    COALESCE(SUM(vs.total_views), 0) AS sum_total_views,
    COALESCE(SUM(vs.total_unique_views), 0) AS sum_total_unique_views
FROM 
    Contests c
    JOIN Colleges co ON c.contest_id = co.contest_id
    JOIN Challenges ch ON co.college_id = ch.college_id
    LEFT JOIN View_Stats vs ON ch.Challenge_id = vs.Challenge_id1
    LEFT JOIN Submission_Stats ss ON ch.Challenge_id = ss.Challenge_id2
GROUP BY 
    c.contest_id, c.hacker_id, c.[Name]
ORDER BY 
    c.contest_id;


	--- task 5 : 
/*
	*/

create table Hackers(
hacker_id int primary key,
[Name] nvarchar(50) not null
)

create table Submissions(
submission_date Date not null,
submission_id int not null,
hacker_id1 int not null,
score int not null,
Foreign key (hacker_id1) references Hackers(hacker_id)
	)

	insert into Hackers values 
	(15758,'Rose'),
	(20703,'Angela'),
	(36396,'Frank'),
	(38289,'Patrick'),
	(44065,'Lisa'),
	(53473,'Kimberly'),
	(62529,'Bonnie'),
	(79722,'Michael');

	insert into Submissions values
	('2016-03-01',8494,20703,0),
	('2016-03-01',22403,53473,15),
	('2016-03-01',23965,79722,60),
	('2016-03-01',30173,36396,70),
	('2016-03-02',34928,20703,0),
	('2016-03-02',38740,15758,60),
	('2016-03-02',42769,79722,25),
	('2016-03-02',44364,79722,60),
	('2016-03-03',45440,20703,0),
	('2016-03-03',49050,36396,70),
	('2016-03-03',50273,79722,5),
	('2016-03-04',50344,20703,0),
	('2016-03-04',51360,44065,90),
	('2016-03-04',54404,53473,65),
	('2016-03-04',61533,79722,45),
	('2016-03-05',72852,20703,0),
	('2016-03-05',74546,38289,0),
	('2016-03-05',76487,62529,0),
	('2016-03-05',82439,36396,10),
	('2016-03-05',90006,36396,40),
	('2016-03-06',90404,20703,0);
	
	select * from Hackers;
	select * from Submissions;


	--Task 6 
	create table Station (
	ID int primary key ,
	City nvarchar(50) not null,
	[State] nvarchar(50) not null,
	Lat_N int not null,
	Long_W int not null
	)

	--Task 7
	-- Create a temporary table to store prime numbers
DECLARE @PrimeNumbers VARCHAR(MAX) = ''; -- Variable to store prime numbers

DECLARE @num int = 2; -- Start checking from number 2

WHILE (@num <= 1000)
BEGIN
    DECLARE @is_prime bit = 1; -- Assume @num is prime initially
    
    -- Check for prime
    DECLARE @divisor int = 2;
    WHILE (@divisor <= SQRT(@num))
    BEGIN
        IF (@num % @divisor = 0)
        BEGIN
            SET @is_prime = 0; -- Not a prime number
            BREAK;
        END
        SET @divisor = @divisor + 1;
    END

    -- If @is_prime is still 1, @num is prime
    IF (@is_prime = 1)
    BEGIN
        SET @PrimeNumbers = @PrimeNumbers + CAST(@num AS VARCHAR) + ' ';
    END

    SET @num = @num + 1;
END

-- Trim trailing space and print the result
SELECT TRIM(RTRIM(@PrimeNumbers)) AS PrimeNumbers;

--Task 8
create table OCCUPATIONS(
ID int primary key,
[Name] nvarchar(50) not null,
Occupation nvarchar(50) not null

);


insert into OCCUPATIONS
values
(1,'Samantha','Doctor'),
(2,'Julia','Actor'),
(3,'Maria','Actor'),
(4,'Meera','Singer'),
(5,'Ashely','Professor'),
(6,'Ketty','Professor'),
(7,'Christeen','Professor'),
(8,'Jane','Actor'),
(9,'Jenny','Doctor'),
(10,'Priya','Singer');

select * from OCCUPATIONS o
group by o.Occupation; 

WITH RankedOccupations AS (
    SELECT 
        Occupation,
        [Name],
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY [Name]) AS rn
    FROM 
        OCCUPATIONS
)

SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN [Name] END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN [Name] END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN [Name] END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN [Name] END) AS Actor
FROM
    RankedOccupations
GROUP BY
    rn
ORDER BY
    rn;

	--Task 9
Create table BST (
N int ,
P int );

insert into BST values
(1,2),
(3,2),
(6,8),
(9,8),
(2,5),
(8,5),
(5,null);

-- Assuming the BST table is already created and populated with data

-- Inner Nodes
SELECT DISTINCT N AS Inner_Node
FROM BST
WHERE N IN (SELECT DISTINCT P  FROM BST WHERE P IS NOT NULL);

-- Leaf Nodes
SELECT Distinct N AS Leaf_Node
FROM BST
WHERE N NOT IN (SELECT P FROM BST WHERE P IS NOT NULL);

-- Root Node
SELECT Distinct N AS Root_Node
FROM BST
WHERE P IS NULL;

	
--Task 10
/*Company */
Create table Company (
company_code nvarchar(50) primary key,
founder nvarchar(50) not null
);

/* Lead_manager*/
create table Lead_Manager(
lead_manager_code nvarchar(50) primary key,
company_code1 nvarchar(50),
Foreign key (company_code1) references Company(company_code)
);

/*Senior_Manager*/
create table Senior_Manager(
senior_manager_code nvarchar(50) primary key,
lead_manager_code1 nvarchar(50) ,
company_code2 nvarchar(50),
Foreign key (company_code2) references Company(company_code),
Foreign key (lead_manager_code1) references Lead_Manager(lead_manager_code)
)

/* Manager */
create table Manager(
manager_Code nvarchar(50) primary key,
senior_manager_code1 nvarchar(50) ,
lead_manager_code2 nvarchar(50),
company_code3 nvarchar(50),
Foreign key (company_code3) references Company(company_code),
Foreign key (lead_manager_code2) references Lead_Manager(lead_manager_code),
Foreign key (senior_manager_code1) references Senior_Manager(senior_manager_code)
)

/* Employee*/
create table employee (
employee_code nvarchar(50) primary key,
manager_Code1 nvarchar(50) ,
senior_manager_code2 nvarchar(50) ,
lead_manager_code3 nvarchar(50),
company_code4 nvarchar(50),
Foreign key (company_code4) references Company(company_code),
Foreign key (lead_manager_code3) references Lead_Manager(lead_manager_code),
Foreign key (senior_manager_code2) references Senior_Manager(senior_manager_code),
Foreign key (manager_Code1) references Manager(manager_Code)
)

insert into Company values 
('C1','Monik'),('C2','Samantha');

insert into Lead_Manager values
('LM1','C1'),('LM2','C2');

INSERT INTO Senior_Manager VALUES
('SM1','LM1','C1'),('SM2','LM1','C1'),('SM3','LM2','C2');

INSERT INTO Manager VALUES
('M1','SM1','LM1','C1'),
('M2','SM3','LM2','C2'),
('M3','SM3','LM2','C2');

INSERT INTO employee VALUES
('E1','M1','SM1','LM1','C1'),
('E2','M1','SM1','LM1','C1'),
('E3','M2','SM3','LM2','C2'),
('E4','M3','SM3','LM2','C2');

SELECT * FROM Company c;
SELECT * FROM Lead_Manager lm;
SELECT * FROM Senior_Manager sm;
SELECT * FROM Manager m;
SELECT * FROM employee e;

SELECT
    c.company_code,
	c.founder ,
    COUNT(DISTINCT lm.lead_manager_code) AS Lead_Manager_no,
    COUNT(DISTINCT sm.senior_manager_code) AS Senior_man_no,
    COUNT(DISTINCT m.manager_Code) AS Managerno,
    COUNT(DISTINCT e.employee_code) AS Empl_no
FROM
    company c
LEFT JOIN
    Lead_Manager lm ON c.company_code = lm.company_code1
LEFT JOIN
    Senior_Manager sm ON lm.lead_manager_code = sm.lead_manager_code1
LEFT JOIN
    Manager m ON sm.senior_manager_code = m.senior_manager_code1
LEFT JOIN
    employee e ON m.manager_Code = e.manager_Code1
GROUP BY
    c.company_code,c.founder
ORDER BY
    c.company_code;

	
	--Task 11 
	/* DONE - 1 st que */

	--Task 12
	CREATE TABLE Job_Costs (
    Job_Family VARCHAR(50),
    Location VARCHAR(50),
    Cost DECIMAL(10, 2)
);

INSERT INTO Job_Costs (Job_Family, Location, Cost)
VALUES
    ('Engineering', 'India', 5000.00),
    ('Engineering', 'International', 3000.00),
    ('Sales', 'India', 2000.00),
    ('Sales', 'International', 4000.00);

	SELECT
    Job_Family,
    SUM(CASE WHEN Location = 'India' THEN Cost ELSE 0 END) AS Cost_India,
    SUM(CASE WHEN Location = 'International' THEN Cost ELSE 0 END) AS Cost_International,
    ROUND((SUM(CASE WHEN Location = 'India' THEN Cost ELSE 0 END) / NULLIF(SUM(Cost), 0)) * 100, 2) AS Percentage_India,
    ROUND((SUM(CASE WHEN Location = 'International' THEN Cost ELSE 0 END) / NULLIF(SUM(Cost), 0)) * 100, 2) AS Percentage_International
FROM
    Job_Costs
GROUP BY
    Job_Family;


	--task 13 find ratio of cost and revenue of a BU montrh on month
	CREATE TABLE BU_Cost_Revenue (
    BU VARCHAR(50),
    Month VARCHAR(50),
    Cost DECIMAL(10, 2),
    Revenue DECIMAL(10, 2)
);

-- Populate sample data
INSERT INTO BU_Cost_Revenue (BU, Month, Cost, Revenue)
VALUES
    ('BU1', 'January', 5000.00, 10000.00),
    ('BU1', 'February', 6000.00, 12000.00),
    ('BU2', 'January', 4000.00, 8000.00),
    ('BU2', 'February', 4500.00, 9000.00);

	SELECT
    BU,
    Month,
    Cost,
    Revenue,
    ROUND((Cost / NULLIF(Revenue, 0)), 2) AS Cost_Revenue_Ratio
FROM
    BU_Cost_Revenue;


	--TASK 14

	CREATE TABLE Employee_Stats (
    Sub_Band VARCHAR(50),
    Headcount INT
);

-- Populate sample data
INSERT INTO Employee_Stats (Sub_Band, Headcount)
VALUES
    ('Sub Band A', 50),
    ('Sub Band B', 75),
    ('Sub Band C', 100);

	SELECT
    Sub_Band,
    Headcount,
    ROUND(Headcount / SUM(Headcount) OVER () * 100, 2) AS Percentage
FROM
    Employee_Stats;

	--TASK 15
	CREATE TABLE Employees (
    Employee_ID INT,
    Name VARCHAR(100),
    Salary DECIMAL(10, 2)
);

-- Populate sample data
INSERT INTO Employees (Employee_ID, Name, Salary)
VALUES
    (1, 'John Doe', 60000.00),
    (2, 'Jane Smith', 55000.00),
    (3, 'Michael Johnson', 58000.00),
    (4, 'Emily Brown', 62000.00),
    (5, 'William Davis', 57000.00);

	SELECT TOP 5 *
FROM Employees
ORDER BY Salary DESC;


--TASK 16
CREATE TABLE Swap_Table (
    Column1 INT,
    Column2 INT
);

-- Populate sample data
INSERT INTO Swap_Table (Column1, Column2)
VALUES
    (10, 20);

UPDATE Swap_Table
SET
    Column1 = Column1 + Column2,
    Column2 = Column1 - Column2,
    Column1 = Column1 - Column2;


	--TASK 17
	-- Create a Login
CREATE LOGIN YourLogin WITH PASSWORD = 'YourPassword';

-- Create a User mapped to the Login
CREATE USER YourUser FOR LOGIN YourLogin;

-- Grant DB_owner permission to the User
ALTER ROLE db_owner ADD MEMBER YourUser;


--TASK 18
CREATE TABLE Employee_Costs (
    Employee_ID INT,
    Month VARCHAR(50),
    BU VARCHAR(50),
    Cost DECIMAL(10, 2)
);

-- Populate sample data
INSERT INTO Employee_Costs (Employee_ID, Month, BU, Cost)
VALUES
    (1, 'January', 'BU1', 5000.00),
    (2, 'January', 'BU1', 6000.00),
    (3, 'January', 'BU2', 4000.00),
    (4, 'January', 'BU2', 4500.00),
    (1, 'February', 'BU1', 10000.00),
    (2, 'February', 'BU1', 12000.00),
    (3, 'February', 'BU2', 8000.00),
    (4, 'February', 'BU2', 9000.00);

SELECT
    BU,
    Month,
    AVG(Cost) AS Average_Cost
FROM
    Employee_Costs
GROUP BY
    BU, Month;


	--TASK 19
	SELECT 
    CEILING(AVG(Salary)) - CEILING(AVG(CASE WHEN Salary <> 0 THEN Salary ELSE NULL END)) AS Error_Amount
FROM 
    Employees;


	---TASK 20
	-- Create Source_Table (example schema)
CREATE TABLE Source_Table (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Age INT
);

-- Populate Source_Table with sample data
INSERT INTO Source_Table (ID, Name, Age)
VALUES
    (1, 'John', 30),
    (2, 'Jane', 28),
    (3, 'Michael', 35);

-- Create Destination_Table (with the same schema as Source_Table)
CREATE TABLE Destination_Table (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Age INT
);

	INSERT INTO Destination_Table (ID, Name, Age)
SELECT ID, Name, Age
FROM Source_Table;

SELECT * FROM Destination_Table;
