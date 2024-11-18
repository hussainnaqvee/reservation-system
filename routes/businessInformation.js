const express = require('express');
const router = express.Router();
const {sql, poolPromise} = require('../db');

router.get('/', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.query(`SELECT *
                                         FROM Business`);
        console.log(result.recordset);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({message: err.message});
    }
});

module.exports = router;
