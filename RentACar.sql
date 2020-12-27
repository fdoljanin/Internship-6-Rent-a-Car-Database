CREATE DATABASE RentACar;
----- 
USE RentACar;

CREATE TABLE Employees(
	EmployeeId int IDENTITY(1,1) PRIMARY KEY,
	FirstName varchar(100) NOT NULL,
	LastName varchar(100) NOT NULL,
	Pin varchar(11) CHECK(ISNUMERIC(Pin)=1) UNIQUE,
	Salary int CHECK(Salary>0)
);

CREATE TABLE PricingClasses(
	PricingClassId int IDENTITY(1,1) PRIMARY KEY,
	ClassName varchar(100) NOT NULL UNIQUE,
	WinterPrice int CHECK(WinterPrice>0) NOT NULL,
	SummerPrice int CHECK(SummerPrice>0) NOT NULL
);

CREATE TABLE Vehicles(
	VehicleId int IDENTITY(1,1) PRIMARY KEY,
	Brand varchar(100) NOT NULL,
	Model varchar(100) NOT NULL,
	Type varchar(100) CHECK(Type IN ('Car','Van','Scooter')) NOT NULL,
	Color varchar(30) NOT NULL,
	PricingClassId int FOREIGN KEY REFERENCES PricingClasses(PricingClassId) NOT NULL,
	Mileage int CHECK(Mileage>=0) NOT NULL,
	LastRegistration datetime2
);

CREATE TABLE Registrations(
	RegistrationId int IDENTITY(1,1) NOT NULL,
	VehicleId int FOREIGN KEY REFERENCES Vehicles(VehicleId) NOT NULL,
	RegisterDate datetime2 NOT NULL,
);

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
GO

CREATE TABLE RentPurchases(
	RentId int IDENTITY(1,1) PRIMARY KEY,
	VehicleId int FOREIGN KEY REFERENCES Vehicles(VehicleId) NOT NULL,
	EmployeeId int FOREIGN KEY REFERENCES Employees(EmployeeId) NOT NULL,
	CustomerFirstName varchar(100) NOT NULL,
	CustomerLastName varchar(100) NOT NULL,
	CustomerPin varchar(11) CHECK(ISNUMERIC(CustomerPin)=1) NOT NULL,
	CustomerBirth datetime2 CHECK(DATEDIFF(yy, CustomerBirth, GETDATE()) >= 18) NOT NULL, 
	CustomerLicense varchar(8) CHECK(ISNUMERIC(CustomerLicense)=1) NOT NULL,
	CustomerCreditCard varchar(16) CHECK(ISNUMERIC(CustomerCreditCard)=1) NOT NULL,
	TransactionDate datetime2 NOT NULL,
	StartTime datetime2 NOT NULL,
	Duration float(1) NOT NULL CHECK(Duration>=1),
	EndTime AS DATEADD(hh, Duration*24, StartTime) PERSISTED
);

GO
CREATE FUNCTION CheckIsAvailable(@VehicleId AS int, @StartTime as datetime2, @EndTime as datetime2)
RETURNS bit
AS
BEGIN
	IF (SELECT COUNT(RentId) FROM RentPurchases WHERE VehicleId = @VehicleId AND 
	NOT (StartTime > @EndTime OR @StartTime > EndTime)) = 1
		RETURN 1;
	RETURN 0;
END
GO

ALTER TABLE RentPurchases
ADD CONSTRAINT CheckAvailability
CHECK([dbo].CheckIsAvailable(VehicleId, StartTime, EndTime)=1);

GO
CREATE FUNCTION  GetPrice(@StartTime as datetime2, @Duration as float, @SummerPrice as int, @WinterPrice as int)
RETURNS int
AS
BEGIN
	DECLARE @Price int = 0;
	WHILE @Duration>0
	BEGIN
		IF 32*MONTH(@StartTime) + DAY(@StartTime) BETWEEN 32*3+1 AND 32*10+1
		BEGIN
			SET @Price += 0.5*@SummerPrice;
		END
		ELSE 
		BEGIN
			SET @Price += 0.5*@WinterPrice;
		END
		SET @StartTime = DATEADD(hh, 12, @StartTime);
		SET @Duration-=0.5;
	END
RETURN @Price
END
GO

------

INSERT INTO Employees(FirstName, LastName, Pin, Salary) VALUES
('Ann', 'Cooper', '16633000209', 6260),
('Brenda', 'Allen', '55631356155', 5295),
('Andrea', 'Rogers', '77353576180', 6533),
('Judith', 'Wood', '14574428324', 6049),
('Chris', 'Sanders', '06294408090', 5326),
('Raymond', 'Anderson', '77052780185', 7630),
('Carl', 'Diaz', '65942177266', 7977);

INSERT INTO PricingClasses(ClassName, WinterPrice, SummerPrice) VALUES 
('Coupe', 130, 170),
('Minivan', 100, 160),
('Hatchback', 150, 200),
('SUV', 280, 360),
('Combi', 500, 700),
('Moped', 50, 80);

