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
    TrainType VARCHAR(20) CHECK (TrainType IN ('Express', 'Mail', 'Superfast', 'Shatabdi', 'Rajdhani')),
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