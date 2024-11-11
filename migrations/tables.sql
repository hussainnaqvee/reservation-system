CREATE TABLE Business (
    BusinessID INT identity(1,1) primary key,
    BusinessName varchar(100) not null,
    Address varchar(100) not null,
    Phone varchar(20) not null
);


CREATE TABLE Slots (
    SlotID INT IDENTITY(1,1) PRIMARY KEY,
    SlotNO INT NOT NULL UNIQUE, -- Identifying the business owner internal numbering for the slots
    SlotCapacity INT NOT NULL,
    BusinessID INT FOREIGN KEY REFERENCES BUSINESS(BUSINESSID)
);

CREATE TABLE AvailableTimeslots (
    TimeslotID INT PRIMARY KEY,
    SLOTID INT FOREIGN KEY REFERENCES Slots(SlotID),
    STARTTIME DATETIME NOT NULL,
    ENDTIME DATETIME NOT NULL
);

CREATE TABLE Reservations (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY ,
    CustomerName VARCHAR(50) NOT NULL,
    CustomerPhoneNo varchar(50) NOT NULL,
    PartySize INT NOT NULL,
    ReservationTime DATETIME NOT NULL,
    Duration INT DEFAULT 60,
    AssignedTables VARCHAR(50)
);




INSERT INTO Business(BusinessName, Address, Phone) values ('Crispy Bites','Houston Street, B41234','+923064920124');


INSERT INTO Slots (SlotNO, SlotCapacity,BusinessID)
VALUES
    (101, 2,1),
    (102, 4,1),
    ( 103, 2,1),
    ( 104, 3,1);


INSERT INTO AvailableTimeslots (TimeslotID, SLOTID, StartTime, EndTime)
VALUES
    (1, 1, '2024-11-11 10:00:00', '2024-11-11 11:00:00'),
    (2, 2, '2024-11-11 10:00:00', '2024-11-11 11:00:00'),
    (3, 3, '2024-11-11 10:00:00', '2024-11-11 11:00:00'),
    (4, 4, '2024-11-11 10:00:00', '2024-11-11 11:00:00');





-- INSERT INTO Reservations(CUSTOMERNAME, CUSTOMERPHONENO, PARTYSIZE, RESERVATIONTIME, ASSIGNEDTABLES)
-- VALUES
--     ('ALI','030121345621',4, '2024-11-11 10:00:00','102'),
--     ('HUMAYUN','030121345621',2, '2024-11-10 10:00:00','101');
--
-- -- Update the available timeslots for SlotNO 101 and 102 in a single query
-- UPDATE AvailableTimeslots
-- SET StartTime = '2024-11-11 12:00:00',
--     EndTime = '2024-11-11 13:00:00'
-- FROM AvailableTimeslots AS AT
-- INNER JOIN Slots AS S ON AT.SlotID = S.SlotID
-- WHERE S.SlotNO IN (101, 102);

