USE master
GO

-- Create the database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'IRCTC_RailwayBookingSystem')
BEGIN
    CREATE DATABASE IRCTC_RailwayBookingSystem
END
GO

USE IRCTC_RailwayBookingSystem
GO


use MyRailway



-- Users Table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50),
    MobileNumber VARCHAR(15) UNIQUE NOT NULL,
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    PinCode VARCHAR(10),
    RegistrationDate DATETIME DEFAULT GETDATE(),
    AccountStatus VARCHAR(20) CHECK (AccountStatus IN ('Active', 'Inactive')) DEFAULT 'Active',
    Role VARCHAR(20) CHECK (Role IN ('User', 'Admin')) DEFAULT 'User'
);

-- Stations Table
CREATE TABLE Stations (
    StationID INT IDENTITY(1,1) PRIMARY KEY,
    StationCode VARCHAR(15) UNIQUE NOT NULL,
    StationName VARCHAR(100) NOT NULL
);

-- Trains Table
CREATE TABLE Trains (
    TrainID INT IDENTITY(1,1) PRIMARY KEY,
    TrainNumber VARCHAR(10) UNIQUE NOT NULL,
    TrainName VARCHAR(100) NOT NULL,
    SourceStationID INT NOT NULL,
    DestinationStationID INT NOT NULL,
    TrainType VARCHAR(20) CHECK (TrainType IN ('Express', 'Mail', 'Superfast', 'Shatabdi', 'Rajdhani','Passenger')),
    DepartureTime TIME,
    ArrivalTime TIME,
    RunningDays VARCHAR(100), -- e.g., 'Mon,Tue,Wed,Thu,Fri,Sat,Sun'
    Status VARCHAR(10) CHECK (Status IN ('Active', 'Inactive')) DEFAULT 'Active',
    FOREIGN KEY (SourceStationID) REFERENCES Stations(StationID),
    FOREIGN KEY (DestinationStationID) REFERENCES Stations(StationID)
);

-- Train Routes Table
CREATE TABLE TrainRoutes (
    RouteID INT IDENTITY(1,1) PRIMARY KEY,
    TrainID INT NOT NULL,
    StationID INT NOT NULL,
    StationSequence INT NOT NULL,
    ArrivalTime TIME,
    DepartureTime TIME,
    DistanceFromOrigin FLOAT,
    FOREIGN KEY (TrainID) REFERENCES Trains(TrainID),
    FOREIGN KEY (StationID) REFERENCES Stations(StationID),
    UNIQUE (TrainID, StationSequence)
);

-- Train Coaches Table
CREATE TABLE Coaches (
    CoachID INT IDENTITY(1,1) PRIMARY KEY,
    TrainID INT NOT NULL,
    CoachNumber VARCHAR(10) NOT NULL,
    CoachType VARCHAR(20) CHECK (CoachType IN ('1A', '2A', '3A', 'SL', 'FC', 'CC', '2S', 'General')),
    TotalSeats INT NOT NULL,
    AvailableSeats INT NOT NULL DEFAULT 0,
    FOREIGN KEY (TrainID) REFERENCES Trains(TrainID),
    UNIQUE (TrainID, CoachNumber)
);

-- Fare Table
CREATE TABLE Fares (
    FareID INT IDENTITY(1,1) PRIMARY KEY,
    TrainID INT NOT NULL,
    CoachType VARCHAR(20) CHECK (CoachType IN ('1A', '2A', '3A', 'SL', 'FC', 'CC', '2S', 'General')),
    BaseFare DECIMAL(10,2) NOT NULL,
    RatePerKM DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (TrainID) REFERENCES Trains(TrainID)
);

-- Bookings Table
CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    TrainID INT NOT NULL,
    SourceStationID INT NOT NULL,
    DestinationStationID INT NOT NULL,
    JourneyDate DATE NOT NULL,
    BookingDate DATETIME DEFAULT GETDATE(),
    CoachType VARCHAR(20) CHECK (CoachType IN ('1A', '2A', '3A', 'SL', 'FC', 'CC', '2S', 'General')),
    TotalPassengers INT NOT NULL,
    TotalFare DECIMAL(10,2) NOT NULL,
    BookingStatus VARCHAR(20) CHECK (BookingStatus IN ('Confirmed', 'Waiting', 'Cancelled', 'RAC')) DEFAULT 'Waiting',
    PNRNumber VARCHAR(20) UNIQUE NOT NULL,
    ConfirmationChance INT DEFAULT 0, -- Percentage chance of confirmation
    PaymentStatus VARCHAR(20) CHECK (PaymentStatus IN ('Paid', 'Pending', 'Failed', 'Refunded')) DEFAULT 'Pending',
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (TrainID) REFERENCES Trains(TrainID),
    FOREIGN KEY (SourceStationID) REFERENCES Stations(StationID),
    FOREIGN KEY (DestinationStationID) REFERENCES Stations(StationID)
);

