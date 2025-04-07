const { sql, poolPromise } = require('../config/db');

// Add alternate train suggestion for a booking
exports.addAlternateTrain = async (req, res) => {
  const {
    BookingID,
    AlternateTrainID,
    AvailableSeats,
    DepartureDifference,
    TimeDifference,
    PriceDifference
  } = req.body;

  try {
    const pool = await poolPromise;

    await pool.request()
      .input('BookingID', sql.Int, BookingID)
      .input('AlternateTrainID', sql.Int, AlternateTrainID)
      .input('AvailableSeats', sql.Int, AvailableSeats)
      .input('DepartureDifference', sql.Int, DepartureDifference)
      .input('TimeDifference', sql.Int, TimeDifference)
      .input('PriceDifference', sql.Decimal(10, 2), PriceDifference)
      .query(`
        INSERT INTO AlternateTrains (
          BookingID, AlternateTrainID, AvailableSeats,
          DepartureDifference, TimeDifference, PriceDifference
        )
        VALUES (
          @BookingID, @AlternateTrainID, @AvailableSeats,
          @DepartureDifference, @TimeDifference, @PriceDifference
        )
      `);

    res.status(201).json({ message: 'Alternate train suggestion added successfully' });
  } catch (err) {
    console.error('Error adding alternate train:', err.message);
    res.status(500).json({ message: 'Failed to add alternate train' });
  }
};

// Get alternate train suggestions for a booking
exports.getAlternateTrainsByBooking = async (req, res) => {
  const { bookingId } = req.params;

  try {
    const pool = await poolPromise;

    const result = await pool.request()
      .input('BookingID', sql.Int, bookingId)
      .query(`
        SELECT A.*, T.TrainName, T.TrainNumber
        FROM AlternateTrains A
        JOIN Trains T ON A.AlternateTrainID = T.TrainID
        WHERE A.BookingID = @BookingID
      `);

    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching alternate trains:', err.message);
    res.status(500).json({ message: 'Failed to fetch alternate trains' });
  }
};

// Optional: Recommend alternate trains for a waitlisted ticket
exports.recommendAlternateTrains = async (req, res) => {
  const { bookingId } = req.params;

  try {
    const pool = await poolPromise;

    const bookingData = await pool.request()
      .input('BookingID', sql.Int, bookingId)
      .query(`
        SELECT B.JourneyDate, B.CoachType, B.SourceStationID, B.DestinationStationID, B.TrainID
        FROM Bookings B
        WHERE B.BookingID = @BookingID
      `);

    if (bookingData.recordset.length === 0) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    const booking = bookingData.recordset[0];

    // Find alternate trains with same source and destination
    const result = await pool.request()
      .input('SourceStationID', sql.Int, booking.SourceStationID)
      .input('DestinationStationID', sql.Int, booking.DestinationStationID)
      .input('JourneyDate', sql.Date, booking.JourneyDate)
      .query(`
        SELECT T.TrainID, T.TrainName, T.DepartureTime, T.ArrivalTime
        FROM Trains T
        WHERE T.SourceStationID = @SourceStationID
          AND T.DestinationStationID = @DestinationStationID
          AND T.Status = 'Active'
      `);

    const suggestedTrains = result.recordset;

    res.json({ message: 'Recommended alternate trains', trains: suggestedTrains });
  } catch (err) {
    console.error('Error recommending alternate trains:', err.message);
    res.status(500).json({ message: 'Failed to recommend alternate trains' });
  }
};
