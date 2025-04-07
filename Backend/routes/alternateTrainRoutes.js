const express = require('express');
const router = express.Router();

const alternateTrainController = require('../controllers/alternateTrainController');
const { authenticateToken } = require('../middleware/authMiddleware');

// Suggest alternate trains for a booking
router.get('/suggest/:bookingId', authenticateToken, alternateTrainController.suggestAlternateTrains);

// View saved alternate options (if stored in DB)
router.get('/view/:bookingId', authenticateToken, alternateTrainController.getAlternateSuggestions);

// (Optional) Save alternate suggestion manually
router.post('/save', authenticateToken, alternateTrainController.saveAlternateSuggestion);

module.exports = router;
