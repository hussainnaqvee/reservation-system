
const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

router.get('/availability', async (req, res) => {
    const {businessId, selectedTime} = req.body;
    try {
        const pool = await poolPromise;
        let result = await pool.request()
            .input('BusinessID', businessId)
            .input('CurrentDateTime', selectedTime)
            .execute('GetAvailableTimeSlots');
        console.log(result.recordset);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

router.post('/', async (req, res) => {
    const {businessId, customerName, phoneNo, capacity, reservationTime} = req.body;
    console.log(req.body);
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('BusinessID', businessId)
            .input('CustomerName', customerName)
            .input('CustomerPhoneNo', phoneNo)
            .input('PartySize', capacity)
            .input('ReservationTime', reservationTime)
            .output('ReservationID', sql.Int)
            .execute('BookReservation');

        const reservationID = result.output.ReservationID;
        if (reservationID !== 5002 && reservationTime !== 5003) {
            res.status(201).json({ message: 'Reservation created',  reservationID});
        } else {
            res.status(500).json({ message: 'Reservation failed',  error: reservationID});
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
