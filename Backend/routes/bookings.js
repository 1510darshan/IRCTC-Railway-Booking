const express = require('express');
const router = express.Router();
const { createBooking, getBookingByPNR, cancelBooking, getUserBookings } = require('../controllers/bookingController');
const auth = require('../middleware/auth');
const middle = require('../middleware/middle');

router.post('/book', auth, createBooking);
router.get('/pnr/:pnrNumber', getBookingByPNR);
router.put('/cancel/:pnrNumber', cancelBooking);
router.get('/user/:userId', middle, getUserBookings);

module.exports = router;