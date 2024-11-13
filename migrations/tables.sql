CREATE TABLE Business (
    BusinessID INT identity(1,1) primary key,
    BusinessName varchar(100) not null,
    Address varchar(100) not null,
    Phone varchar(20) not null,
    Email varchar(100) not null,
    BusinessStartTime TIME not null,
    BusinessEndTime TIME not null,
);

CREATE TABLE Slots (
    SlotID INT IDENTITY(1,1) PRIMARY KEY,
    SlotNO INT NOT NULL UNIQUE, -- Identifying the business owner internal numbering for the slots
    SlotCapacity INT NOT NULL,
    BusinessID INT FOREIGN KEY REFERENCES BUSINESS(BUSINESSID)
);

CREATE TABLE Reservations (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY ,
    CustomerName VARCHAR(50) NOT NULL,
    CustomerPhoneNo varchar(50) NOT NULL,
    PartySize INT NOT NULL,
    ReservationTime DATETIME NOT NULL,
    ReservationTimeEnd DATETIME NOT NULL,
    SlotId INT FOREIGN KEY REFERENCES Slots
);



INSERT INTO Business(BusinessName, Address, Phone, Email, BusinessStartTime, BusinessEndTime) values ('Crispy Bites','Houston Street, B41234','+923064920124', 'hussain.an@example.com', '09:00:00','17:00:00');


INSERT INTO Slots (SlotNO, SlotCapacity,BusinessID)
VALUES
    (101, 2,1),
    (102, 4,1),
    ( 103, 2,1),
    ( 104, 3,1);