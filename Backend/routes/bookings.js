const express = require('express');
const router = express.Router();
const { createBooking, getBookingByPNR, cancelBooking } = require('../controllers/bookingController');
const auth = require('../middleware/auth');

router.post('/book', auth, createBooking);
router.get('/pnr/:pnrNumber', auth, getBookingByPNR);
router.put('/cancel/:pnrNumber', auth, cancelBooking);

module.exports = router;