CREATE PROCEDURE BookReservation
    @CustomerName VARCHAR(50),
    @PhoneNo VARCHAR(50),
    @Capacity INT,
    @ReservationTime DATETIME,
    @ReservationID INT OUTPUT
AS
BEGIN
    DECLARE @SlotID INT;
    DECLARE @SlotCapacity INT;
    DECLARE @EndTime DATETIME;

    SELECT TOP 1
        @SlotID = S.SlotID,
        @SlotCapacity = S.SlotCapacity,
        @EndTime = AT.EndTime
    FROM
        AvailableTimeslots AT
    JOIN
        Slots S ON AT.SLOTID = S.SlotID
    WHERE
        AT.ENDTIME <= @ReservationTime
        AND S.SlotCapacity >= @Capacity
    ORDER BY
        AT.EndTime ASC;

    IF @SlotID IS NOT NULL
    BEGIN
        INSERT INTO Reservations (CustomerName, CustomerPhoneNo, PartySize, ReservationTime, AssignedTables)
        VALUES (@CustomerName, @PhoneNo, @Capacity, @ReservationTime, CAST(@SlotID AS VARCHAR(50)));

        SET @ReservationID = SCOPE_IDENTITY();

       UPDATE AvailableTimeslots SET StartTime = @ReservationTime, EndTime = DATEADD(HOUR, 1, @ReservationTime)
        FROM AvailableTimeslots AS AT
        WHERE AT.SLOTID = @SLOTID;
    END
    ELSE
    BEGIN
        SET @ReservationID = -5002; -- not found
    END
END;



-- DECLARE @ReservationID INT;
--
-- EXEC BookReservation
--     @CustomerName = 'Muhammad Ali',
--     @PhoneNo = '+923005456780',
--     @Capacity = 2,
--     @ReservationTime = '2024-11-11 23:30:00',
--     @ReservationID = @ReservationID OUTPUT;
--
-- SELECT @ReservationID AS ReservationID;

