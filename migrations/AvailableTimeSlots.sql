CREATE PROCEDURE GetAvailableTimeSlots
    @BusinessID INT,
    @CurrentDateTime DATETIME
AS
BEGIN
    DECLARE @CurrentTime TIME = CONVERT(TIME, @CurrentDateTime);
    DECLARE @CurrentDate DATE = CONVERT(DATE, @CurrentDateTime);

    DECLARE @BusinessStartTime TIME, @BusinessEndTime TIME;
    SELECT @BusinessStartTime = BusinessStartTime, @BusinessEndTime = BusinessEndTime
    FROM Business
    WHERE BusinessID = @BusinessID;

    SELECT s.SlotID, s.SlotNO, s.SlotCapacity
    FROM Slots s
    LEFT JOIN Reservations r
        ON s.SlotID = r.SlotId
        AND @CurrentDate = CONVERT(DATE, r.ReservationTime)
        AND r.ReservationTimeEnd > @CurrentDateTime
    WHERE s.BusinessID = @BusinessID
      AND @CurrentTime BETWEEN @BusinessStartTime AND @BusinessEndTime
      AND r.ReservationID IS NULL
    ORDER BY s.SlotNO;

END;