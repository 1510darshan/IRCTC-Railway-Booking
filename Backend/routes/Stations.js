const express = require('express');
const router = express.Router();
const { getStation, getALLStation } = require('../controllers/stationsController');

// Route to fetch stations matching a keyword (route param)
router.get('/:station', getStation);
router.get ("/", getALLStation);

module.exports = router;