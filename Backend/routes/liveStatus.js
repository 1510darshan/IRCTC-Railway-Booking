const express = require('express');
const router = express.Router();
const { getLiveStatus, updateLiveStatus } = require('../controllers/liveStatusController');
const auth = require('../middleware/auth');

router.get('/:trainId', getLiveStatus);
router.put('/:trainId', auth, updateLiveStatus); // Admin only

module.exports = router;