-- Passengers Table
CREATE TABLE Passengers (
    PassengerID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Age INT NOT NULL,
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other', 'Transgender')),
    SeatNumber VARCHAR(20),
    IDProofType VARCHAR(20) CHECK (IDProofType IN ('Aadhar', 'PAN', 'Passport', 'VoterID')),
    IDProofNumber VARCHAR(50),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- Payments Table
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod VARCHAR(20) CHECK (PaymentMethod IN ('CreditCard', 'DebitCard', 'NetBanking', 'UPI', 'Wallet')),
    TransactionID VARCHAR(50) UNIQUE,
    Status VARCHAR(20) CHECK (Status IN ('Success', 'Failed', 'Pending', 'Refunded')),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- WaitingList Table
CREATE TABLE WaitingList (
    WaitingID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    WaitingNumber INT NOT NULL,
    ConfirmationChance INT DEFAULT 0,
    LastUpdated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- LiveTrainStatus Table
CREATE TABLE LiveTrainStatus (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    TrainID INT NOT NULL,
    StatusDate DATE NOT NULL,
    CurrentStationID INT,
    NextStationID INT,
    DelayMinutes INT DEFAULT 0,
    CurrentSpeed INT DEFAULT 0,
    PlatformNumber VARCHAR(10),
    ExpectedArrivalTime TIME,
    LastUpdated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (TrainID) REFERENCES Trains(TrainID),
    FOREIGN KEY (CurrentStationID) REFERENCES Stations(StationID),
    FOREIGN KEY (NextStationID) REFERENCES Stations(StationID),
    UNIQUE (TrainID, StatusDate)
);

-- AlternateTrains Table
CREATE TABLE AlternateTrains (
    AlternateID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    AlternateTrainID INT NOT NULL,
    AvailableSeats INT,
    DepartureDifference INT,
    TimeDifference INT,
    PriceDifference DECIMAL(10,2),
    SuggestionReason VARCHAR(100),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID),
    FOREIGN KEY (AlternateTrainID) REFERENCES Trains(TrainID)
);


---====================================================================================================================================
------------------------------------------------------------ Views -----------------------------------------------------------------
---====================================================================================================================================

CREATE VIEW UserProfileView AS
SELECT 
    UserID, 
    Username, 
    Email, 
    FirstName, 
    LastName, 
    MobileNumber, 
    Address, 
    City, 
    State, 
    PinCode
FROM Users;
GO



CREATE VIEW vw_BookingDetails AS
SELECT 
    b.PNRNumber,
    b.JourneyDate,
    b.BookingDate,
    b.CoachType,
    b.TotalPassengers,
    b.TotalFare,
    b.BookingStatus,
    b.ConfirmationChance,
    b.PaymentStatus,

    t.TrainNumber,
    t.TrainName,
    t.RunningDays,

    src.StationName AS SourceStation,
    dest.StationName AS DestinationStation,

    p.Name AS PassengerName,
    p.Age AS PassengerAge,
    p.Gender AS PassengerGender,
    p.SeatNumber,

    w.WaitingNumber,
    w.ConfirmationChance AS WaitlistConfirmationChance

FROM Bookings b
JOIN Trains t ON b.TrainID = t.TrainID
JOIN Stations src ON b.SourceStationID = src.StationID
JOIN Stations dest ON b.DestinationStationID = dest.StationID
LEFT JOIN Passengers p ON b.BookingID = p.BookingID
LEFT JOIN WaitingList w ON b.BookingID = w.BookingID;



SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Bookings';


---====================================================================================================================================
------------------------------------------------------------ Views End ----------------------------------------------------------------
---====================================================================================================================================

-------------------------------------------------------------------------------------------------------------

-- Stations
SET IDENTITY_INSERT Stations ON;
INSERT INTO Stations (StationID, StationCode, StationName) VALUES
(1, 'NDLS', 'New Delhi'), (2, 'HWH', 'Howrah Junction'), (3, 'MAS', 'Chennai Central');
SET IDENTITY_INSERT Stations OFF;

-- Trains
SET IDENTITY_INSERT Trains ON;
INSERT INTO Trains (TrainID, TrainNumber, TrainName, SourceStationID, DestinationStationID, TrainType, DepartureTime, ArrivalTime, RunningDays)
VALUES (1, '12051', 'Shatabdi Express', 1, 2, 'Shatabdi', '06:00:00', '14:30:00', 'Mon,Tue,Wed,Thu,Fri,Sat');
SET IDENTITY_INSERT Trains OFF;

-- Coaches
INSERT INTO Coaches (TrainID, CoachNumber, CoachType, TotalSeats, AvailableSeats)
VALUES (1, 'C1', 'CC', 70, 50);

-- Fares
INSERT INTO Fares (TrainID, CoachType, BaseFare, RatePerKM)
VALUES (1, 'CC', 1200.00, 2.50);

-- Users
INSERT INTO Users (Username, Email, PasswordHash, FirstName, LastName, MobileNumber, Address, City, State, PinCode)
VALUES ('user1', 'user1@example.com', 'hashedpass', 'John', 'Doe', '9876543210', '123 Main St', 'Delhi', 'Delhi', '110001');

-------------------------------------------------------------------------------------------------------------
USE IRCTC_RailwayBookingSystem;

USE IRCTC_RailwayBookingSystem;

DROP PROCEDURE IF EXISTS CreateBookingWithPNR;
GO

USE IRCTC_RailwayBookingSystem;

DROP PROCEDURE IF EXISTS CreateBookingWithPNR;
GO

CREATE PROCEDURE CreateBookingWithPNR
    @UserID INT,
    @TrainID INT,
    @SourceStationID INT,
    @DestinationStationID INT,
    @JourneyDate DATE,
    @CoachType VARCHAR(20),
    @TotalPassengers INT,
    @TotalFare DECIMAL(10,2),
    @BookingStatus VARCHAR(20),
    @ConfirmationChance INT,
    @PaymentStatus VARCHAR(20),
    @PNRNumber VARCHAR(20) OUTPUT,
    @BookingID INT OUTPUT
AS
BEGIN
    BEGIN TRY
        -- Generate PNR
        SET @PNRNumber = 'IRCTC-' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR(6)), 6);

        -- Calculate available seats
        DECLARE @AvailableSeats INT;
        SELECT @AvailableSeats = SUM(AvailableSeats)
        FROM Coaches
        WHERE TrainID = @TrainID AND CoachType = @CoachType;

        IF @AvailableSeats IS NULL SET @AvailableSeats = 0;

        -- Determine confirmation chance
        SET @ConfirmationChance = CASE
            WHEN @AvailableSeats >= @TotalPassengers THEN 100
            WHEN @AvailableSeats > 0 THEN 70
            ELSE 30
        END;

        -- Determine booking status
        IF @AvailableSeats >= @TotalPassengers
            SET @BookingStatus = 'Confirmed';
        ELSE
            SET @BookingStatus = 'Waiting';

        -- Insert booking
        INSERT INTO Bookings (
            UserID, TrainID, SourceStationID, DestinationStationID, JourneyDate,
            CoachType, TotalPassengers, TotalFare, PNRNumber, BookingStatus,
            ConfirmationChance, PaymentStatus
        )
        VALUES (
            @UserID, @TrainID, @SourceStationID, @DestinationStationID, @JourneyDate,
            @CoachType, @TotalPassengers, @TotalFare, @PNRNumber, @BookingStatus,
            @ConfirmationChance, @PaymentStatus
        );

        -- Validate insert and retrieve BookingID
        SET @BookingID = SCOPE_IDENTITY();
        IF @BookingID IS NULL
            RAISERROR('Failed to insert booking. BookingID is NULL.', 16, 1);

        -- Insert into WaitingList if not confirmed
        IF @BookingStatus = 'Waiting'
        BEGIN
            DECLARE @WaitingNumber INT;
            SELECT @WaitingNumber = ISNULL(MAX(WaitingNumber), 0) + 1
            FROM WaitingList
            WHERE BookingID IN (
                SELECT BookingID FROM Bookings 
                WHERE TrainID = @TrainID AND JourneyDate = @JourneyDate AND CoachType = @CoachType
            );

            INSERT INTO WaitingList (BookingID, WaitingNumber, ConfirmationChance)
            VALUES (@BookingID, @WaitingNumber, @ConfirmationChance);
        END;

        -- Suggest alternate trains for low confirmation chance
        IF @BookingStatus = 'Waiting' AND @ConfirmationChance < 50
        BEGIN
            INSERT INTO AlternateTrains (
                BookingID, AlternateTrainID, AvailableSeats, 
                DepartureDifference, TimeDifference, PriceDifference, SuggestionReason
            )
            SELECT 
                @BookingID,
                t2.TrainID,
                ISNULL((
                    SELECT SUM(c.AvailableSeats)
                    FROM Coaches c
                    WHERE c.TrainID = t2.TrainID AND c.CoachType = @CoachType
                ), 0) AS AvailableSeats,
                DATEDIFF(MINUTE, t1.DepartureTime, t2.DepartureTime) AS DepartureDifference,
                DATEDIFF(MINUTE, t1.ArrivalTime, t2.ArrivalTime) - DATEDIFF(MINUTE, t1.DepartureTime, t1.ArrivalTime) AS TimeDifference,
                (f2.BaseFare + f2.RatePerKM * 1000) - @TotalFare AS PriceDifference,
                'Low Confirmation Chance (<50%)' AS SuggestionReason
            FROM Trains t1
            CROSS JOIN Trains t2
            JOIN Fares f1 ON t1.TrainID = f1.TrainID AND f1.CoachType = @CoachType
            JOIN Fares f2 ON t2.TrainID = f2.TrainID AND f2.CoachType = @CoachType
            WHERE t1.TrainID = @TrainID
                AND t2.TrainID != @TrainID
                AND t2.SourceStationID = @SourceStationID
                AND t2.DestinationStationID = @DestinationStationID
                AND t2.Status = 'Active'
                AND CHARINDEX(DATENAME(WEEKDAY, @JourneyDate), t2.RunningDays) > 0
                AND (
                    SELECT SUM(c.AvailableSeats)
                    FROM Coaches c
                    WHERE c.TrainID = t2.TrainID AND c.CoachType = @CoachType
                ) > 0;
        END;

        -- Final safeguard
        IF @PNRNumber IS NULL OR @BookingID IS NULL
            RAISERROR('Failed to generate PNR or BookingID.', 16, 1);
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT 
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY();

        -- Reset outputs to null
        SET @PNRNumber = NULL;
        SET @BookingID = NULL;

        -- Re-throw the error
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO




