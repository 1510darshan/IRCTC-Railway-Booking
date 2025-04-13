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


exports.trainsbyStations = async (req, res) => {
    const { sourceStationName, destinationStationName } = req.params;
    console.log(sourceStationName, destinationStationName);
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('SourceStationName', sql.VarChar, sourceStationName)
            .input('DestinationStationName', sql.VarChar, destinationStationName)
            .query(`
                WITH TrainInfo AS (
                    SELECT
                        t.TrainID,
                        t.TrainNumber,
                        t.TrainName,
                        t.TrainType,
                        t.DepartureTime,
                        t.ArrivalTime,
                        DATEDIFF(MINUTE, t.DepartureTime, t.ArrivalTime) AS JourneyDurationMinutes,
                        t.RunningDays,
                        src.StationName AS SourceStation,
                        src.StationCode AS SourceCode,
                        dest.StationName AS DestinationStation,
                        dest.StationCode AS DestinationCode
                    FROM
                        Trains t
                    JOIN
                        Stations src ON t.SourceStationID = src.StationID
                    JOIN
                        Stations dest ON t.DestinationStationID = dest.StationID
                    WHERE
                        src.StationName = @SourceStationName
                        AND dest.StationName = @DestinationStationName
                        AND t.Status = 'Active'
                )
                SELECT
                    ti.TrainID,
                    ti.TrainNumber,
                    ti.TrainName,
                    ti.TrainType,
                    ti.DepartureTime,
                    ti.ArrivalTime,
                    ti.JourneyDurationMinutes,
                    ti.RunningDays,
                    ti.SourceStation,
                    ti.SourceCode,
                    ti.DestinationStation,
                    ti.DestinationCode,
                    (
                        SELECT
                            c.CoachType AS [type],
                            c.AvailableSeats AS [availableSeats],
                            c.TotalSeats AS [totalSeats],
                            f.BaseFare AS [fare]
                        FROM Coaches c
                        JOIN Fares f ON c.TrainID = f.TrainID AND c.CoachType = f.CoachType
                        WHERE c.TrainID = ti.TrainID
                        FOR JSON PATH
                    ) AS AvailableCoaches
                FROM
                    TrainInfo ti
                ORDER BY
                    ti.DepartureTime;
            `);
            
        if (result.recordset.length === 0) {
            return res.status(404).json({
                error: 'No trains found between these stations'
            });
        }
        
        // Parse the JSON string in AvailableCoaches
        const formattedResults = result.recordset.map(train => {
            return {
                ...train,
                AvailableCoaches: JSON.parse(train.AvailableCoaches || '[]')
            };
        });
        
        res.json(formattedResults);
    } catch (err) {
        console.error('Error fetching trains:', err);
        res.status(500).json({ error: err.message });
    }
};