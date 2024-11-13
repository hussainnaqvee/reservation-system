    drop procedure BookReservation;

    CREATE PROCEDURE BookReservation
    @BusinessID INT,
    @CustomerName VARCHAR(50),
    @CustomerPhoneNo VARCHAR(50),
    @PartySize INT,
    @ReservationTime DATETIME,
    @ReservationID INT OUTPUT  -- Output parameter to return the ReservationID
AS
BEGIN
    DECLARE @ReservationEndTime DATETIME = DATEADD(HOUR, 1, @ReservationTime); -- Assuming 1-hour reservation duration
    DECLARE @BusinessStartTime TIME, @BusinessEndTime TIME;
    DECLARE @SelectedSlotID INT = NULL;

    SELECT @BusinessStartTime = BusinessStartTime, @BusinessEndTime = BusinessEndTime
    FROM Business
    WHERE BusinessID = @BusinessID;

    IF @BusinessStartTime IS NULL
        BEGIN
            print 'Could not Business timing(BusinessId null or Business Timings not defined)'
            SET @ReservationID = 5000;
            RETURN
        END

    -- Check if reservation time is within business hours
    IF CONVERT(TIME, @ReservationTime) < @BusinessStartTime OR CONVERT(TIME, @ReservationEndTime) > @BusinessEndTime
    BEGIN
        PRINT 'Reservation time is outside business hours.';
        SET @ReservationID = 5002;
        RETURN;
    END

    SELECT TOP 1 @SelectedSlotID = s.SlotID
    FROM Slots s
    LEFT JOIN Reservations r
        ON s.SlotID = r.SlotId
        AND r.ReservationTimeEnd > @ReservationTime
        AND r.ReservationTime < @ReservationEndTime
    WHERE s.BusinessID = @BusinessID
      AND s.SlotCapacity >= @PartySize
      AND r.ReservationID IS NULL
    ORDER BY s.SlotCapacity ASC;

    IF @SelectedSlotID IS NOT NULL
    BEGIN
        INSERT INTO Reservations (CustomerName, CustomerPhoneNo, PartySize, ReservationTime, ReservationTimeEnd, SlotId)
        VALUES (@CustomerName, @CustomerPhoneNo, @PartySize, @ReservationTime, @ReservationEndTime, @SelectedSlotID);

        -- Retrieve the new ReservationID
        SET @ReservationID = SCOPE_IDENTITY();
        PRINT 'Reservation successfully booked.';
    END
    ELSE
    BEGIN
        PRINT 'No available slot found matching the requested party size and time.';
        SET @ReservationID = 5003;
    END
END;
