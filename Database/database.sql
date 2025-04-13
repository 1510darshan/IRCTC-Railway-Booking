use MyRailway




INSERT INTO Stations (StationCode, StationName) VALUES 
('CSTM', 'Chhatrapati Shivaji Terminus'),
('ASR', 'Amritsar Junction'),
('KOTA', 'Kota Junction'),
('GHY', 'Guwahati'),
('TVC', 'Thiruvananthapuram Central'),
('ALD', 'Prayagraj Junction'),
('AGC', 'Agra Cantt'),
('NGP', 'Nagpur Junction'),
('VSKP', 'Visakhapatnam'),
('JP', 'Jaipur Junction');


------------------------------------------------------------------------------------------------------------------------
-- Stations
INSERT INTO Stations (StationCode, StationName) VALUES 
('NDLS', 'New Delhi'),
('HWH', 'Howrah Junction'),
('MAS', 'Chennai Central'),
('BCT', 'Mumbai Central'),
('PNBE', 'Patna Junction'),
('LTT', 'Lokmanya Tilak Terminus'),
('ADI', 'Ahmedabad Junction'),
('BPL', 'Bhopal Junction'),
('BBS', 'Bhubaneswar'),
('CNB', 'Kanpur Central'),
('SDAH', 'Sealdah'),
('PUNE', 'Pune Junction'),
('JAT', 'Jammu Tawi'),
('SBC', 'Bengaluru City Junction'),
('HYB', 'Hyderabad');

