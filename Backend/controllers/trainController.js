const { sql, poolPromise } = require('../config/db');

exports.getAllTrains = async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query(`
            SELECT t.TrainID, t.TrainNumber, t.TrainName, t.TrainType, t.DepartureTime, t.ArrivalTime, t.RunningDays,
                   src.StationName AS SourceStation, dest.StationName AS DestinationStation
            FROM Trains t
            JOIN Stations src ON t.SourceStationID = src.StationID
            JOIN Stations dest ON t.DestinationStationID = dest.StationID
            WHERE t.Status = 'Active'
        `);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getTrainById = async (req, res) => {
    const { trainId } = req.params;
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('TrainID', sql.Int, trainId)
            .query(`
                SELECT t.TrainID, t.TrainNumber, t.TrainName, t.TrainType, t.DepartureTime, t.ArrivalTime, t.RunningDays,
                       src.StationName AS SourceStation, dest.StationName AS DestinationStation
                FROM Trains t
                JOIN Stations src ON t.SourceStationID = src.StationID
                JOIN Stations dest ON t.DestinationStationID = dest.StationID
                WHERE t.TrainID = @TrainID AND t.Status = 'Active'
            `);
        if (!result.recordset[0]) return res.status(404).json({ error: 'Train not found' });
        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getTrainSchedule = async (req, res) => {
    const { trainId } = req.params;
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('TrainID', sql.Int, trainId)
            .query(`
                SELECT tr.StationSequence, s.StationName, tr.ArrivalTime, tr.DepartureTime, tr.DistanceFromOrigin
                FROM TrainRoutes tr
                JOIN Stations s ON tr.StationID = s.StationID
                WHERE tr.TrainID = @TrainID
                ORDER BY tr.StationSequence
            `);
        if (result.recordset.length === 0) return res.status(404).json({ error: 'Schedule not found' });
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.addTrain = async (req, res) => {
    const { trainNumber, trainName, sourceStationId, destinationStationId, trainType, departureTime, arrivalTime, runningDays } = req.body;
    try {
        const pool = await poolPromise;
        await pool.request()
            .input('TrainNumber', sql.VarChar, trainNumber)
            .input('TrainName', sql.VarChar, trainName)
            .input('SourceStationID', sql.Int, sourceStationId)
            .input('DestinationStationID', sql.Int, destinationStationId)
            .input('TrainType', sql.VarChar, trainType)
            .input('DepartureTime', sql.Time, departureTime)
            .input('ArrivalTime', sql.Time, arrivalTime)
            .input('RunningDays', sql.VarChar, runningDays)
            .query(`
                INSERT INTO Trains (TrainNumber, TrainName, SourceStationID, DestinationStationID, TrainType, DepartureTime, ArrivalTime, RunningDays)
                VALUES (@TrainNumber, @TrainName, @SourceStationID, @DestinationStationID, @TrainType, @DepartureTime, @ArrivalTime, @RunningDays)
            `);
        res.status(201).json({ message: 'Train added successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};