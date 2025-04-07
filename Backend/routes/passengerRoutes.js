const express = require('express');
const router = express.Router();

const passengerController = require('../controllers/passengerController');
const { authenticateToken } = require('../middleware/authMiddleware');

// Add passengers to a booking
router.post('/add', authenticateToken, passengerController.addPassengers);

// Get all passengers for a booking
router.get('/:bookingId', authenticateToken, passengerController.getPassengersByBooking);

// Update passenger details (optional)
router.put('/update/:passengerId', authenticateToken, passengerController.updatePassenger);

// Delete a passenger (optional)
router.delete('/delete/:passengerId', authenticateToken, passengerController.deletePassenger);

module.exports = router;
