const express = require('express');
const router = express.Router();
const { getAllTrains, getTrainById, getTrainSchedule, addTrain } = require('../controllers/trainController');
const auth = require('../middleware/auth');

router.get('/', getAllTrains);
router.get('/:trainId', getTrainById);
router.get('/:trainId/schedule', getTrainSchedule);
router.post('/', auth, addTrain); // Admin only

module.exports = router;