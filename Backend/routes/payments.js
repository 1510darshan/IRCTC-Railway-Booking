const express = require('express');
const router = express.Router();
const { processPayment, getPaymentStatus } = require('../controllers/paymentController');
const auth = require('../middleware/auth');

router.post('/process', auth, processPayment);
router.get('/status/:bookingId', auth, getPaymentStatus);

module.exports = router;