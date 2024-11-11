CREATE PROCEDURE GetAvailableTimeslotsByBusinessID
    @BusinessID INT
AS
BEGIN
    SELECT
        AT.TimeslotID,
        AT.SLOTID,
        S.SlotNO,
        S.SlotCapacity,
        AT.StartTime,
        AT.EndTime
    FROM
        AvailableTimeslots AS AT
    JOIN
        Slots AS S ON AT.SLOTID = S.SlotID
    WHERE
        S.BusinessID = @BusinessID
        AND AT.EndTime > GETDATE();
END;



    DROP PROCEDURE GetAvailableTimeslotsByBusinessID;

    EXEC GetAvailableTimeslotsByBusinessID @BusinessID = 1;