select * from Trains


SELECT * FROM Coaches WHERE TrainID = 1 AND CoachType = 'CC';
IF @@ROWCOUNT = 0
    INSERT INTO Coaches (TrainID, CoachType, AvailableSeats, TotalSeats) VALUES (1, 'CC', 50, 50);

	SELECT * FROM Trains WHERE TrainID = 1 AND SourceStationID = 1 AND DestinationStationID = 2;
IF @@ROWCOUNT = 0
    INSERT INTO Trains (TrainID, TrainNumber, TrainName, TrainType, DepartureTime, ArrivalTime, RunningDays, SourceStationID, DestinationStationID, Status)
    VALUES (1, '12051', 'Shatabdi Express', 'Shatabdi', '06:00:00', '14:30:00', 'Mon,Tue,Wed,Thu,Fri,Sat', 1, 2, 'Active');


SELECT * FROM Fares WHERE TrainID = 1 AND CoachType = 'CC';
IF @@ROWCOUNT = 0
    INSERT INTO Fares (TrainID, CoachType, BaseFare, RatePerKM) VALUES (1, 'CC', 2000.00, 1.50);

SELECT PNRNumber, COUNT(*) FROM Bookings GROUP BY PNRNumber HAVING COUNT(*) > 1;


GRANT INSERT ON Bookings TO Darshan;
GRANT INSERT ON WaitingList TO Darshan;
GRANT INSERT ON AlternateTrains TO Darshan;

