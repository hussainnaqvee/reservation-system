// app.js
const express = require('express');
const cors = require('cors');
const reservations = require('./routes/reservation');
const business = require('./routes/businessInformation');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Routes
app.use('/reservations', reservations);
app.use('/business', business);

const PORT = process.env.PORT || 3000;
const IP = process.env.IP || 'localhost';
app.listen(PORT, IP, () => {
    console.log(`Server is running on port ${PORT}`);
});
