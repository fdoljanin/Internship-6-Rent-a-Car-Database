CREATE DATABASE RentACar
--
USE RentACar

CREATE TABLE Employees(
	EmployeeId int IDENTITY(1,1) PRIMARY KEY,
	FirstName varchar(100) NOT NULL,
	LastName varchar(100) NOT NULL,
	Pin varchar(11) CHECK(ISNUMERIC(Pin)=1) UNIQUE,
	Salary int CHECK(Salary>0)
)

CREATE TABLE PriceClasses(
	PriceClassId int IDENTITY(1,1) PRIMARY KEY,
	ClassName varchar(100) NOT NULL UNIQUE,
	WinterPrice int CHECK(WinterPrice>0) NOT NULL,
	SummerPrice int CHECK(SummerPrice>0) NOT NULL
)

CREATE TABLE Vehicles(
	VehicleId int IDENTITY(1,1) PRIMARY KEY,
	Brand varchar(100) NOT NULL,
	Model varchar(100) NOT NULL,
	Type varchar(100) NOT NULL,
	Color varchar(30) NOT NULL,
	PriceClassId int FOREIGN KEY REFERENCES PriceClasses(PriceClassId) NOT NULL,
	Mileage int CHECK(Mileage>=0),
	LastRegistration datetime2
)

CREATE TABLE Registrations(
	RegistrationId int IDENTITY(1,1) NOT NULL,
	VehicleId int FOREIGN KEY REFERENCES Vehicles(VehicleId) NOT NULL,
	RegisterDate datetime2 NOT NULL,
)


GO
CREATE TRIGGER UpdateRegistrations
ON Registrations
AFTER INSERT
AS
BEGIN 
UPDATE Vehicles 
SET Vehicles.LastRegistration = (SELECT MAX(RegisterDate) FROM inserted WHERE inserted.VehicleId = Vehicles.VehicleId)
WHERE (SELECT MAX(RegisterDate) FROM inserted WHERE inserted.VehicleId = Vehicles.VehicleId) > Vehicles.LastRegistration 
OR Vehicles.LastRegistration IS NULL
END


CREATE TABLE Rents(
	RentId int IDENTITY(1,1) PRIMARY KEY,
	VehicleId int FOREIGN KEY REFERENCES Vehicles(VehicleId) NOT NULL,
	EmployeeId int FOREIGN KEY REFERENCES Employees(EmployeeId) NOT NULL,
	CustomerFirstName varchar(100) NOT NULL,
	CustomerLastName varchar(100) NOT NULL,
	CustomerPin varchar(11) CHECK(ISNUMERIC(CustomerPin)=1) NOT NULL,
	CustomerBirth datetime2 NOT NULL,
	CustomerLicense varchar(8) CHECK(ISNUMERIC(CustomerLicense)=1) NOT NULL,
	CustomerCreditCard varchar(16) CHECK(ISNUMERIC(CustomerCreditCard)=1) NOT NULL,
	TransactionDate datetime2 NOT NULL,
	StartTime datetime2 NOT NULL,
	EndTime datetime2 NOT NULL
)

INSERT INTO Employees(FirstName, LastName, Pin, Salary) VALUES
('Ann', 'Cooper', '16633000209', 6260),
('Brenda', 'Allen', '55631356155', 5295),
('Andrea', 'Rogers', '77353576180', 6533),
('Judith', 'Wood', '14574428324', 6049),
('Chris', 'Sanders', '06294408090', 5326),
('Raymond', 'Anderson', '77052780185', 7630),
('Carl', 'Diaz', '65942177266', 7977);

INSERT INTO PriceClasses(ClassName, WinterPrice, SummerPrice) VALUES 
('Coupe', 130, 170),
('Minivan', 230, 270),
('Hatchback', 330, 370),
('SUV', 430, 470),
('Combi', 540, 590),
('Moped', 110, 210);

