const sql = require('mssql');
require('dotenv').config();

// Debug environment variables
console.log('Environment Variables:');
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_PASSWORD:', process.env.DB_PASSWORD);
console.log('DB_SERVER:', process.env.DB_SERVER);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('DB_PORT:', process.env.DB_PORT);

const dbConfig = {
    user: process.env.DB_USER || "Darshan",
    password: process.env.DB_PASSWORD || '12345',
    server: process.env.DB_SERVER || 'LAPTOP-9CPN5090\\SQLEXPRESS',  // Should now be LAPTOP-9CPN5090\SQLEXPRESS
    database: process.env.DB_NAME || 'MyRailway',
    port: parseInt(process.env.DB_PORT) || 1433,  // Add port
    options: {
        encrypt: true,  // Required for Azure or if encryption is enabled
        trustServerCertificate: true  // For local development to bypass SSL issues
    }
};

const poolPromise = new sql.ConnectionPool(dbConfig)
    .connect()
    .then(pool => {
        console.log('Connected to MSSQL');
        return pool;
    })
    .catch(err => {
        console.error('Database connection failed:', err);
        process.exit(1);  // Exit the process to ensure the error is noticed
    });

module.exports = { sql, poolPromise };