select * from Bookings

select * from Users

select * from Passengers





---====================================================================================================================================
------------------------------------------------------------ Seat Manage --------------------------------------------------------------
---====================================================================================================================================

USE IRCTC_RailwayBookingSystem
GO

-- Create Seats Table
CREATE TABLE Seats (
    SeatID INT IDENTITY(1,1) PRIMARY KEY,
    CoachID INT NOT NULL,
    SeatNumber VARCHAR(10) NOT NULL,
    SeatType VARCHAR(20) CHECK (SeatType IN ('Window', 'Middle', 'Aisle', 'Lower Berth', 'Middle Berth', 'Upper Berth', 'Side Lower', 'Side Upper')),
    SeatStatus VARCHAR(20) CHECK (SeatStatus IN ('Available', 'Booked', 'Reserved', 'RAC', 'Maintenance')) DEFAULT 'Available',
    CurrentBookingID INT NULL,
    LastUpdated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CoachID) REFERENCES Coaches(CoachID),
    FOREIGN KEY (CurrentBookingID) REFERENCES Bookings(BookingID),
    UNIQUE (CoachID, SeatNumber)
);
GO

-- Index for performance
CREATE INDEX IX_Seats_CoachID ON Seats(CoachID);
GO

CREATE INDEX IX_Seats_Status ON Seats(SeatStatus);
GO

