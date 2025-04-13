

const { sql, poolPromise } = require('../config/db');



exports.getStation = async (req, res) => {
    const { station } = req.params;
    console.log('Searching for:', station);

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('StationName', sql.VarChar, `%${station}%`)
            .query(`SELECT StationName FROM Stations WHERE StationName LIKE @StationName`);

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Station not found' });
        }

        res.json(result.recordset);
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};


exports.getALLStation = async (req, res) => {
    
    // console.log('Searching for:', station);

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .query(`select StationName, StationID from Stations`);

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Station not found' });
        }

        res.json(result.recordset);
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};