INSERT INTO Vehicles(Brand, Model, Type, Color, PricingClassId, Mileage) VALUES 
('BMW', '840', 'Car', 'Grey', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Coupe'), 2650),
('BMW', 'M4', 'Car', 'Green', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Coupe'), 2013),
('Toyota', 'Sienna', 'Car', 'Grey', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Minivan'), 683),
('Chevrolet', 'Corvette', 'Car', 'Orange', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Coupe'), 1117),
('Honda', 'Odyssey', 'Car', 'Red', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Minivan'), 2044),
('Nissan', 'Quest', 'Car', 'Grey', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Minivan'), 1774),
('Wolkswagen', 'Golf', 'Car', 'Blue', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Hatchback'), 2343),
('Ford', 'Focus', 'Car', 'Red', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Hatchback'), 1001),
('Mazda', '3', 'Car', 'Red', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Hatchback'), 2111),
('Skoda', 'Octavia', 'Car', 'Blue', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Hatchback'), 10774),
('Wolkswagen', 'GTI', 'Car', 'Black', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Hatchback'), 4455),
('Skoda', 'Fabia', 'Car', 'Red', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Hatchback'), 1434),
('Wolkswagen', 'Touareg', 'Car', 'Green', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'SUV'), 2040),
('Mazda', 'MX-30', 'Car', 'Green', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'SUV'), 9384),
('Ford', 'Transit', 'Van', 'Black', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Combi'), 3235),
('Renault', 'Trafic', 'Van', 'Grey', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Combi'), 2968),
('Suzuki', 'AY50', 'Scooter', 'Yellow', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Moped'), 1784),
('Piaggio', 'Liberty', 'Scooter', 'Grey', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Moped'), 1555),
('Piaggio', 'Typhoon', 'Scooter', 'Black', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Moped'), 1246),
('Citroen', 'Berlingo', 'Van', 'Black', (SELECT PricingClassId FROM PricingClasses WHERE ClassName = 'Combi'), 8246);


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

INSERT INTO RentPurchases (VehicleId, EmployeeId, CustomerFirstName, CustomerLastName, CustomerPin, CustomerBirth, CustomerLicense, CustomerCreditCard, TransactionDate, StartTime, Duration) VALUES
(5,2,'Richard','Wilson','07649446464','1977-5-4','48066710', '8148489434405333', '2018-4-3', '2018-4-5 19:00', 1.5),
(2,3,'Anne','Garcia','35710815006','1991-8-23','36218490', '4124471951492068', '2018-4-4', '2018-4-6 22:00', 4),
(1,5,'Aaron','Howard','56558445316','1988-1-8','46548109', '3099910042133648', '2018-5-3', '2018-5-7 12:00', 2.5),
(6,7,'Kathy','Ross','06741541992','1954-10-14','99042478', '1926352340788839', '2018-5-6', '2018-5-7 13:00', 1),
(5,3,'Fred','Bell','45432684014','1992-9-1','94966688', '8372851956355999', '2018-9-30', '2018-9-30 10:00', 4),
(12,3,'Kathy','Ross','06741541992','1954-10-14','99042478', '1926352340788839', '2018-9-30', '2018-9-30 10:00', 3.5),
(12,4,'Kathy','Ross','06741541992','1954-10-14','99042478', '1926352340788839', '2018-10-28', '2018-10-30 11:00', 4.5),
(10,4,'Yudy Young','Wilson','46216788481','2001-2-28','54486082', '6827049039478492', '2019-2-27', '2019-2-28 18:00', 22),
(17,5,'Timothy','Hughes','48718974899','1995-8-5','80459874', '0465091344030874', '2019-8-1', '2019-8-5 14:00', 32),
(18,6,'Jeremy','Smith','38333296479','1985-4-19','20763908', '3957665602652717', '2020-1-1', '2020-1-2 9:00', 1.5),
(19,6,'Jeremy','Smith','38333296479','1985-4-19','20763908', '3957665602652717', '2020-1-27', '2020-2-1 8:00', 2.5),
(20,3,'Jeremy','Smith','38333296479','1985-4-19','20763908', '3957665602652717', '2020-2-20', '2020-2-27 8:00', 9.5),
(14,3,'Aaron','Howard','56558445316','1988-1-8','46548109', '2063410332126485', '2020-2-22', '2020-2-27 11:00', 3.5),
(5,2,'Benjamin','Johnson','49258947076','1959-12-2','41895417', '1811791766412913', '2020-2-26', '2020-2-27 12:00', 4),
(11,4,'Yudy','Wilson','46216788481','2001-2-28','54486082', '6827049039478492', '2020-2-27', '2020-2-29 18:00', 1),
(4,3,'Anne','Garcia','35710815006','1991-8-23','36218490', '4124471951492068', '2020-8-28', '2020-8-29 18:00', 3),
(15,4,'Yudy','Wilson','46216788481','2001-2-28','54486082', '6827049039478492', '2020-10-27', '2020-10-29 19:30', 2.5),
(2,1,'Aaron','Howard','56558445316','1988-1-8','46548109', '3099910042133648', '2020-10-28', '2020-10-29 21:00', 2),
(3,1,'Tina','Long','81027056810','1989-11-26','66132530', '8785793173508860', '2020-12-21', '2020-12-24 15:00', 10),
(16,5,'Fred','Bell','45432684014','1992-9-1','94966688', '8372851956355999', '2020-12-28', '2020-12-30 12:00', 4.5),
(13,4,'Kathy','Ross','06741541992','1954-10-14','99042478', '1926352340788839', '2020-12-28', '2020-12-29 11:00', 5),
(18,7,'Kathy','Ross','06741541992','1954-10-14','99042478', '1926352340788839', '2021-2-25', '2021-2-26 11:00', 16),
(20,3,'Tina','Long','81027056810','1989-11-26','66132530', '8785793173508860', '2021-3-21', '2021-3-24 15:00', 4);

SELECT * FROM Vehicles WHERE (DATEDIFF(yy, LastRegistration, GETDATE()) > 0);

SELECT * FROM Vehicles WHERE LastRegistration BETWEEN DATEADD(YEAR,-1, GETDATE()) AND DATEADD(MONTH,-11,GETDATE());

SELECT Type, COUNT(VehicleId) AS NumberOfVehicles FROM Vehicles
GROUP BY Type
ORDER BY NumberOfVehicles;

SELECT TOP 5 emp.FirstName, emp.LastName, rp.* FROM RentPurchases rp
JOIN Employees emp ON emp.EmployeeId = rp.EmployeeId
WHERE rp.EmployeeId = 3
ORDER BY TransactionDate DESC;

SELECT rp.StartTime, rp.Duration, pc.SummerPrice, pc.WinterPrice,
[dbo].GetPrice(rp.StartTime, rp.Duration, pc.SummerPrice, pc.WinterPrice) AS Price 
FROM RentPurchases rp
JOIN Vehicles v ON v.VehicleId = rp.VehicleId
JOIN PricingClasses pc ON pc.PricingClassId = v.PricingClassId
WHERE rp.RentId = 3;

SELECT MIN(CustomerFirstName) AS FirstName, MIN(CustomerLastName) AS LastName, MIN(CustomerBirth) AS Birth,
MIN(CustomerPin) AS Pin, MIN(CustomerLicense) AS License, MIN(CustomerCreditCard) AS CreditCard  FROM RentPurchases
GROUP BY CustomerPin;

SELECT MIN(FirstName) AS FirstName, MIN(LastName) AS LastName, MAX(TransactionDate) AS LastTransaction FROM RentPurchases rp
JOIN Employees e ON rp.EmployeeId = e.EmployeeId
GROUP BY rp.EmployeeId;

SELECT MIN(Brand) AS Brand, COUNT(VehicleId) AS NumberOfVehicles FROM Vehicles 
GROUP BY Brand 
ORDER BY NumberOfVehicles;

SELECT rp.*,
[dbo].GetPrice(rp.StartTime, rp.Duration, pc.SummerPrice, pc.WinterPrice) AS Price
INTO RentPurchasesArchive
FROM RentPurchases rp
JOIN Vehicles v ON v.VehicleId = rp.VehicleId
JOIN PricingClasses pc ON pc.PricingClassId = v.PricingClassId
WHERE DATEADD(hh, rp.Duration*24, rp.StartTime) < GETDATE();
DELETE FROM RentPurchases WHERE DATEADD(hh, Duration*24, RentPurchases.StartTime) < GETDATE();

WITH rp AS (
SELECT TransactionDate FROM RentPurchases
UNION ALL
SELECT TransactionDate FROM RentPurchasesArchive)
SELECT MONTH(TransactionDate) AS Month, COUNT(TransactionDate) AS RentPurchasesCount FROM rp
WHERE YEAR(TransactionDate) = 2020
GROUP BY MONTH(TransactionDate);

SELECT *, CASE
	WHEN LastRegistration <= DATEADD(MONTH,-11,GETDATE()) OR LastRegistration IS NULL THEN 'Treba registraciju'
	ELSE 'Ne treba registraciju'
	END AS NeedsRegistration
FROM Vehicles
WHERE Type = 'Car'
ORDER BY LastRegistration;

WITH rp AS (
SELECT VehicleId, Duration FROM RentPurchases 
UNION ALL
SELECT VehicleId, Duration FROM RentPurchasesArchive)
SELECT MIN(v.Type) AS Type, COUNT(rp.VehicleId) AS RentAboveAvgCount FROM Vehicles v
JOIN rp ON rp.VehicleId = v.VehicleId
WHERE Duration > (SELECT CAST(AVG(Duration) AS float) FROM rp)
GROUP BY v.Type;