const express = require('express');
const app = express();
require('dotenv').config();
const cookieParser = require('cookie-parser');
const cors = require('cors');



app.use(cors({ origin: 'http://localhost:3000' }));

app.set('view engine', 'ejs');
app.use(express.json());
app.use(cookieParser()); 

// Routes
app.use('/api/users', require('./routes/users'));
app.use('/api/trains', require('./routes/trains'));
app.use('/api/bookings', require('./routes/bookings'));
app.use('/api/payments', require('./routes/payments'));
app.use('/api/live-status', require('./routes/liveStatus'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});