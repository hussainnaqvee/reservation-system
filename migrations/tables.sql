CREATE TABLE BusinessTypes
(
    BusinessTypeId INT identity (1,1) PRIMARY KEY,
    Name           varchar(50) not null,
);

INSERT INTO BusinessTypes(Name)
values ('Restaurant'),
       ('Saloon');

CREATE TABLE Business (
                          BusinessID           INT identity(1,1) primary key,
                          BusinesTypeId        INT FOREIGN key REFERENCES BusinessTypes not null,
                          BusinessName         varchar(100) not null,
                          Address              varchar(100) not null,
                          Phone                varchar(20)  not null,
                          Email                varchar(100) not null,
                          ReservationStartTime TIME         not null,
                          ReservationEndTime   TIME         not null,
                          OpeningTime          TIME         not null,
                          ClosingTime          TIME         not null,
                          AverageServeTime     int          not null, -- Average Serve Time required by the Business to serve each customer
                          BufferTime           int          not null, -- Average Buffer/cooldown time for slot after which it becomes available.
);

CREATE TABLE Slots (
                       SlotID       INT IDENTITY(1,1) PRIMARY KEY,
                       SlotName     varchar(200) NOT NULL UNIQUE, -- Identifying the business owner internal numbering for the slots
                       SlotCapacity INT          NOT NULL,
                       BusinessID   INT FOREIGN KEY REFERENCES BUSINESS(BUSINESSID)
);

CREATE TABLE Reservations (
                              ReservationID      INT IDENTITY(1,1) PRIMARY KEY,
                              CustomerName       VARCHAR(50) NOT NULL,
                              CustomerPhoneNo    varchar(50) NOT NULL,
                              PartySize          INT         NOT NULL,
                              ReservationTime    DATETIME    NOT NULL,
                              ReservationTimeEnd DATETIME    NOT NULL,
                              SlotId             INT FOREIGN KEY REFERENCES Slots
);



INSERT INTO Business(BusinessName, BusinesTypeId, Address, Phone, Email, ReservationStartTime, ReservationEndTime,
                     OpeningTime, ClosingTime, AverageServeTime, BufferTime)
values ('Crispy Bites', 1, 'Houston Street, B41234', '+923064920124', 'hussain.an@example.com', '12:00:00', '18:00:00',
        '09:00:00', '20:00:00', 60, 10);
INSERT INTO Business(BusinessName, BusinesTypeId, Address, Phone, Email, ReservationStartTime, ReservationEndTime,
                     OpeningTime, ClosingTime, AverageServeTime, BufferTime)
values ('Hair Saloon', 2, 'Houston Street, B41234', '+923064920124', 'hussain.an@example.com', '12:00:00', '18:00:00',
        '09:00:00', '20:00:00', 60, 5);


INSERT INTO Slots (SlotName, SlotCapacity, BusinessID)
VALUES ('1', 2, 1),
       ('2', 4, 1),
       ('3', 2, 1),
       ('4', 3, 1);

INSERT INTO Slots (SlotName, SlotCapacity, BusinessID)
VALUES ('Jacob', 1, 2),
       ('Daniel', 1, 2),
       ('David', 1, 2),
       ('Kamla', 1, 2);