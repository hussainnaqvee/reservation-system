
const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

router.get('/availability', async (req, res) => {
    const { businessId } = req.query;
    try {
        const pool = await poolPromise;
        let result = await pool.request()
            .input('BusinessID', businessId)
            .execute('GetAvailableTimeslotsByBusinessID');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Endpoint to create a reservation
router.post('/', async (req, res) => {
    const { customerName, phoneNo, capacity, reservationTime } = req.body;
    console.log(req.body);
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('CustomerName', sql.VarChar, customerName)
            .input('PhoneNo', sql.VarChar, phoneNo)
            .input('Capacity', sql.Int, capacity)
            .input('ReservationTime', sql.DateTime, reservationTime)
            .output('ReservationID', sql.Int)
            .execute('BookReservation');

        const reservationID = result.output.ReservationID;
        console.log('Reservation ID:', reservationID);
        if (reservationID !== -9001) {
            res.status(201).json({ message: 'Reservation created',  reservationID});
        } else {
            res.status(500).json({ message: 'Reservation failed',  error: reservationID});
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
