const { poolPromise } = require('../config/db');

exports.getLiveStatus = async (req, res) => {
    const { trainId } = req.params;
    const { date } = req.query;

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('TrainID', sql.Int, trainId)
            .input('StatusDate', sql.Date, date)
            .query(`
                SELECT lts.StatusID, lts.TrainID, t.TrainNumber, t.TrainName,
                       lts.StatusDate, lts.DelayMinutes, lts.CurrentSpeed, lts.PlatformNumber, lts.ExpectedArrivalTime,
                       cs.StationName AS CurrentStation, ns.StationName AS NextStation
                FROM LiveTrainStatus lts
                JOIN Trains t ON lts.TrainID = t.TrainID
                LEFT JOIN Stations cs ON lts.CurrentStationID = cs.StationID
                LEFT JOIN Stations ns ON lts.NextStationID = ns.StationID
                WHERE lts.TrainID = @TrainID AND lts.StatusDate = @StatusDate
            `);
        if (result.recordset.length === 0) return res.status(404).json({ error: 'Live status not found' });
        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.updateLiveStatus = async (req, res) => {
    const { trainId } = req.params;
    const { statusDate, currentStationId, nextStationId, delayMinutes, currentSpeed, platformNumber, expectedArrivalTime } = req.body;

    try {
        const pool = await poolPromise;
        await pool.request()
            .input('TrainID', sql.Int, trainId)
            .input('StatusDate', sql.Date, statusDate)
            .input('CurrentStationID', sql.Int, currentStationId)
            .input('NextStationID', sql.Int, nextStationId)
            .input('DelayMinutes', sql.Int, delayMinutes)
            .input('CurrentSpeed', sql.Int, currentSpeed)
            .input('PlatformNumber', sql.VarChar, platformNumber)
            .input('ExpectedArrivalTime', sql.Time, expectedArrivalTime)
            .query(`
                IF EXISTS (SELECT 1 FROM LiveTrainStatus WHERE TrainID = @TrainID AND StatusDate = @StatusDate)
                    UPDATE LiveTrainStatus
                    SET CurrentStationID = @CurrentStationID, NextStationID = @NextStationID,
                        DelayMinutes = @DelayMinutes, CurrentSpeed = @CurrentSpeed,
                        PlatformNumber = @PlatformNumber, ExpectedArrivalTime = @ExpectedArrivalTime,
                        LastUpdated = GETDATE()
                    WHERE TrainID = @TrainID AND StatusDate = @StatusDate
                ELSE
                    INSERT INTO LiveTrainStatus (TrainID, StatusDate, CurrentStationID, NextStationID, DelayMinutes, CurrentSpeed, PlatformNumber, ExpectedArrivalTime)
                    VALUES (@TrainID, @StatusDate, @CurrentStationID, @NextStationID, @DelayMinutes, @CurrentSpeed, @PlatformNumber, @ExpectedArrivalTime)
            `);
        res.json({ message: 'Live train status updated' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};