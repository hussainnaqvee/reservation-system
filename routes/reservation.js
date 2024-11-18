
const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

const getDateOfDay = (dayOfWeek) => {
    const daysMap = {
        Sunday: 0,
        Monday: 1,
        Tuesday: 2,
        Wednesday: 3,
        Thursday: 4,
        Friday: 5,
        Saturday: 6,
    };

    if (!daysMap.hasOwnProperty(dayOfWeek)) {
        throw new Error("Invalid day of the week");
    }

    const today = new Date(); // Today's date
    const todayDayOfWeek = today.getDay(); // Day of the week (0-6, 0 is Sunday)

    // Calculate the difference between the target day and today's day
    const targetDayOffset = (daysMap[dayOfWeek] - todayDayOfWeek + 7) % 7;

    // Get the target date
    const targetDate = new Date(today);
    targetDate.setDate(today.getDate() + targetDayOffset);

    // Format the date as YYYY-MM-DD
    const formattedDate = targetDate.toISOString().split('T')[0];

    return formattedDate;
};

router.post('/availability', async (req, res) => {
    const {businessId, selectedDay, futureBookingDate} = req.body;

    console.log(req.body);
    try {
        const reservationDate = futureBookingDate ? futureBookingDate : getDateOfDay(selectedDay);
        const pool = await poolPromise;
        let result = await pool.request()
            .input('BusinessID', businessId)
            .input('ReservationDate', reservationDate)
            .execute('GetAvailableSlots');
        console.log(result.recordset);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

router.post('/', async (req, res) => {
    const {
        customerName,
        customerPhoneNo,
        capacity,
        reservationDay,
        reservationTime,
        futureBookingDateTime,
        slotId
    } = req.body;
    console.log(req.body);
    try {
        const reservationDateTime = futureBookingDateTime ? futureBookingDateTime : `${getDateOfDay(reservationDay)}T${reservationTime}`;
        console.log(reservationDateTime);
        const pool = await poolPromise;
        const result = await pool.request()
            .input('CustomerName', customerName)
            .input('CustomerPhoneNo', customerPhoneNo)
            .input('PartySize', capacity)
            .input('ReservationTime', reservationDateTime)
            .input('SlotId', slotId)
            .output('ReservationID', sql.Int)
            .execute('BookReservation');

        const reservationID = result.output.ReservationID;
        console.log(reservationID);
        if (reservationID !== 5002 && reservationTime !== 5003) {
            res.status(201).json({message: 'Reservation created', reservationId: reservationID});
        } else {
            res.status(500).json({ message: 'Reservation failed',  error: reservationID});
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
