const {sql, poolPromise } = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
    const { username, email, password, firstName, lastName, mobileNumber, address, city, state, pinCode } = req.body;
    console.log( username, email, password, firstName, lastName, mobileNumber, address, city, state, pinCode)
    try {
        const pool = await poolPromise;
        const passwordHash = await bcrypt.hash(password, 10);

        await pool.request()
            .input('Username', sql.VarChar, username)
            .input('Email', sql.VarChar, email)
            .input('PasswordHash', sql.VarChar, passwordHash)
            .input('FirstName', sql.VarChar, firstName)
            .input('LastName', sql.VarChar, lastName)
            .input('MobileNumber', sql.VarChar, mobileNumber)
            .input('Address', sql.VarChar, address)
            .input('City', sql.VarChar, city)
            .input('State', sql.VarChar, state)
            .input('PinCode', sql.VarChar, pinCode)
            .query(`
                INSERT INTO Users (Username, Email, PasswordHash, FirstName, LastName, MobileNumber, Address, City, State, PinCode)
                VALUES (@Username, @Email, @PasswordHash, @FirstName, @LastName, @MobileNumber, @Address, @City, @State, @PinCode)
            `);

        res.status(201).json({ message: 'User registered successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};



exports.login = async (req, res) => {
  const { username, password } = req.body;
  console.log( username, password);

  try {
      const pool = await poolPromise;
      const result = await pool.request()
          .input('Username', sql.VarChar, username)
          .query('SELECT * FROM Users WHERE Username = @Username');

      const user = result.recordset[0];
      if (!user) {
          return res.status(400).json({ error: 'Invalid credentials' });
      }

      const isMatch = await bcrypt.compare(password, user.PasswordHash);
      if (!isMatch) {  // Fix: Check isMatch instead of user
          return res.status(400).json({ error: 'Invalid credentials' });
      }

      // Ensure JWT_SECRET is defined
      // if (!process.env.JWT_SECRET) {
      //     return res.status(500).json({ error: 'JWT_SECRET is not configured' });
      // }

      const token = jwt.sign(
          { userId: user.UserID, role: user.Role },
          "mysecretkey123456",  // Use environment variable
          { expiresIn: '1h' }
      );

      res.cookie("token", token, {
          httpOnly: true,
          secure: process.env.NODE_ENV === "production",  // Secure in production
          sameSite: "strict",
          maxAge: 3*60 * 60 * 1000  // Match token expiry (1 hour)
      }).status(200).json({
          message: 'Login successful',
          token: token,  // Include token in response body for Postman
          user: {
              userId: user.UserID,
              username: user.Username,
              role: user.Role
          }
      });

  } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Server error' });
  }
};


exports.getProfile = async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('UserID', sql.Int, req.user.userId)
            .query(`
                SELECT UserID, Username, Email, FirstName, LastName, MobileNumber, Address, City, State, PinCode
                FROM Users
                WHERE UserID = @UserID
            `);

        if (!result.recordset[0]) return res.status(404).json({ error: 'User not found' });
        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.updateProfile = async (req, res) => {
    const { firstName, lastName, mobileNumber, address, city, state, pinCode } = req.body;

    try {
        const pool = await poolPromise;
        await pool.request()
            .input('UserID', sql.Int, req.user.userId)
            .input('FirstName', sql.VarChar, firstName)
            .input('LastName', sql.VarChar, lastName)
            .input('MobileNumber', sql.VarChar, mobileNumber)
            .input('Address', sql.VarChar, address)
            .input('City', sql.VarChar, city)
            .input('State', sql.VarChar, state)
            .input('PinCode', sql.VarChar, pinCode)
            .query(`
                UPDATE Users
                SET FirstName = @FirstName, LastName = @LastName, MobileNumber = @MobileNumber,
                    Address = @Address, City = @City, State = @State, PinCode = @PinCode
                WHERE UserID = @UserID
            `);

        res.json({ message: 'Profile updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};