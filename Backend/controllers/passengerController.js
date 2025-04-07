const { sql, poolPromise } = require('../config/db');

// Add passenger(s) to a booking
exports.addPassenger = async (req, res) => {
  const { BookingID, Name, Age, Gender, SeatNumber, IDProofType, IDProofNumber } = req.body;

  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('BookingID', sql.Int, BookingID)
      .input('Name', sql.VarChar(100), Name)
      .input('Age', sql.Int, Age)
      .input('Gender', sql.VarChar(10), Gender)
      .input('SeatNumber', sql.VarChar(20), SeatNumber || null)
      .input('IDProofType', sql.VarChar(20), IDProofType || null)
      .input('IDProofNumber', sql.VarChar(50), IDProofNumber || null)
      .query(`
        INSERT INTO Passengers (BookingID, Name, Age, Gender, SeatNumber, IDProofType, IDProofNumber)
        VALUES (@BookingID, @Name, @Age, @Gender, @SeatNumber, @IDProofType, @IDProofNumber)
      `);

    res.status(201).json({ message: 'Passenger added successfully' });
  } catch (err) {
    console.error('Error adding passenger:', err.message);
    res.status(500).json({ message: 'Failed to add passenger' });
  }
};

// Get passengers by BookingID
exports.getPassengersByBooking = async (req, res) => {
  const { bookingId } = req.params;

  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('BookingID', sql.Int, bookingId)
      .query('SELECT * FROM Passengers WHERE BookingID = @BookingID');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching passengers:', err.message);
    res.status(500).json({ message: 'Failed to fetch passengers' });
  }
};

// Update passenger by ID
exports.updatePassenger = async (req, res) => {
  const { passengerId } = req.params;
  const { Name, Age, Gender, SeatNumber, IDProofType, IDProofNumber } = req.body;

  try {
    const pool = await poolPromise;
    await pool.request()
      .input('PassengerID', sql.Int, passengerId)
      .input('Name', sql.VarChar(100), Name)
      .input('Age', sql.Int, Age)
      .input('Gender', sql.VarChar(10), Gender)
      .input('SeatNumber', sql.VarChar(20), SeatNumber || null)
      .input('IDProofType', sql.VarChar(20), IDProofType || null)
      .input('IDProofNumber', sql.VarChar(50), IDProofNumber || null)
      .query(`
        UPDATE Passengers
        SET Name = @Name,
            Age = @Age,
            Gender = @Gender,
            SeatNumber = @SeatNumber,
            IDProofType = @IDProofType,
            IDProofNumber = @IDProofNumber
        WHERE PassengerID = @PassengerID
      `);

    res.json({ message: 'Passenger updated successfully' });
  } catch (err) {
    console.error('Error updating passenger:', err.message);
    res.status(500).json({ message: 'Failed to update passenger' });
  }
};

// Delete passenger by ID
exports.deletePassenger = async (req, res) => {
  const { passengerId } = req.params;

  try {
    const pool = await poolPromise;
    await pool.request()
      .input('PassengerID', sql.Int, passengerId)
      .query('DELETE FROM Passengers WHERE PassengerID = @PassengerID');

    res.json({ message: 'Passenger deleted successfully' });
  } catch (err) {
    console.error('Error deleting passenger:', err.message);
    res.status(500).json({ message: 'Failed to delete passenger' });
  }
};