-- Trains
INSERT INTO Trains (TrainNumber, TrainName, SourceStationID, DestinationStationID, TrainType, DepartureTime, ArrivalTime, RunningDays, Status) VALUES
('12301', 'Rajdhani Express', 1, 2, 'Rajdhani', '16:55:00', '10:00:00', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', 'Active'),
('12951', 'Mumbai Rajdhani', 1, 4, 'Rajdhani', '16:25:00', '08:35:00', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', 'Active'),
('12259', 'Sealdah Duronto', 1, 11, 'Superfast', '13:15:00', '03:55:00', 'Mon,Wed,Fri', 'Active'),
('12622', 'Tamil Nadu Express', 1, 3, 'Superfast', '22:30:00', '07:15:00', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', 'Active'),
('12306', 'Howrah Rajdhani', 1, 2, 'Rajdhani', '17:15:00', '10:10:00', 'Tue,Thu,Sun', 'Active'),
('12619', 'Matsyagandha Express', 6, 4, 'Express', '15:35:00', '10:25:00', 'Mon,Wed,Fri', 'Active'),
('12723', 'Telangana Express', 1, 15, 'Superfast', '06:30:00', '15:40:00', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', 'Active'),
('12649', 'Karnataka Sampark Kranti', 1, 14, 'Superfast', '11:15:00', '18:40:00', 'Mon,Thu,Sat', 'Active'),
('12025', 'Shatabdi Express', 1, 12, 'Shatabdi', '06:10:00', '11:25:00', 'Mon,Tue,Wed,Thu,Fri,Sat', 'Active'),
('12001', 'Bhopal Shatabdi', 1, 8, 'Shatabdi', '05:55:00', '12:10:00', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', 'Active'),
('12905', 'Porbandar Express', 7, 4, 'Express', '22:45:00', '12:55:00', 'Tue,Fri,Sun', 'Active'),
('12309', 'Rajendra Nagar Rajdhani', 1, 5, 'Rajdhani', '19:55:00', '07:40:00', 'Mon,Wed,Fri,Sun', 'Active'),
('18047', 'Amaravati Express', 14, 3, 'Express', '17:40:00', '08:30:00', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', 'Active'),
('12802', 'Purushottam Express', 12, 2, 'Superfast', '12:55:00', '16:20:00', 'Tue,Wed,Fri,Sun', 'Active'),
('12437', 'Secunderabad Rajdhani', 1, 15, 'Rajdhani', '15:50:00', '13:25:00', 'Mon,Wed,Fri', 'Active');

-- Train Routes
INSERT INTO TrainRoutes (TrainID, StationID, StationSequence, ArrivalTime, DepartureTime, DistanceFromOrigin) VALUES
-- Rajdhani Express (New Delhi to Howrah)
(1, 1, 1, NULL, '16:55:00', 0),
(1, 10, 2, '19:40:00', '19:50:00', 440),
(1, 5, 3, '01:35:00', '01:45:00', 995),
(1, 9, 4, '06:30:00', '06:40:00', 1468),
(1, 2, 5, '10:00:00', NULL, 1531),

-- Mumbai Rajdhani (New Delhi to Mumbai Central)
(2, 1, 1, NULL, '16:25:00', 0),
(2, 8, 2, '22:15:00', '22:20:00', 702),
(2, 12, 3, '03:30:00', '03:35:00', 1192),
(2, 4, 4, '08:35:00', NULL, 1385),

-- Tamil Nadu Express (New Delhi to Chennai Central)
(4, 1, 1, NULL, '22:30:00', 0),
(4, 10, 2, '02:15:00', '02:25:00', 440),
(4, 8, 3, '05:40:00', '05:50:00', 702),
(4, 15, 4, '10:15:00', '10:25:00', 1661),
(4, 14, 5, '15:20:00', '15:30:00', 2007),
(4, 3, 6, '07:15:00', NULL, 2175);

-- Coaches
INSERT INTO Coaches (TrainID, CoachNumber, CoachType, TotalSeats, AvailableSeats) VALUES
-- Rajdhani Express coaches



(3, 'A1', '1A', 24, 20),
(3, 'B1', '2A', 48, 40),
(3, 'B2', '2A', 48, 45),
(3, 'C1', '3A', 72, 60),
(3, 'C2', '3A', 72, 65),
(3, 'C3', '3A', 72, 70),

(5, 'A1', '1A', 24, 20),
(5, 'B1', '2A', 48, 40),
(5, 'B2', '2A', 48, 45),
(5, 'C1', '3A', 72, 60),
(5, 'C2', '3A', 72, 65),
(5, 'C3', '3A', 72, 70),

(6, 'A1', '1A', 24, 20),
(6, 'B1', '2A', 48, 40),
(6, 'B2', '2A', 48, 45),
(6, 'C1', '3A', 72, 60),
(6, 'C2', '3A', 72, 65),
(6, 'C3', '3A', 72, 70),


(7, 'A1', '1A', 24, 20),
(7, 'B1', '2A', 48, 40),
(7, 'B2', '2A', 48, 45),
(7, 'C1', '3A', 72, 60),
(7, 'C2', '3A', 72, 65),
(7, 'C3', '3A', 72, 70),



(8, 'A1', '1A', 24, 22),
(8, 'B1', '2A', 48, 42),
(8, 'B2', '2A', 48, 44),
(8, 'C1', '3A', 72, 65),
(8, 'C2', '3A', 72, 68),
(8, 'S1', 'SL', 80, 75),
(8, 'S2', 'SL', 80, 72),
(8, 'S3', 'SL', 80, 78),
(8, 'S4', 'SL', 80, 76),
(8, 'G1', 'General', 90, 85),

(10, 'A1', '1A', 24, 22),
(10, 'B1', '2A', 48, 42),
(10, 'B2', '2A', 48, 44),
(10, 'C1', '3A', 72, 65),
(10, 'C2', '3A', 72, 68),
(10, 'S1', 'SL', 80, 75),
(10, 'S2', 'SL', 80, 72),
(10, 'S3', 'SL', 80, 78),
(10, 'S4', 'SL', 80, 76),
(10, 'G1', 'General', 90, 85),

(9, 'A1', '1A', 24, 22),
(9, 'B1', '2A', 48, 42),
(9, 'B2', '2A', 48, 44),
(9, 'C1', '3A', 72, 65),
(9, 'C2', '3A', 72, 68),
(9, 'S1', 'SL', 80, 75),
(9, 'S2', 'SL', 80, 72),
(9, 'S3', 'SL', 80, 78),
(9, 'S4', 'SL', 80, 76),
(9, 'G1', 'General', 90, 85),


(11, 'A1', '1A', 24, 20),
(11, 'B1', '2A', 48, 40),
(11, 'B2', '2A', 48, 45),
(11, 'C1', '3A', 72, 60),
(11, 'C2', '3A', 72, 65),
(11, 'C3', '3A', 72, 70);



-- Fares
INSERT INTO Fares (TrainID, CoachType, BaseFare, RatePerKM) VALUES
-- Rajdhani Express fares
(1, '1A', 3000.00, 3.50),
(1, '2A', 1950.00, 2.20),
(1, '3A', 1350.00, 1.60),

-- Mumbai Rajdhani fares
(2, '1A', 3300.00, 3.75),
(2, '2A', 2100.00, 2.35),
(2, '3A', 1450.00, 1.70),

-- Tamil Nadu Express fares
(4, '1A', 3200.00, 3.60),
(4, '2A', 2000.00, 2.25),
(4, '3A', 1400.00, 1.65),
(4, 'SL', 850.00, 0.90),
(4, 'General', 400.00, 0.45);

-- Users
INSERT INTO Users (Username, Email, PasswordHash, FirstName, LastName, MobileNumber, Address, City, State, PinCode) VALUES
('rajesh123', 'rajesh.kumar@example.com', 'hashedpass123', 'Rajesh', 'Kumar', '9876543210', '42 Lajpat Nagar', 'New Delhi', 'Delhi', '110024'),
('priya_sharma', 'priya.sharma@example.com', 'hashedpass456', 'Priya', 'Sharma', '9876543211', '78 Bandra West', 'Mumbai', 'Maharashtra', '400050'),
('amit_patel', 'amit.patel@example.com', 'hashedpass789', 'Amit', 'Patel', '9876543212', '15 Navrangpura', 'Ahmedabad', 'Gujarat', '380009'),
('neha_singh', 'neha.singh@example.com', 'hashedpass101', 'Neha', 'Singh', '9876543213', '23 Salt Lake', 'Kolkata', 'West Bengal', '700091'),
('vijay_reddy', 'vijay.reddy@example.com', 'hashedpass202', 'Vijay', 'Reddy', '9876543214', '56 Jubilee Hills', 'Hyderabad', 'Telangana', '500033'),
('ananya_iyer', 'ananya.iyer@example.com', 'hashedpass303', 'Ananya', 'Iyer', '9876543215', '89 Jayanagar', 'Bengaluru', 'Karnataka', '560041'),
('karthik_nair', 'karthik.nair@example.com', 'hashedpass404', 'Karthik', 'Nair', '9876543216', '32 Adyar', 'Chennai', 'Tamil Nadu', '600020'),
('pooja_joshi', 'pooja.joshi@example.com', 'hashedpass505', 'Pooja', 'Joshi', '9876543217', '67 Aundh', 'Pune', 'Maharashtra', '411007'),
('rahul_verma', 'rahul.verma@example.com', 'hashedpass606', 'Rahul', 'Verma', '9876543218', '45 Gandhi Nagar', 'Bhopal', 'Madhya Pradesh', '462001'),
('admin_irctc', 'admin@irctc.gov.in', 'secureadminpass', 'Admin', 'User', '9876543219', 'IRCTC HQ', 'New Delhi', 'Delhi', '110001');

-- Update admin role
UPDATE Users SET Role = 'Admin' WHERE Username = 'admin_irctc';

-- Bookings
DECLARE @PNRNumber1 VARCHAR(20), @BookingID1 INT
DECLARE @PNRNumber2 VARCHAR(20), @BookingID2 INT
DECLARE @PNRNumber3 VARCHAR(20), @BookingID3 INT
DECLARE @PNRNumber4 VARCHAR(20), @BookingID4 INT
DECLARE @PNRNumber5 VARCHAR(20), @BookingID5 INT

-- Booking 1: Rajdhani Express - Confirmed
EXEC CreateBookingWithPNR 
    @UserID = 1, 
    @TrainID = 1, 
    @SourceStationID = 1, 
    @DestinationStationID = 2, 
    @JourneyDate = '2025-04-20', 
    @CoachType = '2A', 
    @TotalPassengers = 2, 
    @TotalFare = 5300.00, 
    @BookingStatus = 'Confirmed', 
    @ConfirmationChance = 100, 
    @PaymentStatus = 'Paid', 
    @PNRNumber = @PNRNumber1 OUTPUT, 
    @BookingID = @BookingID1 OUTPUT

-- Booking 2: Mumbai Rajdhani - Confirmed
EXEC CreateBookingWithPNR 
    @UserID = 2, 
    @TrainID = 2, 
    @SourceStationID = 1, 
    @DestinationStationID = 4, 
    @JourneyDate = '2025-04-22', 
    @CoachType = '3A', 
    @TotalPassengers = 3, 
    @TotalFare = 6800.00, 
    @BookingStatus = 'Confirmed', 
    @ConfirmationChance = 100, 
    @PaymentStatus = 'Paid', 
    @PNRNumber = @PNRNumber2 OUTPUT, 
    @BookingID = @BookingID2 OUTPUT

-- Booking 3: Tamil Nadu Express - Waiting
EXEC CreateBookingWithPNR 
    @UserID = 3, 
    @TrainID = 4, 
    @SourceStationID = 1, 
    @DestinationStationID = 3, 
    @JourneyDate = '2025-04-25', 
    @CoachType = '1A', 
    @TotalPassengers = 2, 
    @TotalFare = 10900.00, 
    @BookingStatus = 'Waiting', 
    @ConfirmationChance = 40, 
    @PaymentStatus = 'Paid', 
    @PNRNumber = @PNRNumber3 OUTPUT, 
    @BookingID = @BookingID3 OUTPUT

-- Booking 4: Rajdhani Express - RAC
EXEC CreateBookingWithPNR 
    @UserID = 4, 
    @TrainID = 1, 
    @SourceStationID = 1, 
    @DestinationStationID = 2, 
    @JourneyDate = '2025-04-20', 
    @CoachType = '3A', 
    @TotalPassengers = 1, 
    @TotalFare = 2950.00, 
    @BookingStatus = 'RAC', 
    @ConfirmationChance = 70, 
    @PaymentStatus = 'Paid', 
    @PNRNumber = @PNRNumber4 OUTPUT, 
    @BookingID = @BookingID4 OUTPUT

-- Booking 5: Mumbai Rajdhani - Cancelled
EXEC CreateBookingWithPNR 
    @UserID = 5, 
    @TrainID = 2, 
    @SourceStationID = 1, 
    @DestinationStationID = 4, 
    @JourneyDate = '2025-04-22', 
    @CoachType = '2A', 
    @TotalPassengers = 2, 
    @TotalFare = 6250.00, 
    @BookingStatus = 'Cancelled', 
    @ConfirmationChance = 0, 
    @PaymentStatus = 'Refunded', 
    @PNRNumber = @PNRNumber5 OUTPUT, 
    @BookingID = @BookingID5 OUTPUT

-- Update the 5th booking to Cancelled
UPDATE Bookings SET BookingStatus = 'Cancelled' WHERE BookingID = @BookingID5;

-- Passengers
-- For Booking 1
INSERT INTO Passengers (BookingID, Name, Age, Gender, SeatNumber, IDProofType, IDProofNumber) VALUES
(@BookingID1, 'Rajesh Kumar', 35, 'Male', 'B1-22', 'Aadhar', '123456789012'),
(@BookingID1, 'Meera Kumar', 32, 'Female', 'B1-23', 'Passport', 'P1234567');

-- For Booking 2
INSERT INTO Passengers (BookingID, Name, Age, Gender, SeatNumber, IDProofType, IDProofNumber) VALUES
(@BookingID2, 'Priya Sharma', 29, 'Female', 'C2-45', 'Aadhar', '234567890123'),
(@BookingID2, 'Rahul Sharma', 34, 'Male', 'C2-46', 'PAN', 'ABCDE1234F'),
(@BookingID2, 'Riya Sharma', 8, 'Female', 'C2-47', 'Aadhar', '345678901234');

-- For Booking 3
INSERT INTO Passengers (BookingID, Name, Age, Gender, SeatNumber, IDProofType, IDProofNumber) VALUES
(@BookingID3, 'Amit Patel', 42, 'Male', NULL, 'VoterID', 'VOTER12345'),
(@BookingID3, 'Shalini Patel', 39, 'Female', NULL, 'Aadhar', '456789012345');

-- For Booking 4
INSERT INTO Passengers (BookingID, Name, Age, Gender, SeatNumber, IDProofType, IDProofNumber) VALUES
(@BookingID4, 'Neha Singh', 27, 'Female', 'C3-15', 'Passport', 'P2345678');

-- For Booking 5
INSERT INTO Passengers (BookingID, Name, Age, Gender, SeatNumber, IDProofType, IDProofNumber) VALUES
(@BookingID5, 'Vijay Reddy', 45, 'Male', NULL, 'Aadhar', '567890123456'),
(@BookingID5, 'Lakshmi Reddy', 41, 'Female', NULL, 'PAN', 'FGHIJ5678K');

-- Payments
INSERT INTO Payments (BookingID, Amount, PaymentDate, PaymentMethod, TransactionID, Status) VALUES
(@BookingID1, 5300.00, '2025-03-15 14:35:22', 'CreditCard', 'TXN123456789', 'Success'),
(@BookingID2, 6800.00, '2025-03-18 09:22:45', 'UPI', 'UPI987654321', 'Success'),
(@BookingID3, 10900.00, '2025-03-20 16:17:30', 'DebitCard', 'TXN234567890', 'Success'),
(@BookingID4, 2950.00, '2025-03-15 12:05:17', 'NetBanking', 'NET345678901', 'Success'),
(@BookingID5, 6250.00, '2025-03-18 11:45:33', 'Wallet', 'WAL456789012', 'Refunded');

-- LiveTrainStatus
INSERT INTO LiveTrainStatus (TrainID, StatusDate, CurrentStationID, NextStationID, DelayMinutes, CurrentSpeed, PlatformNumber, ExpectedArrivalTime) VALUES
(1, '2025-04-09', 10, 5, 15, 110, '3', '01:50:00'),
(2, '2025-04-09', 1, 8, 0, 0, '5', '22:15:00'),
(4, '2025-04-09', 8, 15, 25, 95, '2', '10:50:00');

-- AlternateTrains for Waiting bookings
INSERT INTO AlternateTrains (BookingID, AlternateTrainID, AvailableSeats, DepartureDifference, TimeDifference, PriceDifference, SuggestionReason) VALUES
(@BookingID3, 7, 5, 480, 60, -1200.00, 'Higher availability in alternative route'),
(@BookingID3, 15, 8, -120, 30, 900.00, 'Premium train with better amenities');








SELECT 
    t.TrainID,
    t.TrainNumber,
    t.TrainName,
    t.TrainType,
    t.DepartureTime,
    t.ArrivalTime,
    t.RunningDays,
    t.Status,
    src.StationName AS SourceStation,
    src.StationCode AS SourceStationCode,
    dest.StationName AS DestinationStation,
    dest.StationCode AS DestinationStationCode
FROM 
    Trains t
JOIN 
    Stations src ON t.SourceStationID = src.StationID
JOIN 
    Stations dest ON t.DestinationStationID = dest.StationID
WHERE 
    src.StationName = 'New Delhi'
    AND dest.StationName = 'Howrah Junction'
    AND t.Status = 'Active';


	select * from Stations
	select * from TrainRoutes


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
                            src.StationName = 'New Delhi'
                            AND dest.StationName = 'Howrah Junction'
                            AND t.Status = 'Active'
                            -- You can add condition for travel date
                            -- AND CHARINDEX(DATENAME(WEEKDAY, @TravelDate), t.RunningDays) > 0
                    )
                    SELECT 
                        ti.*,
                        (
                            SELECT STRING_AGG(
                                CONCAT(
                                    c.CoachType, ': ', 
                                    c.AvailableSeats, ' seats, ₹', 
                                    CAST(f.BaseFare AS VARCHAR)
                                ), 
                                ' | '
                            )
                            FROM Coaches c
                            JOIN Fares f ON c.TrainID = f.TrainID AND c.CoachType = f.CoachType
                            WHERE c.TrainID = ti.TrainID
                        ) AS AvailableCoachesAndFares
                    FROM 
                        TrainInfo ti
                    ORDER BY 
                        ti.DepartureTime;



