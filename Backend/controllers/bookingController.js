const { sql, poolPromise } = require('../config/db');


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
    console.log(userId,
        trainId,
        sourceStationId,
        destinationStationId,
        journeyDate,
        coachType,
        totalPassengers,
        totalFare,
        passengers)

    try {
        const pool = await poolPromise;
        const request = pool.request();

        if (!userId | !trainId | !sourceStationId | !destinationStationId
            | !journeyDate
            | !coachType
            | !totalPassengers
            | !totalFare
            | !passengers) {
            console.log("Enter all fields");
        }

        

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
            bookingId : bookingId,
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

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('PNRNumber', sql.VarChar, pnrNumber)
            .query(`
                SELECT *
                FROM vw_BookingDetails
                WHERE PNRNumber = @PNRNumber
            `);

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'PNR not found' });
        }

        res.json(result.recordset);
    } catch (err) {
        console.error("Error querying PNR:", err);
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



exports.getUserBookings = async (req, res) => {
    const userId = req.params.userId;
    console.log("UserID : ", userId);
    
    try {
        // Verify that the requesting user is accessing their own bookings
        // if (!req.user || req.user.id !== parseInt(userId)) {
        //     return res.status(403).json({ error: 'Unauthorized access to bookings' });
        // }
        
        
        const pool = await poolPromise;
        const result = await pool.request()
            .input('UserID', sql.Int, userId)
            .query(`
                SELECT 
                    b.BookingID,
                    b.PNRNumber,
                    b.UserID,
                    b.TrainID,
                    t.TrainName,
                    b.JourneyDate,
                    b.BookingDate,
                    b.BookingStatus,
                    b.PaymentStatus,
                    b.TotalFare,
                    b.CoachType,
                    b.TotalPassengers,
                    s1.StationName AS SourceStation,
                    s2.StationName AS DestinationStation,
                    b.ConfirmationChance
                FROM 
                    Bookings b
                LEFT JOIN 
                    Trains t ON b.TrainID = t.TrainID
                LEFT JOIN 
                    Stations s1 ON b.SourceStationID = s1.StationID
                LEFT JOIN 
                    Stations s2 ON b.DestinationStationID = s2.StationID
                WHERE 
                    b.UserID = @UserID
                ORDER BY 
                    b.JourneyDate DESC, b.BookingDate DESC
            `);
        console.log("My Data :",result.recordset);
        res.json(result.recordset);
    } catch (err) {
        console.error('Error fetching user bookings:', err);
        res.status(500).json({ error: 'Server error while fetching bookings' });
    }
};

async function getConfirmationChance(bookingId) {
    const pool = await poolPromise;
    const result = await pool.request()
        .input('BookingID', sql.Int, bookingId)
        .query('SELECT ConfirmationChance FROM Bookings WHERE BookingID = @BookingID');
    return result.recordset[0]?.ConfirmationChance || 0;

}



// Helper function to update waiting list after a cancellation
async function updateWaitingListBookings(pool, trainId, journeyDate) {
    try {
        // Get all waiting list bookings for this train and date
        const waitingListResult = await pool.request()
            .input('TrainID', sql.Int, trainId)
            .input('JourneyDate', sql.Date, journeyDate)
            .query(`
                SELECT BookingID
                FROM Bookings
                WHERE TrainID = @TrainID 
                AND JourneyDate = @JourneyDate
                AND BookingStatus IN ('Waiting', 'RAC')
                ORDER BY BookingDate ASC
            `);
        
        // Update confirmation chances for each booking
        const waitingListBookings = waitingListResult.recordset;
        for (let i = 0; i < waitingListBookings.length; i++) {
            const bookingId = waitingListBookings[i].BookingID;
            
            // Calculate new confirmation chance (higher for those who booked earlier)
            const newChance = Math.min(100, 50 + Math.floor((waitingListBookings.length - i) * 5));
            
            await pool.request()
                .input('BookingID', sql.Int, bookingId)
                .input('ConfirmationChance', sql.Int, newChance)
                .query(`
                    UPDATE Bookings
                    SET ConfirmationChance = @ConfirmationChance
                    WHERE BookingID = @BookingID
                `);
        }
    } catch (err) {
        console.error('Error updating waiting list bookings:', err);
        // We don't want to fail the entire transaction if this fails
        // Just log the error
    }
}