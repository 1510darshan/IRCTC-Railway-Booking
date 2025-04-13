const express = require('express');
const app = express();
const cookieParser = require('cookie-parser');
const cors = require('cors');



app.use(cors({
  origin: 'http://localhost:3000',  // ✅ Frontend origin
  credentials: true                // ✅ Allow credentials (cookies)
}));

require('dotenv').config();
app.set('view engine', 'ejs');
app.use(express.json());
app.use(cookieParser()); 

// Routes
app.use('/api/users', require('./routes/users'));
app.use('/api/trains', require('./routes/trains'));
app.use('/api/bookings', require('./routes/bookings'));
app.use('/api/payments', require('./routes/payments'));
app.use('/api/live-status', require('./routes/liveStatus'));
app.use('/api/Stations', require('./routes/Stations'));
app.use('/api/seats', require('./routes/seats'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});