INSERT INTO Vehicles(Brand, Model, Type, Color, PriceClassId, Mileage) VALUES 
('BMW', '840', 'Car', 'Grey', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Coupe'), 2650),
('BMW', 'M4', 'Car', 'Green', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Coupe'), 2013),
('Toyota', 'Sienna', 'Car', 'Grey', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Minivan'), 683),
('Chevrolet', 'Corvette', 'Car', 'Orange', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Coupe'), 1117),
('Honda', 'Odyssey', 'Car', 'Red', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Minivan'), 2044),
('Nissan', 'Quest', 'Car', 'Grey', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Minivan'), 1774),
('Wolkswagen', 'Golf', 'Car', 'Blue', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Hatchback'), 2343),
('Ford', 'Focus', 'Car', 'Red', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Hatchback'), 1001),
('Mazda', '3', 'Car', 'Red', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Hatchback'), 2111),
('Skoda', 'Octavia', 'Car', 'Blue', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Hatchback'), 10774),
('Wolkswagen', 'GTI', 'Car', 'Black', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Hatchback'), 4455),
('Skoda', 'Fabia', 'Car', 'Red', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Hatchback'), 1434),
('Wolkswagen', 'Touareg', 'Car', 'Green', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'SUV'), 2040),
('Mazda', 'MX-30', 'Car', 'Green', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'SUV'), 9384),
('Ford', 'Transit', 'Van', 'Black', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Combi'), 3235),
('Renault', 'Trafic', 'Van', 'Grey', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Combi'), 2968),
('Suzuki', 'AY50', 'Scooter', 'Yellow', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Moped'), 1784),
('Piaggio', 'Liberty', 'Scooter', 'Grey', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Moped'), 1555),
('Piaggio', 'Typhoon', 'Scooter', 'Black', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Moped'), 1246),
('Citroen', 'Berlingo', 'Van', 'Black', (SELECT PriceClassId FROM PriceClasses WHERE ClassName = 'Combi'), 8246);


INSERT INTO Registrations(VehicleId, RegisterDate) VALUES
(1, '2016-5-12'),
(1, '2017-5-13'),
(1, '2018-5-14'),
(2, '2020-7-20'),
(3, '2019-12-30'),
(4, '2018-4-11'),
(5, '2016-11-2'),
(5, '2018-3-4'),
(5, '2019-3-2'),
(5, '2020-3-1'),
(6, '2020-2-4'),
(7, '2019-1-2'),
(8, '2019-9-12'),
(9, '2020-8-1'),
(10, '2018-3-3'),
(10, '2019-3-10'),
(11, '2020-2-22'),
(12, '2019-10-2'),
(12, '2020-10-5'),
(13, '2019-12-29'),
(14, '2018-5-14'),
(15, '2016-10-10'),
(15, '2017-10-23'),
(15, '2018-11-1'),
(15, '2019-11-12'),
(16, '2020-5-4'),
(17, '2020-12-20'),
(18, '2019-5-3'),
(19, '2018-3-4'),
(19, '2019-2-5'),
(19, '2020-1-7'),
(20, '2020-5-4');

INSERT INTO Rents (VehicleId, EmployeeId, CustomerFirstName, CustomerLastName, CustomerPin, CustomerBirth, CustomerLicense, CustomerCreditCard, TransactionDate, StartTime, EndTime) VALUES
(5,2,'Richard','Wilson','07649446464','1977-5-4','48066710', '8148489434405333', '2018-4-3', '2018-4-5 18:00', '2018-4-6 17:00'),
(1,5,'Aaron','Howard','56558445316','1988-1-8','46548109', '3099910042133648', '2018-5-3', '2018-5-7 12:00', '2018-5-10 22:30'),
(6,7,'Kathy','Ross','06741541992','1954-10-14','99042478', '1926352340788839', '2018-5-6', '2018-5-7 13:00', '2018-5-11 14:00'),
(5,3,'Fred','Bell','45432684014','1992-9-1','94966688', '8372851956355999', '2018-9-30', '2018-9-30 10:00', '2018-10-2 22:00'),
(10,4,'Yudy Young','Wilson','46216788481','2001-2-28','54486082', '6827049039478492', '2019-2-27', '2019-2-28 18:00', '2019-3-2 18:00'),
(17,5,'Timothy','Hughes','48718974899','1995-8-5','80459874', '0465091344030874', '2019-8-1', '2019-8-5 14:00', '2019-8-5 21:00'),
(18,6,'Jeremy','Smith','38333296479','1985-4-19','20763908', '3957665602652717', '2020-1-1', '2020-1-2 9:00', '2020-1-3 10:00'),
(5,2,'Benjamin','Johnson','49258947076','1959-12-2','41895417', '1811791766412913', '2020-2-26', '2020-2-27 10:00', '2020-3-1 19:00'),
(4,3,'Anne','Garcia','35710815006','1991-8-23','36218490', '4124471951492068', '2020-10-28', '2020-10-29 18:00', '2020-10-30 10:00'),
(3,1,'Tina','Long','81027056810','1989-11-26','66132530', '8785793173508860', '2020-12-21', '2020-12-24 15:00', '2021-1-2 19:00');

SELECT * FROM Vehicles WHERE (DATEDIFF(yy, LastRegistration, GETDATE())>0);

SELECT * FROM Vehicles WHERE LastRegistration BETWEEN DATEADD(YEAR,-1, GETDATE()) AND DATEADD(MONTH,-11,GETDATE());

SELECT Type, COUNT(VehicleId) AS NumberOfVehicles FROM Vehicles
GROUP BY Type
ORDER BY NumberOfVehicles

SELECT TOP(5) emp.FirstName, emp.LastName, rts.* FROM Rents rts
INNER JOIN Employees emp ON emp.EmployeeId = rts.EmployeeId
WHERE rts.EmployeeId = 2
ORDER BY TransactionDate DESC


GO
CREATE FUNCTION GetPrice(@StartTime as datetime2, @EndTime as datetime2, @SummerPrice as int, @WinterPrice as int) --this turned super messy, I will use loop or smth later
RETURNS int
AS
BEGIN
DECLARE @StartTimeBack datetime = DATEADD(dd, -DATEPART(dayofyear, '2018-2-28'), @StartTime); 
DECLARE @EndTimeBack datetime = DATEADD(dd, -DATEPART(dayofyear, '2018-2-28'), @EndTime);
DECLARE @WinterStart datetime2 = DATEADD(dd, -DATEPART(dayofyear, '2018-2-28'), '2018-10-1');
DECLARE @StartDay int = DATEPART(dayofyear, @StartTimeBack);
DECLARE @EndDay int = DATEPART(dayofyear, @EndTimeBack);
DECLARE @SwitchDay int = DATEPART(dayofyear, @WinterStart);
DECLARE @WinterDays int = 0;
DECLARE @SummerDays int = 0;
DECLARE @Price int = 0;
DECLARE @Swapped BIT = 0;
IF (@StartDay>@EndDay)
BEGIN
	DECLARE @Temp int = @StartDay;
    SET @StartDay = @EndDay;
	SET @EndDay = @Temp;
	SET @Swapped = 1;
END 
IF @SwitchDay BETWEEN @StartDay AND @EndDay
	BEGIN
	SET @SummerDays =  @SwitchDay - @StartDay;
	SET @WinterDays = @EndDay - @SwitchDay;
	END
ELSE IF @StartDay <= @SwitchDay
	BEGIN
	SET @SummerDays = @EndDay - @StartDay;
	END
ELSE
	BEGIN
	SET @WinterDays = @EndDay-@StartDay;
	END
IF @Swapped=1
SET @Price = @SwitchDay * @SummerPrice + (365 - @SwitchDay)*@WinterPrice - @SummerDays * @SummerPrice - @WinterDays*@WinterPrice;
ELSE
SET @Price = @WinterDays*@WinterPrice + @SummerDays*@SummerPrice;
RETURN @Price;
END

GO

SELECT Rents.StartTime, Rents.EndTime, PriceClasses.SummerPrice, PriceClasses.WinterPrice,
[dbo].GetPrice(Rents.StartTime, Rents.EndTime, PriceClasses.SummerPrice, PriceClasses.WinterPrice) AS Price 
FROM Rents
JOIN Vehicles ON Rents.VehicleId = Vehicles.VehicleId
JOIN PriceClasses ON PriceClasses.PriceClassId = Vehicles.PriceClassId
WHERE Rents.RentId = 3

SELECT * FROM Rents 

SELECT MIN(CustomerFirstName) AS FirstName, MIN(CustomerLastName) AS LastName, MIN(CustomerBirth) AS Birth,
MIN(CustomerPin) AS Pin, MIN(CustomerLicense) AS License, MIN(CustomerCreditCard) AS CreditCard  FROM Rents
GROUP BY CustomerPin;

SELECT MIN(FirstName) AS FirstName, MIN(LastName) AS LastName, MAX(TransactionDate) AS LastTransaction FROM Rents
JOIN Employees ON Rents.EmployeeId = Employees.EmployeeId
GROUP BY Rents.EmployeeId;

SELECT MIN(Brand) AS Brand, COUNT(VehicleId) AS NumberOfVehicles FROM Vehicles 
GROUP BY Brand 
ORDER BY NumberOfVehicles;

SELECT Rents.*,
[dbo].GetPrice(Rents.StartTime, Rents.EndTime, PriceClasses.SummerPrice, PriceClasses.WinterPrice) AS Price
INTO RentsArchive
FROM Rents
JOIN Vehicles ON Rents.VehicleId = Vehicles.VehicleId
JOIN PriceClasses ON PriceClasses.PriceClassId = Vehicles.PriceClassId
WHERE Rents.EndTime < GETDATE();
DELETE FROM Rents WHERE EndTime < GETDATE();

SELECT DATEPART(mm, TransactionDate) AS Month, COUNT(RentId) AS RentsCount FROM Rents 
WHERE DATEPART(yy, TransactionDate)=2020
GROUP BY DATEPART(mm, TransactionDate)

SELECT *, CASE
	WHEN LastRegistration <= DATEADD(MONTH,-11,GETDATE()) THEN 'Treba registraciju'
	ELSE 'Ne treba registraciju'
	END AS NeedsRegistration
FROM Vehicles
ORDER BY LastRegistration;

SELECT MIN(Vehicles.Type) AS Type, COUNT(RentId) AS RentAboveAvgCount FROM Rents
JOIN Vehicles ON Rents.VehicleId = Vehicles.VehicleId
WHERE DATEDIFF(MI, Rents.StartTime, Rents.EndTime) > (SELECT CAST(AVG(DATEDIFF(MI, Rents.StartTime, Rents.EndTime)) AS float) FROM Rents)
GROUP BY Vehicles.Type