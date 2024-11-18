CREATE PROCEDURE GetAvailableSlots @BusinessId INT,
    @ReservationDate DATE
AS
BEGIN
    SET
NOCOUNT ON;

    -- Declare variables for business timings and buffer times
    DECLARE
@ReservationStartTime TIME;
    DECLARE
@ReservationEndTime TIME;
    DECLARE
@AverageServeTime INT;
    DECLARE
@BufferTime INT;

    -- Retrieve business timings and buffer times
SELECT @ReservationStartTime = ReservationStartTime,
       @ReservationEndTime = ReservationEndTime,
       @AverageServeTime = AverageServeTime,
       @BufferTime = BufferTime
FROM Business
WHERE BusinessID = @BusinessId;

-- Calculate slot duration (serve time + buffer time)
DECLARE
@SlotDuration INT = @AverageServeTime + @BufferTime;

    -- Convert start and end times to DATETIME
    DECLARE
@ReservationStartDateTime DATETIME = CAST(@ReservationDate AS DATETIME) + CAST(@ReservationStartTime AS DATETIME);
    DECLARE
@ReservationEndDateTime DATETIME = CAST(@ReservationDate AS DATETIME) + CAST(@ReservationEndTime AS DATETIME);

    -- If the reservation date is today, adjust the start time to the current time
    IF
@ReservationDate = CAST(GETDATE() AS DATE)
BEGIN
        -- If current time is past ReservationEndTime, return no results
        IF
GETDATE() > @ReservationEndDateTime
BEGIN
            PRINT
'All reservation slots for today are closed.';
            RETURN;
END;

        -- Adjust start time to current time if it's later than the business start time
        SET
@ReservationStartDateTime = CASE
            WHEN GETDATE() > @ReservationStartDateTime THEN GETDATE()
            ELSE @ReservationStartDateTime
END;
END;

    -- Get all slots for the business
WITH BusinessSlots AS (SELECT SlotID,
                              SlotName,
                              SlotCapacity
                       FROM Slots
                       WHERE BusinessID = @BusinessId)

   -- Get all existing reservations for the business on the given date
   , ReservationsForDay AS (SELECT r.SlotID,
                                   r.ReservationTime,
                                   r.ReservationTimeEnd
                            FROM Reservations r
                                     INNER JOIN BusinessSlots bs ON r.SlotID = bs.SlotID
                            WHERE CAST(r.ReservationTime AS DATE) = @ReservationDate)

   -- Generate time slots for the day
   , TimeSlots AS (SELECT DATEADD(MINUTE, n * @SlotDuration, @ReservationStartDateTime)                 AS SlotStartTime,
                          DATEADD(MINUTE, n * @SlotDuration + @SlotDuration, @ReservationStartDateTime) AS SlotEndTime
                   FROM (SELECT TOP(DATEDIFF(MINUTE, @ReservationStartDateTime, @ReservationEndDateTime) /
                                    @SlotDuration) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
                         FROM master.dbo.spt_values) t)

-- Combine time slots with slot availability and format as CSV
SELECT bs.SlotID,
       bs.SlotName,
       bs.SlotCapacity,
       -- Concatenate available time slots for each slot into a CSV format
       STUFF((SELECT ', ' + CONVERT(VARCHAR, CONVERT(TIME, ts.SlotStartTime), 120)
              FROM TimeSlots ts
                       LEFT JOIN ReservationsForDay rfd
                                 ON ts.SlotStartTime < rfd.ReservationTimeEnd
                                     AND ts.SlotEndTime > rfd.ReservationTime
                                     AND bs.SlotID = rfd.SlotID
              WHERE rfd.ReservationTime IS NULL -- Only include slots with no overlapping reservations
                AND bs.SlotID = bs.SlotID
           FOR XML PATH ('') ), 1, 2, '') AS AvailableTimes
FROM BusinessSlots bs
ORDER BY bs.SlotID;

END;
