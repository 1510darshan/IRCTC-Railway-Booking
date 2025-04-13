exports.selectSeats = async (req, res) => {
    const {
        bookingId,
        seatIds
    } = req.body;

    console.log('Booking ID:', bookingId);
    console.log('Selected Seat IDs:', seatIds);

    if (!bookingId || !seatIds || !Array.isArray(seatIds) || seatIds.length === 0) {
        return res.status(400).json({ 
            error: 'Invalid request. Please provide booking ID and at least one seat ID.' 
        });
    }

    try {
        const pool = await poolPromise;

        // Check if booking exists and is in a valid state for seat selection
        const bookingCheck = await pool.request()
            .input('BookingID', sql.Int, bookingId)
            .query(`
                SELECT BookingID, BookingStatus, TotalPassengers, PaymentStatus
                FROM Bookings
                WHERE BookingID = @BookingID
            `);

        if (bookingCheck.recordset.length === 0) {
            return res.status(404).json({ error: 'Booking not found' });
        }

        const booking = bookingCheck.recordset[0];
        
        if (booking.BookingStatus !== 'Waiting' && booking.BookingStatus !== 'RAC') {
            return res.status(400).json({ 
                error: 'Seats can only be selected for bookings in Waiting or RAC status' 
            });
        }

        if (booking.PaymentStatus !== 'Paid') {
            return res.status(400).json({ 
                error: 'Payment must be completed before selecting seats' 
            });
        }

        // Get passenger count to validate seat selection
        if (seatIds.length !== booking.TotalPassengers) {
            return res.status(400).json({ 
                error: `Please select exactly ${booking.TotalPassengers} seats for your booking` 
            });
        }

        // Check if selected seats are available
        const seatIdString = seatIds.join(',');
        const request = pool.request();
        
        // Execute the stored procedure to book seats
        await request
            .input('BookingID', sql.Int, bookingId)
            .input('SeatIDs', sql.VarChar(sql.MAX), seatIdString)
            .execute('BookSeats');

        // Get seat details for response
        const seatDetails = await pool.request()
            .input('BookingID', sql.Int, bookingId)
            .query(`
                SELECT s.SeatID, c.CoachNumber, s.SeatNumber, s.SeatType, 
                       p.PassengerID, p.Name as PassengerName
                FROM Seats s
                JOIN Coaches c ON s.CoachID = c.CoachID
                LEFT JOIN Passengers p ON s.CurrentBookingID = p.BookingID
                WHERE s.CurrentBookingID = @BookingID
            `);

        // Return success response with seat details
        res.status(200).json({
            message: 'Seats successfully booked',
            bookingId: bookingId,
            seats: seatDetails.recordset,
            bookingStatus: 'Confirmed'
        });
    } catch (err) {
        console.error('Error in selectSeats:', err);
        
        // More descriptive error messages based on error type
        if (err.message && err.message.includes('not available')) {
            return res.status(400).json({ 
                error: 'One or more selected seats are no longer available' 
            });
        }
        
        res.status(500).json({ error: err.message });
    }
};

