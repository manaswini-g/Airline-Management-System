drop database if exists Airlines_DB_Team7;
create database if not exists Airlines_DB_Team7;
USE Airlines_DB_Team7;
SHOW DATABASES;
select database();
show tables;
-- Complex Queries for Use Case

-- Table 1: Airports (Details of airports worldwide) 
CREATE TABLE Airports (
    airport_id INT PRIMARY KEY NOT NULL,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    IATA_code CHAR(3) UNIQUE NOT NULL,
    ICAO_code CHAR(4) UNIQUE,
    timezone VARCHAR(50) NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL
);

-- Table 2: Terminals (Terminals within an airport) 
CREATE TABLE Terminals (
    terminal_id INT PRIMARY KEY NOT NULL,
    airport_id INT NOT NULL,
    name VARCHAR(10) NOT NULL,
    FOREIGN KEY (airport_id) REFERENCES Airports(airport_id)
);

-- Table 3: Gates (Gates within terminals) 
CREATE TABLE Gates (
    gate_id INT PRIMARY KEY NOT NULL,
    terminal_id INT NOT NULL,
    gate_number VARCHAR(10) NOT NULL,
    FOREIGN KEY (terminal_id) REFERENCES Terminals(terminal_id)
);

-- Table 4: Aircrafts (Aircraft details) 
CREATE TABLE Aircrafts (
    aircraft_id INT PRIMARY KEY NOT NULL,
    model VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    registration_number VARCHAR(20) UNIQUE NOT NULL,
    range_km INT,
    status ENUM('Active', 'Maintenance', 'Retired') NOT NULL
);

-- Table 5: Maintenance_Records (Records of aircraft maintenance) 
CREATE TABLE Maintenance_Records (
    maintenance_id INT PRIMARY KEY NOT NULL,
    aircraft_id INT NOT NULL,
    maintenance_date DATE NOT NULL,
    description TEXT,
    status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled'),
    next_due_date DATE,
    FOREIGN KEY (aircraft_id) REFERENCES Aircrafts(aircraft_id)
);

-- Table 6: Employees (Employee details with various roles)
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    status ENUM('Active', 'On Leave', 'Retired', 'Terminated') NOT NULL
);

-- Table 7: Crew (Subset of employees assigned to flight operations) 
CREATE TABLE Crew (
    crew_id INT PRIMARY KEY NOT NULL,
    employee_id INT NOT NULL UNIQUE,
    role ENUM('Pilot', 'Co-Pilot', 'Cabin Crew') NOT NULL,
    license_number VARCHAR(50) UNIQUE,
    certification_expiry DATE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Table 8: Routes (Standard routes between two airports)
CREATE TABLE Routes (
    route_id INT PRIMARY KEY NOT NULL,
    departure_airport_id INT NOT NULL,
    arrival_airport_id INT NOT NULL,
    distance_km DECIMAL(6,2) NOT NULL CHECK (distance_km > 0),
    flight_time_minutes INT NOT NULL,
    FOREIGN KEY (departure_airport_id) REFERENCES Airports(airport_id),
    FOREIGN KEY (arrival_airport_id) REFERENCES Airports(airport_id)
);

-- Table 9: Flights (Scheduled flights with route and aircraft) 
CREATE TABLE Flights (
    flight_id INT PRIMARY KEY NOT NULL,
    flight_number VARCHAR(10) UNIQUE NOT NULL,
    route_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    scheduled_departure_time TIME NOT NULL,
    scheduled_arrival_time TIME NOT NULL,
    status ENUM('Scheduled', 'Cancelled', 'Inactive') NOT NULL,
    FOREIGN KEY (route_id) REFERENCES Routes(route_id),
    FOREIGN KEY (aircraft_id) REFERENCES Aircrafts(aircraft_id)
);

-- Table 10: Flight_Instances (Occurrences of a flight on a specific date) 
CREATE TABLE Flight_Instances (
    flight_instance_id INT PRIMARY KEY NOT NULL,
    flight_id INT NOT NULL,
    flight_date DATE NOT NULL,
    gate_id INT,
    actual_departure_time DATETIME,
    actual_arrival_time DATETIME,
    status ENUM('On Time', 'Delayed', 'Cancelled', 'Completed') NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
    FOREIGN KEY (gate_id) REFERENCES Gates(gate_id)
);

-- Table 11: Crew_Assignments (Assigning crew to flight instances) 
CREATE TABLE Crew_Assignments (
    assignment_id INT PRIMARY KEY NOT NULL,
    crew_id INT NOT NULL,
    flight_instance_id INT NOT NULL,
    assigned_role VARCHAR(50) NOT NULL,
    assignment_date DATE NOT NULL,
    FOREIGN KEY (crew_id) REFERENCES Crew(crew_id),
    FOREIGN KEY (flight_instance_id) REFERENCES Flight_Instances(flight_instance_id)
);

-- Table 12: Passengers (Passenger personal details) 
CREATE TABLE Passengers (
    passenger_id INT PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    passport_number VARCHAR(20) UNIQUE NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    frequent_flyer_number VARCHAR(20) UNIQUE
);

-- Table 13: Loyalty_Program (Frequent flyer program details) 
CREATE TABLE Loyalty_Program (
    loyalty_id INT PRIMARY KEY NOT NULL,
    passenger_id INT NOT NULL UNIQUE,
    membership_tier ENUM('Silver', 'Gold', 'Platinum', 'Diamond') NOT NULL,
    total_miles INT NOT NULL DEFAULT 0,
    enrollment_date DATE NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id)
);

-- Table 14: Bookings (Flight reservations) 
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY NOT NULL,
    passenger_id INT NOT NULL,
    flight_instance_id INT NOT NULL,
    booking_date DATE NOT NULL,
    booking_status ENUM('Confirmed', 'Cancelled', 'Waitlisted') NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id),
    FOREIGN KEY (flight_instance_id) REFERENCES Flight_Instances(flight_instance_id)
);

