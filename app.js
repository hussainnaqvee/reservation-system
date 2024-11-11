// app.js
const express = require('express');
const reservations = require('./routes/reservation');
require('dotenv').config();

const app = express();
app.use(express.json());

// Routes
app.use('/reservations', reservations);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