// Function to get available seats for a train on a specific date
exports.getAvailableSeats = async (req, res) => {
    const { trainId, journeyDate, coachType } = req.query;
    
    if (!trainId || !journeyDate || !coachType) {
        return res.status(400).json({ 
            error: 'Missing required parameters: trainId, journeyDate, and coachType are required' 
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('TrainID', sql.Int, trainId)
            .input('JourneyDate', sql.Date, journeyDate)
            .input('CoachType', sql.VarChar, coachType)
            .query(`
                SELECT 
                    c.CoachID,
                    c.CoachNumber,
                    c.CoachType,
                    s.SeatID,
                    s.SeatNumber,
                    s.SeatType,
                    s.SeatStatus
                FROM Coaches c
                JOIN Seats s ON c.CoachID = s.CoachID
                WHERE c.TrainID = @TrainID
                AND c.CoachType = @CoachType
                AND s.SeatStatus = 'Available'
                AND NOT EXISTS (
                    -- Check if seat is booked on the specific journey date
                    SELECT 1 FROM Bookings b
                    WHERE b.JourneyDate = @JourneyDate
                    AND s.CurrentBookingID = b.BookingID
                )
                ORDER BY c.CoachNumber, s.SeatNumber
            `);

        // Group seats by coach for easier frontend rendering
        const coachesByNumber = {};
        
        result.recordset.forEach(seat => {
            if (!coachesByNumber[seat.CoachNumber]) {
                coachesByNumber[seat.CoachNumber] = {
                    coachId: seat.CoachID,
                    coachNumber: seat.CoachNumber,
                    coachType: seat.CoachType,
                    seats: []
                };
            }
            
            coachesByNumber[seat.CoachNumber].seats.push({
                seatId: seat.SeatID,
                seatNumber: seat.SeatNumber,
                seatType: seat.SeatType,
                status: seat.SeatStatus
            });
        });
        
        res.status(200).json({
            trainId: trainId,
            journeyDate: journeyDate,
            coachType: coachType,
            coaches: Object.values(coachesByNumber)
        });
    } catch (err) {
        console.error('Error in getAvailableSeats:', err);
        res.status(500).json({ error: err.message });
    }
};

// Function to display a train's complete seat map
exports.getTrainSeatMap = async (req, res) => {
    const { trainId } = req.params;
    
    if (!trainId) {
        return res.status(400).json({ error: 'Train ID is required' });
    }
    
    try {
        const pool = await poolPromise;
        
        // First get train details
        const trainDetails = await pool.request()
            .input('TrainID', sql.Int, trainId)
            .query(`
                SELECT 
                    t.TrainID, 
                    t.TrainNumber, 
                    t.TrainName,
                    src.StationCode AS SourceStationCode,
                    src.StationName AS SourceStationName,
                    dest.StationCode AS DestinationStationCode,
                    dest.StationName AS DestinationStationName
                FROM Trains t
                JOIN Stations src ON t.SourceStationID = src.StationID
                JOIN Stations dest ON t.DestinationStationID = dest.StationID
                WHERE t.TrainID = @TrainID
            `);
        
        if (trainDetails.recordset.length === 0) {
            return res.status(404).json({ error: 'Train not found' });
        }
        
        // Get coaches and their seats
        const coachesResult = await pool.request()
            .input('TrainID', sql.Int, trainId)
            .query(`
                SELECT 
                    c.CoachID, 
                    c.CoachNumber, 
                    c.CoachType,
                    c.TotalSeats,
                    c.AvailableSeats
                FROM Coaches c
                WHERE c.TrainID = @TrainID
                ORDER BY c.CoachType, c.CoachNumber
            `);
        
        const coaches = [];
        
        // For each coach, get its seats
        for (const coach of coachesResult.recordset) {
            const seatsResult = await pool.request()
                .input('CoachID', sql.Int, coach.CoachID)
                .query(`
                    SELECT 
                        s.SeatID,
                        s.SeatNumber,
                        s.SeatType,
                        s.SeatStatus
                    FROM Seats s
                    WHERE s.CoachID = @CoachID
                    ORDER BY 
                        CAST(
                            CASE WHEN ISNUMERIC(s.SeatNumber) = 1 
                            THEN s.SeatNumber 
                            ELSE '0' END AS INT
                        )
                `);
            
            coaches.push({
                coachId: coach.CoachID,
                coachNumber: coach.CoachNumber,
                coachType: coach.CoachType,
                totalSeats: coach.TotalSeats,
                availableSeats: coach.AvailableSeats,
                seats: seatsResult.recordset.map(seat => ({
                    seatId: seat.SeatID,
                    seatNumber: seat.SeatNumber,
                    seatType: seat.SeatType,
                    status: seat.SeatStatus
                }))
            });
        }
        
        res.status(200).json({
            train: trainDetails.recordset[0],
            coaches: coaches
        });
    } catch (err) {
        console.error('Error in getTrainSeatMap:', err);
        res.status(500).json({ error: err.message });
    }
};