-- Create a view to see available seats by train
CREATE VIEW vw_AvailableSeats AS
SELECT 
    t.TrainID,
    t.TrainNumber,
    t.TrainName,
    c.CoachID,
    c.CoachNumber,
    c.CoachType,
    s.SeatID,
    s.SeatNumber,
    s.SeatType,
    s.SeatStatus
FROM Trains t
JOIN Coaches c ON t.TrainID = c.TrainID
JOIN Seats s ON c.CoachID = s.CoachID
WHERE s.SeatStatus = 'Available';
GO

-- Create a stored procedure to automatically populate seats for a coach
CREATE OR ALTER PROCEDURE PopulateCoachSeats
    @CoachID INT
AS
BEGIN
    DECLARE @CoachType VARCHAR(20)
    DECLARE @TotalSeats INT
    DECLARE @Counter INT = 1
    DECLARE @SeatNumber VARCHAR(10)
    DECLARE @SeatType VARCHAR(20)
    
    -- Get coach information
    SELECT @CoachType = CoachType, @TotalSeats = TotalSeats
    FROM Coaches
    WHERE CoachID = @CoachID
    
    -- Return if coach not found
    IF @CoachType IS NULL
        RETURN
        
    -- Delete existing seats for this coach
    DELETE FROM Seats WHERE CoachID = @CoachID
    
    -- Insert seats based on coach type
    WHILE @Counter <= @TotalSeats
    BEGIN
        SET @SeatNumber = CAST(@Counter AS VARCHAR(5))
        
        -- Set seat type based on coach type and seat number
        SET @SeatType = CASE
            WHEN @CoachType IN ('SL') THEN
                CASE
                    WHEN @Counter % 8 = 1 THEN 'Lower Berth'
                    WHEN @Counter % 8 = 2 THEN 'Middle Berth'
                    WHEN @Counter % 8 = 3 THEN 'Upper Berth'
                    WHEN @Counter % 8 = 4 THEN 'Lower Berth'
                    WHEN @Counter % 8 = 5 THEN 'Middle Berth'
                    WHEN @Counter % 8 = 6 THEN 'Upper Berth'
                    WHEN @Counter % 8 = 7 THEN 'Side Lower'
                    ELSE 'Side Upper'
                END
            WHEN @CoachType IN ('2A') THEN
                CASE
                    WHEN @Counter % 6 = 1 THEN 'Lower Berth'
                    WHEN @Counter % 6 = 2 THEN 'Upper Berth'
                    WHEN @Counter % 6 = 3 THEN 'Lower Berth'
                    WHEN @Counter % 6 = 4 THEN 'Upper Berth'
                    WHEN @Counter % 6 = 5 THEN 'Side Lower'
                    ELSE 'Side Upper'
                END
            WHEN @CoachType IN ('3A') THEN
                CASE
                    WHEN @Counter % 8 = 1 THEN 'Lower Berth'
                    WHEN @Counter % 8 = 2 THEN 'Middle Berth'
                    WHEN @Counter % 8 = 3 THEN 'Upper Berth'
                    WHEN @Counter % 8 = 4 THEN 'Lower Berth'
                    WHEN @Counter % 8 = 5 THEN 'Middle Berth'
                    WHEN @Counter % 8 = 6 THEN 'Upper Berth'
                    WHEN @Counter % 8 = 7 THEN 'Side Lower'
                    ELSE 'Side Upper'
                END
            WHEN @CoachType IN ('1A') THEN
                CASE
                    WHEN @Counter % 4 = 1 THEN 'Lower Berth'
                    WHEN @Counter % 4 = 2 THEN 'Upper Berth'
                    WHEN @Counter % 4 = 3 THEN 'Lower Berth'
                    ELSE 'Upper Berth'
                END
            WHEN @CoachType IN ('CC', 'FC', '2S') THEN
                CASE
                    WHEN @Counter % 3 = 1 THEN 'Window'
                    WHEN @Counter % 3 = 2 THEN 'Middle'
                    ELSE 'Aisle'
                END
            ELSE 'Regular'
        END
        
        -- Insert the seat
        INSERT INTO Seats (CoachID, SeatNumber, SeatType, SeatStatus)
        VALUES (@CoachID, @SeatNumber, @SeatType, 'Available')
        
        SET @Counter = @Counter + 1
    END
    
    -- Update available seats count in the Coaches table
    UPDATE Coaches
    SET AvailableSeats = @TotalSeats
    WHERE CoachID = @CoachID
