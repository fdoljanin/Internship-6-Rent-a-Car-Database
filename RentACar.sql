CREATE DATABASE RentACar
--
USE RentACar

CREATE TABLE Employees(
	EmployeeId int IDENTITY(1,1) PRIMARY KEY,
	FirstName varchar(100) NOT NULL,
	LastName varchar(100) NOT NULL,
	Pin varchar(11) CHECK(ISNUMERIC(Pin)=1) UNIQUE,
	Wage int CHECK(Wage>0),
	Gender int CHECK(Gender IN (0,1,2,9)) NOT NULL,
	BirthYear datetime2 NOT NULL
)

CREATE TABLE PriceClasses(
	PriceClassId int IDENTITY(1,1) PRIMARY KEY,
	ClassName varchar(100) NOT NULL,
	WinterPrice int CHECK(WinterPrice>0) NOT NULL,
	SummerPrice int CHECK(SummerPrice>0) NOT NULL
)

CREATE TABLE Car(
	CarId int IDENTITY(1,1) PRIMARY KEY,
	Brand varchar(100) NOT NULL,
	Model varchar(100) NOT NULL,
	Type varchar(100) NOT NULL,
	Color varchar(30) NOT NULL,
	PriceClass int FOREIGN KEY REFERENCES PriceClasses(PriceClassId) NOT NULL,
	Mileage int CHECK(Mileage>=0),
	LastRegistration datetime2
)

CREATE TABLE Registrations(
	RegistrationId int IDENTITY(1,1) NOT NULL,
	CarId int FOREIGN KEY REFERENCES Car(CarId) NOT NULL,
	RegisterDate datetime2 NOT NULL,
	ExpireDate datetime2 NOT NULL
)

CREATE TABLE Rents(
	RentId int IDENTITY(1,1) PRIMARY KEY,
	CarId int FOREIGN KEY REFERENCES Car(CarId) NOT NULL,
	EmployeeId int FOREIGN KEY REFERENCES Employees(EmployeeId) NOT NULL,
	CustomerFirstName varchar(100) NOT NULL,
	CustomerLastName varchar(100) NOT NULL,
	CustomerPin varchar(11) CHECK(ISNUMERIC(CustomerPin)=1) NOT NULL,
	CustomerBirth datetime2 NOT NULL,
	CustomerLicense varchar(8) CHECK(ISNUMERIC(CustomerLicense)=1) NOT NULL,
	CustomerCreditCard varchar(16) CHECK(ISNUMERIC(CustomerCreditCard)=1) NOT NULL,
	StartTime datetime2 NOT NULL,
	EndTime datetime2 NOT NULL
)