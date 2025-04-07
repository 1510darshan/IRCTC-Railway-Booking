const { sql,poolPromise } = require('../config/db');


exports.createBooking = async (req, res) => {
    const {
        userId,
        trainId,
        sourceStationId,
        destinationStationId,
        journeyDate,
        coachType,
        totalPassengers,
        totalFare,
        passengers
    } = req.body;

    try {
        const pool = await poolPromise;
        const request = pool.request();

        console.log('Executing CreateBookingWithPNR with:', {
            UserID: userId,
            TrainID: trainId,
            SourceStationID: sourceStationId,
            DestinationStationID: destinationStationId,
            JourneyDate: journeyDate,
            CoachType: coachType,
            TotalPassengers: totalPassengers,
            TotalFare: totalFare,
            BookingStatus: 'Waiting',
            ConfirmationChance: 0,
            PaymentStatus: 'Pending'
        });

        const result = await request
            .input('UserID', sql.Int, userId)
            .input('TrainID', sql.Int, trainId)
            .input('SourceStationID', sql.Int, sourceStationId)
            .input('DestinationStationID', sql.Int, destinationStationId)
            .input('JourneyDate', sql.Date, journeyDate)
            .input('CoachType', sql.VarChar, coachType)
            .input('TotalPassengers', sql.Int, totalPassengers)
            .input('TotalFare', sql.Decimal(10, 2), totalFare)
            .input('BookingStatus', sql.VarChar, 'Waiting')
            .input('ConfirmationChance', sql.Int, 0)
            .input('PaymentStatus', sql.VarChar, 'Pending')
            .output('PNRNumber', sql.VarChar(20))
            .output('BookingID', sql.Int)
            .execute('CreateBookingWithPNR');

        const generatedPNR = result.output.PNRNumber;
        const bookingId = result.output.BookingID;

        console.log('Generated PNR:', generatedPNR);
        console.log('Generated BookingID:', bookingId);

        if (!generatedPNR || !bookingId) {
            throw new Error(`Failed to generate PNR or BookingID: PNR=${generatedPNR}, BookingID=${bookingId}`);
        }

        // Insert passengers
        for (const passenger of passengers) {
            await pool.request()
                .input('BookingID', sql.Int, bookingId)
                .input('Name', sql.VarChar, passenger.name)
                .input('Age', sql.Int, passenger.age)
                .input('Gender', sql.VarChar, passenger.gender)
                .input('IDProofType', sql.VarChar, passenger.idProofType)
                .input('IDProofNumber', sql.VarChar, passenger.idProofNumber)
                .query(`
                    INSERT INTO Passengers (BookingID, Name, Age, Gender, IDProofType, IDProofNumber)
                    VALUES (@BookingID, @Name, @Age, @Gender, @IDProofType, @IDProofNumber)
                `);
        }

        // Fetch alternate trains if applicable
        const alternateTrainsResult = await pool.request()
            .input('BookingID', sql.Int, bookingId)
            .query(`
                SELECT at.AlternateTrainID, t.TrainNumber, t.TrainName, at.AvailableSeats,
                       at.DepartureDifference, at.TimeDifference, at.PriceDifference, at.SuggestionReason
                FROM AlternateTrains at
                JOIN Trains t ON at.AlternateTrainID = t.TrainID
                WHERE at.BookingID = @BookingID
            `);

        // Send final response
        res.status(201).json({
            message: 'Booking created successfully',
            pnrNumber: generatedPNR,
            confirmationChance: await getConfirmationChance(bookingId),
            alternateTrains: alternateTrainsResult.recordset
        });

    } catch (err) {
        console.error('Error in createBooking:', err);
        res.status(500).json({ error: err.message });
    }
};


exports.getBookingByPNR = async (req, res) => {
    const { pnrNumber } = req.params;
    console.log(pnrNumber)
    
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('PNRNumber', sql.VarChar, pnrNumber)
            .query(`
                SELECT b.PNRNumber, b.JourneyDate, b.BookingDate, b.CoachType, b.TotalPassengers, b.TotalFare,
                       b.BookingStatus, b.ConfirmationChance, b.PaymentStatus,
                       t.TrainNumber, t.TrainName, t.RunningDays,
                       src.StationName AS SourceStation, dest.StationName AS DestinationStation,
                       p.Name, p.Age, p.Gender, p.SeatNumber,
                       w.WaitingNumber, w.ConfirmationChance AS WaitlistConfirmationChance
                FROM Bookings b
                JOIN Trains t ON b.TrainID = t.TrainID
                JOIN Stations src ON b.SourceStationID = src.StationID
                JOIN Stations dest ON b.DestinationStationID = dest.StationID
                LEFT JOIN Passengers p ON b.BookingID = p.BookingID
                LEFT JOIN WaitingList w ON b.BookingID = w.BookingID
                WHERE b.PNRNumber = @PNRNumber
            `);
        if (result.recordset.length === 0) return res.status(404).json({ error: 'PNR not found' });
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.cancelBooking = async (req, res) => {
    const { pnrNumber } = req.params;
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('PNRNumber', sql.VarChar, pnrNumber)
            .query(`
                UPDATE Bookings
                SET BookingStatus = 'Cancelled', PaymentStatus = 'Refunded'
                WHERE PNRNumber = @PNRNumber AND BookingStatus NOT IN ('Cancelled', 'Refunded')
                SELECT @@ROWCOUNT AS RowsAffected
            `);
        if (result.recordset[0].RowsAffected === 0) return res.status(404).json({ error: 'Booking not found or already cancelled' });
        res.json({ message: 'Booking cancelled successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

async function getConfirmationChance(bookingId) {
    const pool = await poolPromise;
    const result = await pool.request()
        .input('BookingID', sql.Int, bookingId)
        .query('SELECT ConfirmationChance FROM Bookings WHERE BookingID = @BookingID');
    return result.recordset[0]?.ConfirmationChance || 0;
}