END;
GO

-- Create a trigger to update the Coaches.AvailableSeats when seat status changes
CREATE OR ALTER TRIGGER trg_UpdateCoachAvailableSeats
ON Seats
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Get affected CoachIDs
    DECLARE @AffectedCoaches TABLE (CoachID INT)
    
    INSERT INTO @AffectedCoaches
    SELECT DISTINCT CoachID FROM inserted
    UNION
    SELECT DISTINCT CoachID FROM deleted
    
    -- Update available seats count for each affected coach
    UPDATE c
    SET AvailableSeats = (
        SELECT COUNT(*) 
        FROM Seats s 
        WHERE s.CoachID = c.CoachID AND s.SeatStatus = 'Available'
    )
    FROM Coaches c
    WHERE c.CoachID IN (SELECT CoachID FROM @AffectedCoaches)
END;
GO

-- Create a procedure to book specific seats
CREATE OR ALTER PROCEDURE BookSeats
    @BookingID INT,
    @SeatIDs VARCHAR(MAX) -- Comma-separated list of SeatIDs
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Create a table variable to hold the seat IDs
        DECLARE @Seats TABLE (SeatID INT)
        
        -- Parse the comma-separated list
        INSERT INTO @Seats
        SELECT value FROM STRING_SPLIT(@SeatIDs, ',')
        
        -- Check if all seats are available
        IF EXISTS (
            SELECT 1 FROM Seats 
            WHERE SeatID IN (SELECT SeatID FROM @Seats)
            AND SeatStatus <> 'Available'
        )
        BEGIN
            RAISERROR('One or more selected seats are not available.', 16, 1)
            RETURN
        END
        
        -- Book the seats
        UPDATE s
        SET s.SeatStatus = 'Booked',
            s.CurrentBookingID = @BookingID,
            s.LastUpdated = GETDATE()
        FROM Seats s
        WHERE s.SeatID IN (SELECT SeatID FROM @Seats)
        
        -- Update passenger seat numbers in the Passengers table
        -- This assumes passengers are already added and need seats assigned
        -- For simplicity, we'll just assign seats sequentially
        
        DECLARE @PassengerIDs TABLE (RowNum INT IDENTITY(1,1), PassengerID INT)
        DECLARE @SeatNumbers TABLE (RowNum INT IDENTITY(1,1), SeatID INT, SeatNumber VARCHAR(20))
        
        INSERT INTO @PassengerIDs (PassengerID)
        SELECT PassengerID
        FROM Passengers
        WHERE BookingID = @BookingID
        AND SeatNumber IS NULL
        
        INSERT INTO @SeatNumbers (SeatID, SeatNumber)
        SELECT s.SeatID, s.SeatNumber
        FROM Seats s
        WHERE s.SeatID IN (SELECT SeatID FROM @Seats)
        ORDER BY s.SeatNumber
        
        -- Get coach numbers for all the seats
        UPDATE p
        SET SeatNumber = (
            SELECT c.CoachNumber + '-' + s.SeatNumber
            FROM Coaches c
            JOIN Seats st ON c.CoachID = st.CoachID
            JOIN @SeatNumbers s ON s.SeatID = st.SeatID
            WHERE s.RowNum = pid.RowNum
        )
        FROM Passengers p
        JOIN @PassengerIDs pid ON p.PassengerID = pid.PassengerID
        WHERE pid.RowNum <= (SELECT COUNT(*) FROM @SeatNumbers)
        
        -- Update booking status to confirmed
        UPDATE Bookings
        SET BookingStatus = 'Confirmed',
            ConfirmationChance = 100
        WHERE BookingID = @BookingID
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END;
GO

-- Example: Populate seats for a coach
-- EXEC PopulateCoachSeats @CoachID = 1;