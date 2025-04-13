const express = require('express');
const router = express.Router();
const { selectSeats, getAvailableSeats, getTrainSeatMap} = require('../controllers/seatController'); // Assuming you place the controller functions there
const bookingController = require('../controllers/bookingController'); // Your existing booking controller
const authMiddleware = require('../middleware/auth'); // Assuming you have auth middleware

// Seat selection routes
router.post('/select', authMiddleware, selectSeats);
router.get('/available', authMiddleware, getAvailableSeats);
router.get('/train/:trainId/map', authMiddleware, getTrainSeatMap);

// Coach management routes (admin only)
router.post('/coach/populate', authMiddleware, async (req, res) => {
    const { coachId } = req.body;
    
    if (!coachId) {
        return res.status(400).json({ error: 'Coach ID is required' });
    }
    
    try {
        const pool = await poolPromise;
        await pool.request()
            .input('CoachID', sql.Int, coachId)
            .execute('PopulateCoachSeats');
            
        res.status(200).json({ message: 'Coach seats populated successfully' });
    } catch (error) {
        console.error('Error populating coach seats:', error);
        res.status(500).json({ error: error.message });
    }
});

// Seat management routes (admin only)
router.put('/status/:seatId', authMiddleware, async (req, res) => {
    const { seatId } = req.params;
    const { status } = req.body;
    
    if (!seatId || !status) {
        return res.status(400).json({ error: 'Seat ID and status are required' });
    }
    
    const validStatuses = ['Available', 'Booked', 'Reserved', 'RAC', 'Maintenance'];
    if (!validStatuses.includes(status)) {
        return res.status(400).json({ 
            error: `Invalid status. Must be one of: ${validStatuses.join(', ')}` 
        });
    }
    
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('SeatID', sql.Int, seatId)
            .input('Status', sql.VarChar, status)
            .query(`
                UPDATE Seats 
                SET SeatStatus = @Status, LastUpdated = GETDATE() 
                WHERE SeatID = @SeatID
            `);
            
        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Seat not found' });
        }
        
        res.status(200).json({ message: 'Seat status updated successfully' });
    } catch (error) {
        console.error('Error updating seat status:', error);
        res.status(500).json({ error: error.message });
    }
});

// Route to get booked seats by PNR
router.get('/booking/:pnr', authMiddleware, async (req, res) => {
    const { pnr } = req.params;
    
    if (!pnr) {
        return res.status(400).json({ error: 'PNR number is required' });
    }
    
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('PNR', sql.VarChar, pnr)
            .query(`
                SELECT 
                    b.BookingID,
                    b.PNRNumber,
                    b.JourneyDate,
                    b.BookingStatus,
                    t.TrainNumber,
                    t.TrainName,
                    c.CoachNumber,
                    s.SeatNumber,
                    s.SeatType,
                    p.Name AS PassengerName,
                    p.Age AS PassengerAge,
                    p.Gender AS PassengerGender
                FROM Bookings b
                JOIN Trains t ON b.TrainID = t.TrainID
                JOIN Passengers p ON b.BookingID = p.BookingID
                LEFT JOIN Seats s ON b.BookingID = s.CurrentBookingID
                LEFT JOIN Coaches c ON s.CoachID = c.CoachID
                WHERE b.PNRNumber = @PNR
            `);
            
        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Booking not found for the provided PNR' });
        }
        
        // Group by booking with passengers and their seats
        const booking = {
            bookingId: result.recordset[0].BookingID,
            pnr: result.recordset[0].PNRNumber,
            journeyDate: result.recordset[0].JourneyDate,
            status: result.recordset[0].BookingStatus,
            train: {
                number: result.recordset[0].TrainNumber,
                name: result.recordset[0].TrainName
            },
            passengers: []
        };
        
        result.recordset.forEach(record => {
            booking.passengers.push({
                name: record.PassengerName,
                age: record.PassengerAge,
                gender: record.PassengerGender,
                seat: record.SeatNumber ? {
                    coach: record.CoachNumber,
                    number: record.SeatNumber,
                    type: record.SeatType
                } : null
            });
        });
        
        res.status(200).json(booking);
    } catch (error) {
        console.error('Error fetching booking by PNR:', error);
        res.status(500).json({ error: error.message });
    }
});

// Route to release/cancel booked seats
router.post('/release', authMiddleware, async (req, res) => {
    const { bookingId } = req.body;
    
    if (!bookingId) {
        return res.status(400).json({ error: 'Booking ID is required' });
    }
    
    try {
        const pool = await poolPromise;
        
        // Start transaction
        const transaction = new sql.Transaction(pool);
        await transaction.begin();
        
        try {
            // Update seat status
            await transaction.request()
                .input('BookingID', sql.Int, bookingId)
                .query(`
                    UPDATE Seats
                    SET SeatStatus = 'Available',
                        CurrentBookingID = NULL,
                        LastUpdated = GETDATE()
                    WHERE CurrentBookingID = @BookingID
                `);
                
            // Update booking status
            await transaction.request()
                .input('BookingID', sql.Int, bookingId)
                .query(`
                    UPDATE Bookings
                    SET BookingStatus = 'Cancelled'
                    WHERE BookingID = @BookingID
                `);
                
            // Clear seat assignments from passengers
            await transaction.request()
                .input('BookingID', sql.Int, bookingId)
                .query(`
                    UPDATE Passengers
                    SET SeatNumber = NULL
                    WHERE BookingID = @BookingID
                `);
                
            // Commit transaction
            await transaction.commit();
            
            res.status(200).json({ 
                message: 'Seats released and booking cancelled successfully' 
            });
        } catch (err) {
            // Rollback transaction on error
            await transaction.rollback();
            throw err;
        }
    } catch (error) {
        console.error('Error releasing seats:', error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;