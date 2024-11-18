CREATE PROCEDURE BookReservation @CustomerName NVARCHAR(50),
    @CustomerPhoneNo NVARCHAR(50),
    @PartySize INT,
    @ReservationTime DATETIME,
    @SlotId INT,
    @ReservationId INT OUTPUT
AS
BEGIN
    SET
NOCOUNT ON;

    -- Ensure reservation time is not in the past
    IF
@ReservationTime < GETDATE()
BEGIN
        RAISERROR
('Reservation time cannot be in the past.', 16, 1);
        RETURN;
END;

    -- Validate SlotId existence
    IF
NOT EXISTS (SELECT 1 FROM Slots WHERE SlotID = @SlotId)
BEGIN
        RAISERROR
('The specified SlotId does not exist.', 16, 1);
        RETURN;
END;

    -- Retrieve business's average serve time and buffer time
    DECLARE
@AverageServeTime INT;
    DECLARE
@BufferTime INT;
SELECT @AverageServeTime = AverageServeTime,
       @BufferTime = BufferTime
FROM Business
WHERE BusinessID = (SELECT BusinessID FROM Slots WHERE SlotID = @SlotId);

-- Calculate ReservationTimeEnd by adding AverageServeTime and BufferTime
DECLARE
@ReservationTimeEnd DATETIME = DATEADD(MINUTE, @AverageServeTime + @BufferTime, @ReservationTime);

    -- Check if the reservation time range is valid for the SlotId
    IF
EXISTS (
        SELECT 1
        FROM Reservations
        WHERE SlotId = @SlotId
        AND (
            (@ReservationTime < ReservationTimeEnd AND @ReservationTimeEnd > ReservationTime) -- Overlapping time check
        )
    )
BEGIN
        RAISERROR
('The selected time range is not available for the specified SlotId.', 16, 1);
        RETURN;
END;

    -- Ensure PartySize does not exceed the slot's capacity
    DECLARE
@SlotCapacity INT;
SELECT @SlotCapacity = SlotCapacity
FROM Slots
WHERE SlotID = @SlotId;

IF
@PartySize > @SlotCapacity
BEGIN
        RAISERROR
('The party size exceeds the slot capacity.', 16, 1);
        RETURN;
END;

    -- Insert the reservation
INSERT INTO Reservations (CustomerName, CustomerPhoneNo, PartySize, ReservationTime, ReservationTimeEnd, SlotId)
VALUES (@CustomerName, @CustomerPhoneNo, @PartySize, @ReservationTime, @ReservationTimeEnd, @SlotId);

-- Retrieve the new ReservationId
SET
@ReservationId = SCOPE_IDENTITY();

    -- Return success
    PRINT
'Reservation created successfully.';
END;