-- Table 15: Tickets (Issued tickets with seat assignments) 
CREATE TABLE Tickets (
    ticket_id INT PRIMARY KEY NOT NULL,
    booking_id INT NOT NULL,
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    seat_number VARCHAR(5) NOT NULL,
    class ENUM('Economy', 'Business', 'First') NOT NULL,
    issue_date DATE NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- Table 16: Payments (Payment transactions for bookings) 
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY NOT NULL,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_method ENUM('Credit Card', 'Debit Card', 'PayPal', 'UPI') NOT NULL,
    payment_date DATE NOT NULL,
    transaction_status ENUM('Paid', 'Pending', 'Failed', 'Refunded') NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- Table 17: CheckIn (Passenger check-in records) 
CREATE TABLE CheckIn (
    checkin_id INT PRIMARY KEY NOT NULL,
    ticket_id INT NOT NULL,
    checkin_time DATETIME NOT NULL,
    boarding_pass_number VARCHAR(20) UNIQUE NOT NULL,
    gate_number VARCHAR(10),
    status ENUM('Checked-In', 'Not Checked-In') NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);

-- Table 18: Baggage (Luggage details) 
CREATE TABLE Baggage (
    baggage_id INT PRIMARY KEY NOT NULL,
    ticket_id INT NOT NULL,
    weight DECIMAL(5,2) NOT NULL,
    tag_number VARCHAR(20) UNIQUE NOT NULL,
    status ENUM('Checked-In', 'Lost', 'Delivered', 'In Transit') NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);

-- Sample Data Insertion

-- Insert data into Airports
INSERT INTO Airports VALUES
(1, 'John F. Kennedy International Airport', 'New York', 'USA', 'JFK', 'KJFK', 'America/New_York', 40.6413, -73.7781),
(2, 'Heathrow Airport', 'London', 'UK', 'LHR', 'EGLL', 'Europe/London', 51.4700, -0.4543),
(3, 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'India', 'BOM', 'VABB', 'Asia/Kolkata', 19.0887, 72.8679),
(4, 'Charles de Gaulle Airport', 'Paris', 'France', 'CDG', 'LFPG', 'Europe/Paris', 49.0097, 2.5479),
(5, 'Dubai International Airport', 'Dubai', 'UAE', 'DXB', 'OMDB', 'Asia/Dubai', 25.2532, 55.3657),
(6, 'Los Angeles International Airport', 'Los Angeles', 'USA', 'LAX', 'KLAX', 'America/Los_Angeles', 33.9416, -118.4085),
(7, 'Indira Gandhi International Airport', 'Delhi', 'India', 'DEL', 'VIDP', 'Asia/Kolkata', 28.5562, 77.1000),
(8, 'Singapore Changi Airport', 'Singapore', 'Singapore', 'SIN', 'WSSS', 'Asia/Singapore', 1.3644, 103.9915),
(9, 'Sydney Airport', 'Sydney', 'Australia', 'SYD', 'YSSY', 'Australia/Sydney', -33.9399, 151.1753),
(10, 'Haneda Airport', 'Tokyo', 'Japan', 'HND', 'RJTT', 'Asia/Tokyo', 35.5494, 139.7798);

-- Insert data into Terminals
INSERT INTO Terminals VALUES
(1, 1, 'T1'), (2, 1, 'T2'), (3, 1, 'T4'), 
(4, 2, 'T2'), (5, 2, 'T3'), (6, 2, 'T5'),
(7, 3, 'T1'), (8, 3, 'T2'), 
(9, 4, 'T1'), (10, 4, 'T2'), (11, 4, 'T3'),
(12, 5, 'T1'), (13, 5, 'T2'), (14, 5, 'T3'),
(15, 6, 'T1'), (16, 6, 'T2'), (17, 6, 'TBIT'),
(18, 7, 'T1'), (19, 7, 'T2'), (20, 7, 'T3');

-- Insert data into Gates
INSERT INTO Gates VALUES
(1, 1, 'A1'), (2, 1, 'A2'), (3, 1, 'A3'), (4, 1, 'A4'), (5, 1, 'A5'),
(6, 2, 'B1'), (7, 2, 'B2'), (8, 2, 'B3'), (9, 2, 'B4'), (10, 2, 'B5'),
(11, 3, 'C1'), (12, 3, 'C2'), (13, 3, 'C3'), (14, 3, 'C4'), (15, 3, 'C5'),
(16, 4, 'D1'), (17, 4, 'D2'), (18, 4, 'D3'), (19, 4, 'D4'), (20, 4, 'D5'),
(21, 5, 'E1'), (22, 5, 'E2'), (23, 5, 'E3'), (24, 5, 'E4'), (25, 5, 'E5');

-- Insert data into Aircrafts
INSERT INTO Aircrafts VALUES
(1, 'Boeing 737-800', 'Boeing', 189, 'N12345', 5400, 'Active'),
(2, 'Airbus A320', 'Airbus', 180, 'N23456', 5700, 'Active'),
(3, 'Boeing 787-9 Dreamliner', 'Boeing', 290, 'N34567', 14140, 'Active'),
(4, 'Airbus A350-900', 'Airbus', 325, 'N45678', 15000, 'Active'),
(5, 'Boeing 777-300ER', 'Boeing', 396, 'N56789', 13650, 'Maintenance'),
(6, 'Airbus A380', 'Airbus', 525, 'N67890', 15200, 'Active'),
(7, 'Embraer E190', 'Embraer', 100, 'N78901', 4445, 'Active'),
(8, 'Bombardier CRJ900', 'Bombardier', 90, 'N89012', 3400, 'Active'),
(9, 'Boeing 747-8', 'Boeing', 467, 'N90123', 14815, 'Retired'),
(10, 'Airbus A321neo', 'Airbus', 240, 'N01234', 7400, 'Active');

-- Insert data into Maintenance_Records
INSERT INTO Maintenance_Records VALUES
(1, 1, '2023-10-15', 'Routine check', 'Completed', '2024-01-15'),
(2, 1, '2024-01-10', 'Engine inspection', 'Completed', '2024-04-10'),
(3, 2, '2023-11-20', 'Avionics update', 'Completed', '2024-02-20'),
(4, 3, '2023-12-05', 'Cabin refurbishment', 'Completed', '2024-06-05'),
(5, 4, '2024-01-20', 'Landing gear maintenance', 'Completed', '2024-04-20'),
(6, 5, '2024-02-01', 'Major engine overhaul', 'In Progress', NULL),
(7, 6, '2023-12-15', 'Wing inspection', 'Completed', '2024-03-15'),
(8, 7, '2024-01-05', 'Hydraulic system check', 'Completed', '2024-04-05'),
(9, 8, '2023-11-10', 'APU service', 'Completed', '2024-02-10'),
(10, 10, '2023-12-20', 'Paint job', 'Completed', '2025-12-20');

-- Insert data into Employees
INSERT INTO Employees VALUES
(1, 'John', 'Smith', 'john.smith@airline.com', '1234567890', 'Pilot', '2015-06-10', 'Active'),
(2, 'Emily', 'Johnson', 'emily.johnson@airline.com', '2345678901', 'Co-Pilot', '2018-03-15', 'Active'),
(3, 'Michael', 'Williams', 'michael.williams@airline.com', '3456789012', 'Flight Attendant', '2019-11-20', 'Active'),
(4, 'Sarah', 'Brown', 'sarah.brown@airline.com', '4567890123', 'Flight Attendant', '2020-05-05', 'Active'),
(5, 'David', 'Jones', 'david.jones@airline.com', '5678901234', 'Pilot', '2016-09-12', 'Active'),
(6, 'Jennifer', 'Garcia', 'jennifer.garcia@airline.com', '6789012345', 'Co-Pilot', '2019-02-28', 'On Leave'),
(7, 'Robert', 'Miller', 'robert.miller@airline.com', '7890123456', 'Flight Attendant', '2021-07-15', 'Active'),
(8, 'Lisa', 'Davis', 'lisa.davis@airline.com', '8901234567', 'Flight Attendant', '2018-04-10', 'Active'),
(9, 'James', 'Rodriguez', 'james.rodriguez@airline.com', '9012345678', 'Pilot', '2017-12-01', 'Active'),
(10, 'Patricia', 'Martinez', 'patricia.martinez@airline.com', '0123456789', 'Co-Pilot', '2020-08-20', 'Active'),
(11, 'Thomas', 'Hernandez', 'thomas.hernandez@airline.com', '1122334455', 'Flight Attendant', '2022-01-10', 'Active'),
(12, 'Elizabeth', 'Lopez', 'elizabeth.lopez@airline.com', '2233445566', 'Flight Attendant', '2021-03-15', 'Active'),
(13, 'Daniel', 'Gonzalez', 'daniel.gonzalez@airline.com', '3344556677', 'Pilot', '2019-06-20', 'Active'),
(14, 'Nancy', 'Wilson', 'nancy.wilson@airline.com', '4455667788', 'Co-Pilot', '2020-09-05', 'Active'),
(15, 'Matthew', 'Anderson', 'matthew.anderson@airline.com', '5566778899', 'Flight Attendant', '2022-02-10', 'Active');

-- Insert data into Crew
INSERT INTO Crew VALUES
(1, 1, 'Pilot', 'P123456', '2025-12-31'),
(2, 2, 'Co-Pilot', 'CP234567', '2025-11-30'),
(3, 3, 'Cabin Crew', 'CC345678', '2024-10-15'),
(4, 4, 'Cabin Crew', 'CC456789', '2024-09-20'),
(5, 5, 'Pilot', 'P567890', '2026-01-15'),
(6, 6, 'Co-Pilot', 'CP678901', '2025-08-10'),
(7, 7, 'Cabin Crew', 'CC789012', '2024-07-25'),
(8, 8, 'Cabin Crew', 'CC890123', '2024-06-30'),
(9, 9, 'Pilot', 'P901234', '2026-03-20'),
(10, 10, 'Co-Pilot', 'CP012345', '2025-10-15'),
(11, 11, 'Cabin Crew', 'CC112233', '2024-12-10'),
(12, 12, 'Cabin Crew', 'CC223344', '2024-11-05'),
(13, 13, 'Pilot', 'P334455', '2026-02-28'),
(14, 14, 'Co-Pilot', 'CP445566', '2025-09-20'),
(15, 15, 'Cabin Crew', 'CC556677', '2024-08-15');

-- Insert data into Routes 
INSERT INTO Routes VALUES
(1, 1, 2, 5567.00, 420),   -- JFK to LHR
(2, 2, 1, 5567.00, 420),   -- LHR to JFK
(3, 1, 3, 9999.99, 840),  -- JFK to BOM 
(4, 3, 1, 9999.99, 840),   -- BOM to JFK 
(5, 2, 4, 340.00, 60),     -- LHR to CDG
(6, 4, 2, 340.00, 60),     -- CDG to LHR
(7, 3, 5, 2000.00, 180),   -- BOM to DXB
(8, 5, 3, 2000.00, 180),    -- DXB to BOM
(9, 1, 6, 3970.00, 300),    -- JFK to LAX
(10, 6, 1, 3970.00, 300),   -- LAX to JFK
(11, 3, 7, 1150.00, 120),   -- BOM to DEL
(12, 7, 3, 1150.00, 120),   -- DEL to BOM
(13, 5, 8, 3800.00, 270),   -- DXB to SIN
(14, 8, 5, 3800.00, 270),   -- SIN to DXB
(15, 6, 9, 9999.99, 780),   -- LAX to SYD 
(16, 9, 6, 9999.99, 780),   -- SYD to LAX 
(17, 8, 10, 5300.00, 360),  -- SIN to HND
(18, 10, 8, 5300.00, 360),  -- HND to SIN
(19, 7, 10, 5800.00, 420),  -- DEL to HND
(20, 10, 7, 5800.00, 420);  -- HND to DEL

-- Insert data into Flights
INSERT INTO Flights VALUES
(1, 'AA100', 1, 3, '09:00:00', '17:00:00', 'Scheduled'),  -- JFK-LHR
(2, 'AA101', 2, 3, '11:00:00', '19:00:00', 'Scheduled'),  -- LHR-JFK
(3, 'AI200', 3, 4, '22:00:00', '12:00:00', 'Scheduled'),  -- JFK-BOM
(4, 'AI201', 4, 4, '02:00:00', '16:00:00', 'Scheduled'),   -- BOM-JFK
(5, 'BA300', 5, 2, '07:30:00', '08:30:00', 'Scheduled'),   -- LHR-CDG
(6, 'BA301', 6, 2, '09:30:00', '10:30:00', 'Scheduled'),   -- CDG-LHR
(7, 'EK400', 7, 6, '08:00:00', '11:00:00', 'Scheduled'),    -- BOM-DXB
(8, 'EK401', 8, 6, '12:00:00', '15:00:00', 'Scheduled'),    -- DXB-BOM
(9, 'DL500', 9, 1, '06:00:00', '12:00:00', 'Scheduled'),    -- JFK-LAX
(10, 'DL501', 10, 1, '13:00:00', '19:00:00', 'Scheduled'), -- LAX-JFK
(11, '6E600', 11, 7, '10:00:00', '12:00:00', 'Scheduled'),  -- BOM-DEL
(12, '6E601', 12, 7, '13:00:00', '15:00:00', 'Scheduled'),  -- DEL-BOM
(13, 'SQ700', 13, 4, '03:00:00', '09:30:00', 'Scheduled'),  -- DXB-SIN
(14, 'SQ701', 14, 4, '10:30:00', '17:00:00', 'Scheduled'),  -- SIN-DXB
(15, 'QF800', 15, 3, '22:00:00', '12:00:00', 'Scheduled'),  -- LAX-SYD
(16, 'QF801', 16, 3, '14:00:00', '04:00:00', 'Scheduled'), -- SYD-LAX
(17, 'JL900', 17, 10, '09:00:00', '15:00:00', 'Scheduled'), -- SIN-HND
(18, 'JL901', 18, 10, '16:00:00', '22:00:00', 'Scheduled'), -- HND-SIN
(19, 'NH1000', 19, 10, '18:00:00', '02:00:00', 'Scheduled'),-- DEL-HND
(20, 'NH1001', 20, 10, '03:00:00', '11:00:00', 'Scheduled');-- HND-DEL

-- Insert data into Flight_Instances (for current date and previous 30 days)
INSERT INTO Flight_Instances VALUES
-- Flight instances for today (some delayed, some on time)
(1, 1, CURDATE(), 1, CONCAT(CURDATE(), ' 09:30:00'), CONCAT(CURDATE(), ' 17:30:00'), 'Delayed'),  -- AA100 delayed
(2, 2, CURDATE(), 6, CONCAT(CURDATE(), ' 11:00:00'), CONCAT(CURDATE(), ' 19:00:00'), 'On Time'),  -- AA101 on time
(3, 5, CURDATE(), 16, CONCAT(CURDATE(), ' 08:00:00'), CONCAT(CURDATE(), ' 09:00:00'), 'Delayed'), -- BA300 delayed
(4, 7, CURDATE(), 21, CONCAT(CURDATE(), ' 08:00:00'), CONCAT(CURDATE(), ' 11:00:00'), 'On Time'), -- EK400 on time
(5, 11, CURDATE(), 11, CONCAT(CURDATE(), ' 10:30:00'), CONCAT(CURDATE(), ' 12:30:00'), 'Delayed'), -- 6E600 delayed

-- Flight instances for yesterday (completed)
(6, 1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 1, CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 09:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 17:00:00'), 'Completed'),
(7, 3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 3, CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 22:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 12:00:00'), 'Completed'),
(8, 7, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 21, CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 08:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 11:00:00'), 'Completed'),
(9, 11, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 11, CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 10:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 12:00:00'), 'Completed'),
(10, 15, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 15, CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 22:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 12:00:00'), 'Completed'),

-- Flight instances for past 30 days (random statuses)
(11, 1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 1, CONCAT(DATE_SUB(CURDATE(), INTERVAL 2 DAY), ' 09:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 2 DAY), ' 17:00:00'), 'Completed'),
(12, 2, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 6, CONCAT(DATE_SUB(CURDATE(), INTERVAL 3 DAY), ' 11:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 3 DAY), ' 19:00:00'), 'Completed'),
(13, 3, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 3, CONCAT(DATE_SUB(CURDATE(), INTERVAL 5 DAY), ' 22:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 5 DAY), ' 12:00:00'), 'Completed'),
(14, 4, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 8, CONCAT(DATE_SUB(CURDATE(), INTERVAL 7 DAY), ' 02:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 7 DAY), ' 16:00:00'), 'Completed'),
(15, 5, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 16, CONCAT(DATE_SUB(CURDATE(), INTERVAL 10 DAY), ' 07:30:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 10 DAY), ' 08:30:00'), 'Completed'),
(16, 6, DATE_SUB(CURDATE(), INTERVAL 12 DAY), 17, CONCAT(DATE_SUB(CURDATE(), INTERVAL 12 DAY), ' 09:30:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 12 DAY), ' 10:30:00'), 'Completed'),
(17, 7, DATE_SUB(CURDATE(), INTERVAL 15 DAY), 21, CONCAT(DATE_SUB(CURDATE(), INTERVAL 15 DAY), ' 08:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 15 DAY), ' 11:00:00'), 'Completed'),
(18, 8, DATE_SUB(CURDATE(), INTERVAL 18 DAY), 22, CONCAT(DATE_SUB(CURDATE(), INTERVAL 18 DAY), ' 12:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 18 DAY), ' 15:00:00'), 'Completed'),
(19, 9, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 23, CONCAT(DATE_SUB(CURDATE(), INTERVAL 20 DAY), ' 06:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 20 DAY), ' 12:00:00'), 'Completed'),
(20, 10, DATE_SUB(CURDATE(), INTERVAL 22 DAY), 24, CONCAT(DATE_SUB(CURDATE(), INTERVAL 22 DAY), ' 13:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 22 DAY), ' 19:00:00'), 'Completed'),
(21, 11, DATE_SUB(CURDATE(), INTERVAL 25 DAY), 11, CONCAT(DATE_SUB(CURDATE(), INTERVAL 25 DAY), ' 10:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 25 DAY), ' 12:00:00'), 'Completed'),
(22, 12, DATE_SUB(CURDATE(), INTERVAL 28 DAY), 12, CONCAT(DATE_SUB(CURDATE(), INTERVAL 28 DAY), ' 13:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 28 DAY), ' 15:00:00'), 'Completed'),
(23, 13, DATE_SUB(CURDATE(), INTERVAL 29 DAY), 13, CONCAT(DATE_SUB(CURDATE(), INTERVAL 29 DAY), ' 03:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 29 DAY), ' 09:30:00'), 'Completed'),
(24, 14, DATE_SUB(CURDATE(), INTERVAL 30 DAY), 14, CONCAT(DATE_SUB(CURDATE(), INTERVAL 30 DAY), ' 10:30:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 30 DAY), ' 17:00:00'), 'Completed');

-- Insert data into Crew_Assignments
INSERT INTO Crew_Assignments VALUES
-- Assignments for today's flights
(1, 1, 1, 'Pilot', CURDATE()),
(2, 2, 1, 'Co-Pilot', CURDATE()),
(3, 3, 1, 'Cabin Crew', CURDATE()),
(4, 4, 1, 'Cabin Crew', CURDATE()),
(5, 5, 2, 'Pilot', CURDATE()),
(6, 6, 2, 'Co-Pilot', CURDATE()),
(7, 7, 2, 'Cabin Crew', CURDATE()),
(8, 8, 2, 'Cabin Crew', CURDATE()),
(9, 9, 3, 'Pilot', CURDATE()),
(10, 10, 3, 'Co-Pilot', CURDATE()),
(11, 11, 3, 'Cabin Crew', CURDATE()),
(12, 12, 3, 'Cabin Crew', CURDATE()),
(13, 13, 4, 'Pilot', CURDATE()),
(14, 14, 4, 'Co-Pilot', CURDATE()),
(15, 15, 4, 'Cabin Crew', CURDATE()),

-- Assignments for past flights
(16, 1, 6, 'Pilot', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(17, 2, 6, 'Co-Pilot', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(18, 3, 6, 'Cabin Crew', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(19, 4, 6, 'Cabin Crew', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(20, 5, 7, 'Pilot', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(21, 6, 7, 'Co-Pilot', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(22, 7, 7, 'Cabin Crew', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(23, 8, 7, 'Cabin Crew', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(24, 9, 8, 'Pilot', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(25, 10, 8, 'Co-Pilot', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(26, 11, 8, 'Cabin Crew', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(27, 12, 8, 'Cabin Crew', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(28, 13, 9, 'Pilot', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(29, 14, 9, 'Co-Pilot', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(30, 15, 9, 'Cabin Crew', DATE_SUB(CURDATE(), INTERVAL 1 DAY));

-- Insert data into Passengers
INSERT INTO Passengers VALUES
(1, 'Rajesh', 'Kumar', 'rajesh.kumar@example.com', '9191919191', 'A12345678', 'India', '1980-05-15', 'FF1001'),
(2, 'Priya', 'Sharma', 'priya.sharma@example.com', '9292929292', 'B23456789', 'India', '1985-08-20', 'FF1002'),
(3, 'Amit', 'Patel', 'amit.patel@example.com', '9393939393', 'C34567890', 'India', '1978-11-10', 'FF1003'),
(4, 'John', 'Smith', 'john.smith@example.com', '1212121212', 'D45678901', 'USA', '1975-04-25', 'FF2001'),
(5, 'Emily', 'Johnson', 'emily.johnson@example.com', '1313131313', 'E56789012', 'USA', '1988-07-30', 'FF2002'),
(6, 'Michael', 'Williams', 'michael.williams@example.com', '1414141414', 'F67890123', 'UK', '1982-09-12', 'FF3001'),
(7, 'Sarah', 'Brown', 'sarah.brown@example.com', '1515151515', 'G78901234', 'UK', '1990-01-05', 'FF3002'),
(8, 'David', 'Jones', 'david.jones@example.com', '1616161616', 'H89012345', 'Australia', '1976-03-18', 'FF4001'),
(9, 'Jennifer', 'Garcia', 'jennifer.garcia@example.com', '1717171717', 'I90123456', 'USA', '1984-06-22', 'FF2003'),
(10, 'Robert', 'Miller', 'robert.miller@example.com', '1818181818', 'J01234567', 'Canada', '1979-12-08', 'FF5001'),
(11, 'Lisa', 'Davis', 'lisa.davis@example.com', '1919191919', 'K12345678', 'UK', '1987-02-14', 'FF3003'),
(12, 'James', 'Rodriguez', 'james.rodriguez@example.com', '2020202020', 'L23456789', 'USA', '1981-10-30', 'FF2004'),
(13, 'Patricia', 'Martinez', 'patricia.martinez@example.com', '2121212121', 'M34567890', 'Spain', '1983-04-05', 'FF6001'),
(14, 'Thomas', 'Hernandez', 'thomas.hernandez@example.com', '2222222222', 'N45678901', 'Mexico', '1977-07-20', 'FF7001'),
(15, 'Elizabeth', 'Lopez', 'elizabeth.lopez@example.com', '2323232323', 'O56789012', 'USA', '1989-09-15', 'FF2005'),
(16, 'Daniel', 'Gonzalez', 'daniel.gonzalez@example.com', '2424242424', 'P67890123', 'Argentina', '1980-11-25', 'FF8001'),
(17, 'Nancy', 'Wilson', 'nancy.wilson@example.com', '2525252525', 'Q78901234', 'UK', '1974-08-10', 'FF3004'),
(18, 'Matthew', 'Anderson', 'matthew.anderson@example.com', '2626262626', 'R89012345', 'Australia', '1986-05-30', 'FF4002'),
(19, 'Samantha', 'Thomas', 'samantha.thomas@example.com', '2727272727', 'S90123456', 'USA', '1992-03-12', 'FF2006'),
(20, 'Christopher', 'Taylor', 'christopher.taylor@example.com', '2828282828', 'T01234567', 'Canada', '1973-12-18', 'FF5002');

-- Insert data into Loyalty_Program
INSERT INTO Loyalty_Program VALUES
(1, 1, 'Gold', 45000, '2018-05-10'),
(2, 2, 'Silver', 25000, '2019-08-15'),
(3, 3, 'Platinum', 75000, '2017-11-20'),
(4, 4, 'Diamond', 120000, '2015-04-25'),
(5, 5, 'Gold', 50000, '2018-07-30'),
(6, 6, 'Silver', 20000, '2020-09-12'),
(7, 7, 'Gold', 48000, '2019-01-05'),
(8, 8, 'Platinum', 80000, '2016-03-18'),
(9, 9, 'Silver', 30000, '2020-06-22'),
(10, 10, 'Gold', 55000, '2018-12-08'),
(11, 11, 'Silver', 22000, '2021-02-14'),
(12, 12, 'Platinum', 70000, '2017-10-30'),
(13, 13, 'Gold', 60000, '2018-04-05'),
(14, 14, 'Silver', 28000, '2019-07-20'),
(15, 15, 'Gold', 52000, '2019-09-15'),
(16, 16, 'Silver', 32000, '2020-11-25'),
(17, 17, 'Platinum', 85000, '2016-08-10'),
(18, 18, 'Gold', 58000, '2018-05-30'),
(19, 19, 'Silver', 18000, '2021-03-12'),
(20, 20, 'Gold', 62000, '2017-12-18');

-- Insert data into Bookings
INSERT INTO Bookings VALUES
-- Bookings for today's flights
(1, 1, 1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Confirmed'),
(2, 2, 1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Confirmed'),
(3, 3, 1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Confirmed'),
(4, 4, 2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Confirmed'),
(5, 5, 2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Confirmed'),
(6, 6, 3, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'Confirmed'),
(7, 7, 3, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'Confirmed'),
(8, 8, 4, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Confirmed'),
(9, 9, 4, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Confirmed'),
(10, 10, 5, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Confirmed'),

-- Bookings for past flights
(11, 1, 6, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Confirmed'),
(12, 2, 6, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Confirmed'),
(13, 3, 6, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Confirmed'),
(14, 4, 7, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'Confirmed'),
(15, 5, 7, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'Confirmed'),
(16, 6, 8, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 'Confirmed'),
(17, 7, 8, DATE_SUB(CURDATE(), INTERVAL 7 DAY), 'Confirmed'),
(18, 8, 9, DATE_SUB(CURDATE(), INTERVAL 8 DAY), 'Confirmed'),
(19, 9, 9, DATE_SUB(CURDATE(), INTERVAL 8 DAY), 'Confirmed'),
(20, 10, 10, DATE_SUB(CURDATE(), INTERVAL 9 DAY), 'Confirmed'),
(21, 11, 11, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Confirmed'),
(22, 12, 11, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Confirmed'),
(23, 13, 12, DATE_SUB(CURDATE(), INTERVAL 11 DAY), 'Confirmed'),
(24, 14, 12, DATE_SUB(CURDATE(), INTERVAL 11 DAY), 'Confirmed'),
(25, 15, 13, DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Confirmed'),
(26, 16, 13, DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'Confirmed'),
(27, 17, 14, DATE_SUB(CURDATE(), INTERVAL 13 DAY), 'Confirmed'),
(28, 18, 14, DATE_SUB(CURDATE(), INTERVAL 13 DAY), 'Confirmed'),
(29, 19, 15, DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'Confirmed'),
(30, 20, 15, DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'Confirmed');

-- Insert data into Tickets
INSERT INTO Tickets VALUES
(1, 1, 'TK1001', '12A', 'Business', DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
(2, 2, 'TK1002', '12B', 'Business', DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
(3, 3, 'TK1003', '15C', 'Economy', DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
(4, 4, 'TK1004', '1A', 'First', DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
(5, 5, 'TK1005', '1B', 'First', DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
(6, 6, 'TK1006', '8A', 'Business', DATE_SUB(CURDATE(), INTERVAL 4 DAY)),
(7, 7, 'TK1007', '8B', 'Business', DATE_SUB(CURDATE(), INTERVAL 4 DAY)),
(8, 8, 'TK1008', '22C', 'Economy', DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
(9, 9, 'TK1009', '22D', 'Economy', DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
(10, 10, 'TK1010', '10A', 'Business', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(11, 11, 'TK1011', '3A', 'First', DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
(12, 12, 'TK1012', '3B', 'First', DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
(13, 13, 'TK1013', '18C', 'Economy', DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
(14, 14, 'TK1014', '5A', 'Business', DATE_SUB(CURDATE(), INTERVAL 6 DAY)),
(15, 15, 'TK1015', '5B', 'Business', DATE_SUB(CURDATE(), INTERVAL 6 DAY)),
(16, 16, 'TK1016', '20D', 'Economy', DATE_SUB(CURDATE(), INTERVAL 7 DAY)),
(17, 17, 'TK1017', '20E', 'Economy', DATE_SUB(CURDATE(), INTERVAL 7 DAY)),
(18, 18, 'TK1018', '7A', 'Business', DATE_SUB(CURDATE(), INTERVAL 8 DAY)),
(19, 19, 'TK1019', '7B', 'Business', DATE_SUB(CURDATE(), INTERVAL 8 DAY)),
(20, 20, 'TK1020', '25F', 'Economy', DATE_SUB(CURDATE(), INTERVAL 9 DAY));

-- Insert data into Payments
INSERT INTO Payments VALUES
(1, 1, 1200.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Paid'),
(2, 2, 1200.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Paid'),
(3, 3, 500.00, 'Debit Card', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Paid'),
(4, 4, 2500.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Paid'),
(5, 5, 2500.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Paid'),
(6, 6, 1100.00, 'Debit Card', DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'Paid'),
(7, 7, 1100.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'Paid'),
(8, 8, 400.00, 'Debit Card', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Paid'),
(9, 9, 400.00, 'UPI', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Paid'),
(10, 10, 1000.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Paid'),
(11, 11, 2300.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Paid'),
(12, 12, 2300.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Paid'),
(13, 13, 450.00, 'Debit Card', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Paid'),
(14, 14, 1050.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'Paid'),
(15, 15, 1050.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'Paid'),
(16, 16, 350.00, 'Debit Card', DATE_SUB(CURDATE(), INTERVAL 7 DAY), 'Paid'),
(17, 17, 350.00, 'UPI', DATE_SUB(CURDATE(), INTERVAL 7 DAY), 'Paid'),
(18, 18, 950.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 8 DAY), 'Paid'),
(19, 19, 950.00, 'Credit Card', DATE_SUB(CURDATE(), INTERVAL 8 DAY), 'Paid'),
(20, 20, 300.00, 'Debit Card', DATE_SUB(CURDATE(), INTERVAL 9 DAY), 'Paid');

-- Insert data into CheckIn
INSERT INTO CheckIn VALUES
(1, 1, CONCAT(CURDATE(), ' 07:30:00'), 'BP1001', 'A1', 'Checked-In'),
(2, 2, CONCAT(CURDATE(), ' 07:35:00'), 'BP1002', 'A1', 'Checked-In'),
(3, 3, CONCAT(CURDATE(), ' 07:40:00'), 'BP1003', 'A1', 'Checked-In'),
(4, 4, CONCAT(CURDATE(), ' 09:00:00'), 'BP1004', 'B1', 'Checked-In'),
(5, 5, CONCAT(CURDATE(), ' 09:05:00'), 'BP1005', 'B1', 'Checked-In'),
(6, 6, CONCAT(CURDATE(), ' 06:00:00'), 'BP1006', 'C1', 'Checked-In'),
(7, 7, CONCAT(CURDATE(), ' 06:05:00'), 'BP1007', 'C1', 'Checked-In'),
(8, 8, CONCAT(CURDATE(), ' 06:30:00'), 'BP1008', 'D1', 'Checked-In'),
(9, 9, CONCAT(CURDATE(), ' 06:35:00'), 'BP1009', 'D1', 'Checked-In'),
(10, 10, CONCAT(CURDATE(), ' 08:00:00'), 'BP1010', 'E1', 'Checked-In');

-- Insert data into Baggage
INSERT INTO Baggage VALUES
(1, 1, 23.50, 'BG1001', 'Checked-In'),
(2, 1, 15.00, 'BG1002', 'Checked-In'),
(3, 2, 20.00, 'BG1003', 'Checked-In'),
(4, 3, 18.50, 'BG1004', 'Checked-In'),
(5, 4, 30.00, 'BG1005', 'Checked-In'),
(6, 5, 28.00, 'BG1006', 'Checked-In'),
(7, 6, 22.00, 'BG1007', 'Checked-In'),
(8, 7, 19.50, 'BG1008', 'Checked-In'),
(9, 8, 17.00, 'BG1009', 'Checked-In'),
(10, 9, 21.00, 'BG1010', 'Checked-In'),
(11, 10, 24.50, 'BG1011', 'Checked-In'),
(12, 11, 16.00, 'BG1012', 'Delivered'),
(13, 12, 25.00, 'BG1013', 'Delivered'),
(14, 13, 14.50, 'BG1014', 'Delivered'),
(15, 14, 29.00, 'BG1015', 'Delivered'),
(16, 15, 27.00, 'BG1016', 'Delivered'),
(17, 16, 20.50, 'BG1017', 'Delivered'),
(18, 17, 18.00, 'BG1018', 'Delivered'),
(19, 18, 22.50, 'BG1019', 'Delivered'),
(20, 19, 19.00, 'BG1020', 'Delivered'),
(21, 20, 23.00, 'BG1021', 'Lost');


-- Sample verification queries
show tables;
DESCRIBE Airports;
SELECT * FROM Airports LIMIT 10;

-- Complex Queries

-- 1) Update aircraft status after maintanence is done 

DELIMITER //
CREATE TRIGGER update_aircraft_status_after_maintenance
AFTER UPDATE ON Maintenance_Records
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' THEN
        UPDATE Aircrafts
        SET status = 'Active'
        WHERE aircraft_id = NEW.aircraft_id;
    END IF;
END;
//
DELIMITER ;

-- 2) Preventing booking on cancelled flight 

DELIMITER //
CREATE TRIGGER prevent_booking_on_cancelled_flight
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    DECLARE flight_status ENUM('Scheduled', 'Cancelled', 'Inactive');
    
    -- Get the status of the flight instance
    SELECT status INTO flight_status
    FROM Flight_Instances
    WHERE flight_instance_id = NEW.flight_instance_id;
    
    -- Check if the flight is cancelled
    IF flight_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot book on a cancelled flight';
    END IF;
END;
//
DELIMITER ;

-- 3) Updating payment status on cancelled booking  

DELIMITER //
CREATE TRIGGER update_payment_status_on_booking_cancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.booking_status = 'Cancelled' THEN
        UPDATE Payments
        SET transaction_status = 'Refunded'
        WHERE booking_id = NEW.booking_id;
    END IF;
END;
//
DELIMITER ;


-- 4) Stored Procedure to Book a Ticket  

DELIMITER //
CREATE PROCEDURE book_ticket(
    IN p_customer_id INT,
    IN p_flight_instance_id INT,
    IN p_seat_count INT,
    OUT p_booking_id INT
)
BEGIN
    DECLARE flight_capacity INT;
    DECLARE available_seats INT;

    -- Get the capacity of the flight instance
    SELECT capacity INTO flight_capacity
    FROM Flight_Instances
    WHERE flight_instance_id = p_flight_instance_id;

    -- Get the number of available seats on the flight
    SELECT (flight_capacity - (SELECT COUNT(*) FROM Bookings WHERE flight_instance_id = p_flight_instance_id)) INTO available_seats;

    -- Check if there are enough available seats
    IF available_seats >= p_seat_count THEN
        -- Insert the booking
        INSERT INTO Bookings (customer_id, flight_instance_id, seat_count, booking_status)
        VALUES (p_customer_id, p_flight_instance_id, p_seat_count, 'Booked');

        -- Get the generated booking_id
        SET p_booking_id = LAST_INSERT_ID();
    ELSE
        -- Raise an error if not enough seats
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough available seats on the flight';
    END IF;
END;
//
DELIMITER ;

 -- 5) Stored Procedure to Cancel a Booking 

DELIMITER //
CREATE PROCEDURE cancel_booking(
    IN p_booking_id INT
)
BEGIN
    DECLARE flight_instance_id INT;
    DECLARE current_status ENUM('Scheduled', 'Cancelled', 'Completed');

    -- Get the flight instance ID for the booking
    SELECT flight_instance_id INTO flight_instance_id
    FROM Bookings
    WHERE booking_id = p_booking_id;

    -- Get the current status of the flight instance
    SELECT status INTO current_status
    FROM Flight_Instances
    WHERE flight_instance_id = flight_instance_id;

    -- Update the booking status to 'Cancelled'
    UPDATE Bookings
    SET booking_status = 'Cancelled'
    WHERE booking_id = p_booking_id;

    -- If the flight instance is scheduled, update its status to 'Cancelled'
    IF current_status = 'Scheduled' THEN
        UPDATE Flight_Instances
        SET status = 'Cancelled'
        WHERE flight_instance_id = flight_instance_id;
    END IF;

    -- Update the payment status to 'Refunded'
    UPDATE Payments
    SET transaction_status = 'Refunded'
    WHERE booking_id = p_booking_id;
END;
//
DELIMITER ;


-- 6) Stored Procedure to Add a New Customer 

-- Check if the procedure 'add_customer' exists
DELIMITER //
CREATE PROCEDURE add_customer(
    IN p_customer_name VARCHAR(255),
    IN p_customer_email VARCHAR(255),
    IN p_customer_phone VARCHAR(50),
    IN p_customer_address VARCHAR(255)
)
BEGIN
    -- Check if the customer already exists based on the email
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE email = p_customer_email) THEN
        -- Insert the new customer into the Customers table
        INSERT INTO Customers (name, email, phone, address)
        VALUES (p_customer_name, p_customer_email, p_customer_phone, p_customer_address);
    ELSE
        -- If the customer already exists, return a message
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer with this email already exists.';
    END IF;
END;
//
DELIMITER ;


-- 7) Stored Procedure to Assign a Pilot to a Flight  

DELIMITER //
CREATE PROCEDURE assign_pilot_to_flight(
    IN p_flight_instance_id INT,
    IN p_pilot_id INT
)
BEGIN
    -- Check if the pilot is already assigned to this flight instance
    IF NOT EXISTS (SELECT 1 FROM Flight_Pilots WHERE flight_instance_id = p_flight_instance_id AND pilot_id = p_pilot_id) THEN
        INSERT INTO Flight_Pilots (flight_instance_id, pilot_id)
        VALUES (p_flight_instance_id, p_pilot_id);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pilot is already assigned to this flight';
    END IF;
END;
//
DELIMITER ;

-- 8) flight status updation   
DELIMITER //
CREATE PROCEDURE update_flight_status(
    IN p_flight_instance_id INT,
    IN p_new_status ENUM('Scheduled', 'Cancelled', 'Completed')
)
BEGIN
    UPDATE Flight_Instances
    SET status = p_new_status
    WHERE flight_instance_id = p_flight_instance_id;
END;
//
DELIMITER ;

-- 9) Stored Procedure to Calculate Total Revenue for a Flight   

DELIMITER //
CREATE PROCEDURE calculate_flight_revenue(
    IN p_flight_instance_id INT,
    OUT p_total_revenue DECIMAL(10, 2)
)
BEGIN
    SELECT SUM(amount) INTO p_total_revenue
    FROM Payments
    WHERE flight_instance_id = p_flight_instance_id;
    
    IF p_total_revenue IS NULL THEN
        SET p_total_revenue = 0.00;
    END IF;
END;
//
DELIMITER ;

-- 10) Stored Procedure to Get Customer Booking History    

DELIMITER //
CREATE PROCEDURE get_customer_booking_history(
    IN p_customer_id INT
)
BEGIN
    SELECT b.booking_id, f.flight_id, fi.departure_datetime, fi.arrival_datetime, b.seat_count, b.booking_status
    FROM Bookings b
    JOIN Flight_Instances fi ON b.flight_instance_id = fi.flight_instance_id
    JOIN Flights f ON fi.flight_id = f.flight_id
    WHERE b.customer_id = p_customer_id
    ORDER BY fi.departure_datetime DESC;
END;
//
DELIMITER ;

-- Complex Use Case Queries
-- 11) Find the Most Popular Route (Based on Number of Bookings):   
SELECT
    r.route_id,
    a1.name AS departure_airport,
    a2.name AS arrival_airport,
    COUNT(*) AS booking_count
FROM
    Routes r
JOIN
    Airports a1 ON r.departure_airport_id = a1.airport_id
JOIN
    Airports a2 ON r.arrival_airport_id = a2.airport_id
JOIN
    Flights f ON r.route_id = f.route_id
JOIN
    Flight_Instances fi ON f.flight_id = fi.flight_id
JOIN
    Bookings b ON fi.flight_instance_id = b.flight_instance_id
GROUP BY
    r.route_id, departure_airport, arrival_airport
ORDER BY
    booking_count DESC
LIMIT 1;

-- 12) Analyze Passenger Nationality Distribution on Different Routes: 
SELECT
    r.route_id,
    a1.name AS departure_airport,
    a2.name AS arrival_airport,
    p.nationality,
    COUNT(*) AS passenger_count
FROM
    Routes r
JOIN
    Airports a1 ON r.departure_airport_id = a1.airport_id
JOIN
    Airports a2 ON r.arrival_airport_id = a2.airport_id
JOIN
    Flights f ON r.route_id = f.route_id
JOIN
    Flight_Instances fi ON f.flight_id = fi.flight_id
JOIN
    Bookings b ON fi.flight_instance_id = b.flight_instance_id
JOIN
    Passengers p ON b.passenger_id = p.passenger_id
GROUP BY
    r.route_id, departure_airport, arrival_airport, p.nationality
ORDER BY
    r.route_id, passenger_count DESC;
    
-- -- 3)  Active Flights with Delayed Status and Their Crew Members
SELECT 
    f.flight_number,
    a1.name AS departure_airport,
    a2.name AS arrival_airport,
    fi.actual_departure_time,
    fi.actual_arrival_time,
    CONCAT(e.first_name, ' ', e.last_name) AS crew_name,
    c.role
FROM 
    Flight_Instances fi
JOIN Flights f ON fi.flight_id = f.flight_id
JOIN Routes r ON f.route_id = r.route_id
JOIN Airports a1 ON r.departure_airport_id = a1.airport_id
JOIN Airports a2 ON r.arrival_airport_id = a2.airport_id
JOIN Crew_Assignments ca ON fi.flight_instance_id = ca.flight_instance_id
JOIN Crew c ON ca.crew_id = c.crew_id
JOIN Employees e ON c.employee_id = e.employee_id
WHERE 
    fi.status = 'Delayed'
    AND fi.flight_date = CURRENT_DATE
ORDER BY 
    fi.actual_departure_time;
    
-- 4. Aircraft Maintenance Due in Next 7 Days

SELECT 
    a.aircraft_id,
    a.model,
    a.registration_number,
    mr.next_due_date,
    DATEDIFF(mr.next_due_date, CURRENT_DATE) AS days_remaining
FROM 
    Aircrafts a
JOIN Maintenance_Records mr ON a.aircraft_id = mr.aircraft_id
WHERE 
    mr.status = 'Completed'
    AND mr.next_due_date BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY)
ORDER BY 
    days_remaining;
    
-- 5. Revenue Analysis by Flight Class (Last 30 Days)
SELECT 
    f.flight_number,
    r.distance_km,
    t.class,
    COUNT(*) AS tickets_sold,
    SUM(py.amount) AS total_revenue,
    AVG(py.amount) AS average_fare
FROM 
    Payments py
JOIN Bookings b ON py.booking_id = b.booking_id
JOIN Flight_Instances fi ON b.flight_instance_id = fi.flight_instance_id
JOIN Flights f ON fi.flight_id = f.flight_id
JOIN Routes r ON f.route_id = r.route_id
JOIN Tickets t ON b.booking_id = t.booking_id
WHERE 
    py.transaction_status = 'Paid'
    AND fi.flight_date BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY) AND CURRENT_DATE
GROUP BY 
    f.flight_number, r.distance_km, t.class
ORDER BY 
    total_revenue DESC;
    
-- 6. Baggage Handling Performance

SELECT 
    f.flight_number,
    fi.flight_date,
    COUNT(bg.baggage_id) AS total_bags,
    SUM(CASE WHEN bg.status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_bags,
    SUM(CASE WHEN bg.status = 'Lost' THEN 1 ELSE 0 END) AS lost_bags,
    CONCAT(ROUND(SUM(CASE WHEN bg.status = 'Delivered' THEN 1 ELSE 0 END) / 
          COUNT(bg.baggage_id) * 100, 2), '%') AS delivery_rate
FROM 
    Baggage bg
JOIN Tickets t ON bg.ticket_id = t.ticket_id
JOIN Bookings b ON t.booking_id = b.booking_id
JOIN Flight_Instances fi ON b.flight_instance_id = fi.flight_instance_id
JOIN Flights f ON fi.flight_id = f.flight_id
WHERE 
    fi.flight_date BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY) AND CURRENT_DATE
GROUP BY 
    f.flight_number, fi.flight_date
ORDER BY 
    delivery_rate ASC, fi.flight_date DESC;

-- 7. Frequent Flyer Tier Analysis: Loyalty Program Analysis

SELECT 
    lp.membership_tier,
    COUNT(*) AS member_count,
    AVG(lp.total_miles) AS avg_miles,
    MAX(lp.total_miles) AS max_miles,
    MIN(lp.total_miles) AS min_miles,
    CONCAT(p.nationality) AS top_nationality
FROM 
    Loyalty_Program lp
JOIN Passengers p ON lp.passenger_id = p.passenger_id
GROUP BY 
    lp.membership_tier, p.nationality
ORDER BY 
    CASE lp.membership_tier
        WHEN 'Diamond' THEN 1
        WHEN 'Platinum' THEN 2
        WHEN 'Gold' THEN 3
        WHEN 'Silver' THEN 4
    END;

-- 8. Aircraft Utilization Report

SELECT 
    a.aircraft_id,
    a.model,
    a.capacity,
    COUNT(fi.flight_instance_id) AS flights_completed,
    SUM(r.distance_km) AS total_distance_km,
    CONCAT(ROUND(COUNT(fi.flight_instance_id) / 30 * 100, 2), '%') AS utilization_rate
FROM 
    Aircrafts a
JOIN Flights f ON a.aircraft_id = f.aircraft_id
JOIN Flight_Instances fi ON f.flight_id = fi.flight_id
JOIN Routes r ON f.route_id = r.route_id
WHERE 
    fi.flight_date BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY) AND CURRENT_DATE
    AND fi.status = 'Completed'
GROUP BY 
    a.aircraft_id, a.model, a.capacity
ORDER BY 
    utilization_rate DESC;

-- 9. Real-Time Flight Status Dashboard

SELECT 
    f.flight_number,
    a1.name AS departure_airport,
    a2.name AS arrival_airport,
    fi.flight_date,
    f.scheduled_departure_time,
    fi.actual_departure_time,
    f.scheduled_arrival_time,
    fi.actual_arrival_time,
    fi.status,
    g.gate_number,
    COUNT(b.booking_id) AS passenger_count,
    CONCAT(
        CASE 
            WHEN fi.actual_departure_time IS NULL THEN 'N/A'
            ELSE TIMESTAMPDIFF(MINUTE, 
                CAST(CONCAT(fi.flight_date, ' ', f.scheduled_departure_time) AS DATETIME),
                fi.actual_departure_time)
        END, 
        ' mins'
    ) AS delay_duration
FROM 
    Flights f
JOIN Routes r ON f.route_id = r.route_id
JOIN Airports a1 ON r.departure_airport_id = a1.airport_id
JOIN Airports a2 ON r.arrival_airport_id = a2.airport_id
JOIN Flight_Instances fi ON f.flight_id = fi.flight_id
LEFT JOIN Gates g ON fi.gate_id = g.gate_id
LEFT JOIN Bookings b ON fi.flight_instance_id = b.flight_instance_id
WHERE 
    fi.flight_date = CURRENT_DATE
    AND b.booking_status = 'Confirmed'
GROUP BY 
    f.flight_number, a1.name, a2.name, fi.flight_date, f.scheduled_departure_time,
    fi.actual_departure_time, f.scheduled_arrival_time, fi.actual_arrival_time,
    fi.status, g.gate_number
ORDER BY 
    f.scheduled_departure_time;

-- 10. Crew Workload Monitoring
    SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS crew_name,
    c.role,
    COUNT(ca.assignment_id) AS assigned_flights,
    GROUP_CONCAT(DISTINCT f.flight_number ORDER BY fi.flight_date SEPARATOR ', ') AS flight_numbers
FROM 
    Crew_Assignments ca
JOIN Crew c ON ca.crew_id = c.crew_id
JOIN Employees e ON c.employee_id = e.employee_id
JOIN Flight_Instances fi ON ca.flight_instance_id = fi.flight_instance_id
JOIN Flights f ON fi.flight_id = f.flight_id
WHERE 
    fi.flight_date BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY)
GROUP BY 
    crew_name, c.role
HAVING 
    COUNT(ca.assignment_id) > 1
ORDER BY 
    assigned_flights DESC;
    
    
-- Functions
-- 13)
-- Function 1: GetLostBaggageRate
-- Description: Calculates the rate of lost baggage for a specific flight instance
-- Parameters: flight_instance_id INT

DELIMITER $$

CREATE FUNCTION GetLostBaggageRate(flight_instance_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE lost_count INT;
    DECLARE total_count INT;

    SELECT COUNT(*) INTO total_count
    FROM Tickets T
    JOIN Bookings B ON T.booking_id = B.booking_id
    JOIN Baggage BG ON T.ticket_id = BG.ticket_id
    WHERE B.flight_instance_id = flight_instance_id;

    SELECT COUNT(*) INTO lost_count
    FROM Tickets T
    JOIN Bookings B ON T.booking_id = B.booking_id
    JOIN Baggage BG ON T.ticket_id = BG.ticket_id
    WHERE B.flight_instance_id = flight_instance_id AND BG.status = 'Lost';

    IF total_count = 0 THEN
        RETURN 0.00;
    ELSE
        RETURN ROUND((lost_count / total_count) * 100, 2);
    END IF;
END$$

-- Sample Call:
SELECT GetLostBaggageRate(3);


-- 14
-- Function 2: GetFlightRevenueBreakdown
-- Description: Returns the total revenue per class (Economy, Business, First) for a given flight instance.
-- Parameters: flight_instance_id INT


DELIMITER $$

CREATE FUNCTION GetFlightRevenueBreakdown(flight_instance_id INT)
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE eco DECIMAL(10,2) DEFAULT 0.00;
    DECLARE bus DECIMAL(10,2) DEFAULT 0.00;
    DECLARE fst DECIMAL(10,2) DEFAULT 0.00;
    DECLARE result TEXT;

    SELECT SUM(P.amount) INTO eco
    FROM Payments P
    JOIN Bookings B ON P.booking_id = B.booking_id
    JOIN Tickets T ON B.booking_id = T.booking_id
    WHERE B.flight_instance_id = flight_instance_id AND T.class = 'Economy' AND P.transaction_status = 'Paid';

    SELECT SUM(P.amount) INTO bus
    FROM Payments P
    JOIN Bookings B ON P.booking_id = B.booking_id
    JOIN Tickets T ON B.booking_id = T.booking_id
    WHERE B.flight_instance_id = flight_instance_id AND T.class = 'Business' AND P.transaction_status = 'Paid';

    SELECT SUM(P.amount) INTO fst
    FROM Payments P
    JOIN Bookings B ON P.booking_id = B.booking_id
    JOIN Tickets T ON B.booking_id = T.booking_id
    WHERE B.flight_instance_id = flight_instance_id AND T.class = 'First' AND P.transaction_status = 'Paid';

    SET result = CONCAT('Economy: $', IFNULL(eco,0.00), ', Business: $', IFNULL(bus,0.00), ', First: $', IFNULL(fst,0.00));
    RETURN result;
END$$

-- Sample Call:
SELECT GetFlightRevenueBreakdown(1);


-- 15
-- Function 3: GetPassengerLoyaltyRecommendation
-- Description: Recommends tier upgrade based on miles and booking frequency.
-- Parameters: passenger_id INT

DELIMITER $$

CREATE FUNCTION GetPassengerLoyaltyRecommendations(passenger_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE miles INT;
    DECLARE booking_count INT;
    DECLARE current_tier ENUM('Silver', 'Gold', 'Platinum', 'Diamond');
    DECLARE suggestion VARCHAR(100);

    SELECT total_miles, membership_tier INTO miles, current_tier
    FROM Loyalty_Program
    WHERE passenger_id = passenger_id
    LIMIT 1;

    SELECT COUNT(*) INTO booking_count
    FROM Bookings
    WHERE passenger_id = passenger_id;

    SET suggestion = 'No Upgrade';

    IF current_tier = 'Silver' AND (miles > 20000 OR booking_count > 5) THEN
        SET suggestion = 'Upgrade to Gold';
    ELSEIF current_tier = 'Gold' AND (miles > 30000 OR booking_count > 10) THEN
        SET suggestion = 'Upgrade to Platinum';
    ELSEIF current_tier = 'Platinum' AND (miles > 40000 OR booking_count > 15) THEN
        SET suggestion = 'Upgrade to Diamond';
    END IF;

    RETURN suggestion;
END$$

-- Sample Call:
SELECT GetPassengerLoyaltyRecommendations(2);



-- 16
-- Function 4: GetCrewDutyCompliance
-- Description: Checks if a crew member exceeded 100 flight hours in the last 30 days.
-- Parameters: crew_id INT


DELIMITER $$

CREATE FUNCTION GetCrewDutyCompliance(crew_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE total_minutes INT;

    SELECT SUM(R.flight_time_minutes) INTO total_minutes
    FROM Crew_Assignments CA
    JOIN Flight_Instances FI ON CA.flight_instance_id = FI.flight_instance_id
    JOIN Flights F ON FI.flight_id = F.flight_id
    JOIN Routes R ON F.route_id = R.route_id
    WHERE CA.crew_id = crew_id AND FI.flight_date >= CURDATE() - INTERVAL 30 DAY;

    IF IFNULL(total_minutes, 0) > 6000 THEN
        RETURN 'Non-Compliant (>100 hrs)';
    ELSE
        RETURN 'Compliant';
    END IF;
END$$

-- Sample Call:
SELECT GetCrewDutyCompliance(1);



-- 17
-- Function 5: GetFlightDelayTrend
-- Description: Returns delay trend for a given route ID over the past 90 days.
-- Parameters: route_id INT


DELIMITER $$

CREATE FUNCTION GetFlightDelayTrend(route_id INT)
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE delay_count INT;
    DECLARE total INT;
    DECLARE trend TEXT;

    SELECT COUNT(*) INTO total
    FROM Flights F
    JOIN Flight_Instances FI ON F.flight_id = FI.flight_id
    WHERE F.route_id = route_id AND FI.flight_date >= CURDATE() - INTERVAL 90 DAY;

    SELECT COUNT(*) INTO delay_count
    FROM Flights F
    JOIN Flight_Instances FI ON F.flight_id = FI.flight_id
    WHERE F.route_id = route_id AND FI.status = 'Delayed'
    AND FI.flight_date >= CURDATE() - INTERVAL 90 DAY;

    IF total = 0 THEN
        SET trend = 'No Flights';
    ELSE
        SET trend = CONCAT('Delayed: ', delay_count, '/', total, ' (', ROUND((delay_count/total)*100,2), '%)');
    END IF;

    RETURN trend;
END$$

-- Sample Call:
SELECT GetFlightDelayTrend(1);
