const { sql, poolPromise } = require('../config/db');

exports.processPayment = async (req, res) => {
    const { bookingId, amount, paymentMethod, transactionId } = req.body;

    console.log( bookingId, amount, paymentMethod, transactionId);
    try {
        const pool = await poolPromise;
        await pool.request()
            .input('BookingID', sql.Int, bookingId)
            .input('Amount', sql.Decimal(10, 2), amount)
            .input('PaymentMethod', sql.VarChar, paymentMethod)
            .input('TransactionID', sql.VarChar, transactionId)
            .input('Status', sql.VarChar, 'Pending')
            .query(`
                INSERT INTO Payments (BookingID, Amount, PaymentMethod, TransactionID, Status)
                VALUES (@BookingID, @Amount, @PaymentMethod, @TransactionID, @Status)
            `);

        // Simulate payment success (in real scenario, integrate with payment gateway)
        await pool.request()
            .input('PaymentID', sql.Int, (await pool.request().query('SELECT MAX(PaymentID) FROM Payments')).recordset[0][''])
            .query('UPDATE Payments SET Status = \'Success\' WHERE PaymentID = @PaymentID');

        await pool.request()
            .input('BookingID', sql.Int, bookingId)
            .query('UPDATE Bookings SET PaymentStatus = \'Paid\' WHERE BookingID = @BookingID');

        res.json({ message: 'Payment processed successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getPaymentStatus = async (req, res) => {
    const { bookingId } = req.params;
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('BookingID', sql.Int, bookingId)
            .query(`
                SELECT p.PaymentID, p.Amount, p.PaymentDate, p.PaymentMethod, p.TransactionID, p.Status
                FROM Payments p
                WHERE p.BookingID = @BookingID
            `);
        if (result.recordset.length === 0) return res.status(404).json({ error: 'Payment not found' });
        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};