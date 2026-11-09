CREATE DATABASE CarRentalDB;

USE CarRentalDB;
CREATE TABLE Customers (
customer_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR (100)NOT NULL,
phone VARCHAR(15)NOT NULL,
email VARCHAR(100) UNIQUE,
    licence_no VARCHAR(30) NOT NULL UNIQUE
);
DESC Customers;
USE CarRentalDB;

CREATE TABLE Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    registration_no VARCHAR(20) NOT NULL UNIQUE,
    fuel_type VARCHAR(20),
    transmission VARCHAR(20),
    daily_rate DECIMAL(10,2) NOT NULL,
    car_status VARCHAR(20) DEFAULT 'Available'
);
INSERT INTO Cars
(brand, model, registration_no, fuel_type,
 transmission, daily_rate, car_status)
VALUES
('Hyundai', 'Creta', 'HR26AB1234', 'Petrol', 'Automatic', 2500, 'Available'),
('Maruti', 'Swift', 'HR26CD5678', 'Petrol', 'Manual', 1500, 'Available'),
('Tata', 'Nexon', 'HR26EF9012', 'Diesel', 'Manual', 2000, 'Available'),
('Kia', 'Seltos', 'HR26GH3456', 'Diesel', 'Automatic', 3000, 'Available'),
('Toyota', 'Fortuner', 'HR26IJ7890', 'Diesel', 'Automatic', 5000, 'Available');
SELECT * FROM Cars;
USE CarRentalDB;
CREATE TABLE Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    car_id INT NOT NULL,
    branch_id INT,
    pickup_date DATE NOT NULL,
    return_date DATE NOT NULL,
    actual_return_date DATE,
    total_amount DECIMAL(10,2),
    rental_status VARCHAR(20) DEFAULT 'Booked',

    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    FOREIGN KEY (car_id)
        REFERENCES Cars(car_id),

    CHECK (return_date > pickup_date)
);


DESC Rentals;
SHOW TABLES;

USE CarRentalDB;

CREATE TABLE RentalHistory (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    actual_return_date DATE NOT NULL,
    late_fee DECIMAL(10,2) DEFAULT 0.00,
    vehicle_condition VARCHAR(100),
    remarks VARCHAR(255),

    FOREIGN KEY (rental_id)
        REFERENCES Rentals(rental_id)
);
DESC RentalHistory;
SHOW TABLES;

 
USE CarRentalDB;
SELECT * FROM Customers;

INSERT INTO Customers
(name, phone, email, licence_no)
VALUES
('Rahul Sharma', '9876543210', 'rahul@gmail.com', 'DL12345'),
('Priya Verma', '9876543211', 'priya@gmail.com', 'DL12346'),
('Arjun Mehta', '9876543212', 'arjun@gmail.com', 'DL12347'),
('Sneha Kapoor', '9876543213', 'sneha@gmail.com', 'DL12348'),
('Karan Singh', '9876543214', 'karan@gmail.com', 'DL12349');

INSERT INTO Rentals
(customer_id, car_id, pickup_date, return_date,
 total_amount, rental_status)
VALUES
(1, 1, '2026-11-01', '2026-11-04', 7500, 'Completed'),
(2, 2, '2026-11-03', '2026-11-05', 3000, 'Completed'),
(3, 3, '2026-11-06', '2026-11-09', 6000, 'Active'),
(4, 4, '2026-11-07', '2026-11-10', 9000, 'Booked'),
(5, 5, '2026-11-08', '2026-11-12', 20000, 'Booked');
SELECT * FROM Rentals;

SELECT
    r.rental_id,
    c.name AS customer_name,
    ca.brand,
    ca.model,
    r.pickup_date,
    r.return_date,
    r.total_amount,
    r.rental_status
FROM Rentals r
JOIN Customers c
    ON r.customer_id = c.customer_id
JOIN Cars ca
    ON r.car_id = ca.car_id;
    
INSERT INTO Customers
(name, phone, email, licence_no)
VALUES
('Amit Kumar', '9876543215',
 'amit@gmail.com', 'DL12350');
 
 SELECT * FROM Customers;
 SELECT *
FROM Customers
WHERE name = 'Amit Kumar';

UPDATE Customers
SET phone = '9999999999'
WHERE email = 'amit@gmail.com';

SELECT name, phone, email
FROM Customers
WHERE email = 'amit@gmail.com';

SELECT *
FROM Rentals
WHERE customer_id = (
    SELECT customer_id
    FROM Customers
    WHERE email = 'amit@gmail.com'
);
DELETE FROM Customers
WHERE email = 'amit@gmail.com';

SELECT *
FROM Customers
WHERE email = 'amit@gmail.com';


SELECT
    r.rental_id,
    c.name AS customer_name,
    ca.brand,
    ca.model,
    ca.daily_rate,
    DATEDIFF(r.return_date, r.pickup_date) AS rental_days,
    ca.daily_rate * DATEDIFF(r.return_date, r.pickup_date)
        AS calculated_amount
FROM Rentals r
JOIN Customers c
    ON r.customer_id = c.customer_id
JOIN Cars ca
    ON r.car_id = ca.car_id;

UPDATE Rentals r
JOIN Cars c
    ON r.car_id = c.car_id
SET r.total_amount =
    c.daily_rate * DATEDIFF(r.return_date, r.pickup_date)
WHERE r.rental_id > 0;
    
    
    
SELECT rental_id, total_amount
FROM Rentals;

SELECT
    car_id,
    brand,
    model,
    registration_no,
    daily_rate
FROM Cars c
WHERE car_status = 'Available'
AND NOT EXISTS (
    SELECT 1
    FROM Rentals r
    WHERE r.car_id = c.car_id
    AND r.rental_status IN ('Booked', 'Active')
    AND r.pickup_date < '2026-11-11'
    AND r.return_date > '2026-11-10'
);


USE CarRentalDB;

INSERT INTO RentalHistory
(rental_id, actual_return_date, late_fee,
 vehicle_condition, remarks)
SELECT
    r.rental_id,
    r.return_date,
    0.00,
    'Good',
    'Vehicle returned successfully'
FROM Rentals r
WHERE r.rental_status = 'Completed'
AND NOT EXISTS (
    SELECT 1
    FROM RentalHistory rh
    WHERE rh.rental_id = r.rental_id
);

SELECT
    rh.history_id,
    c.name AS customer_name,
    ca.brand,
    ca.model,
    r.pickup_date,
    rh.actual_return_date,
    r.total_amount,
    rh.late_fee,
    rh.vehicle_condition
FROM RentalHistory rh
JOIN Rentals r
    ON rh.rental_id = r.rental_id
JOIN Customers c
    ON r.customer_id = c.customer_id
JOIN Cars ca
    ON r.car_id = ca.car_id;
    
SELECT
    rental_id,
    customer_id,
    return_date,
    actual_return_date,
    GREATEST(
        DATEDIFF(actual_return_date, return_date), 0
    ) AS late_days,
    GREATEST(
        DATEDIFF(actual_return_date, return_date), 0
    ) * 500 AS late_fee
FROM Rentals
WHERE actual_return_date IS NOT NULL;

CREATE INDEX idx_rental_car_dates
ON Rentals(car_id, pickup_date, return_date);

SHOW INDEX FROM Cars;

CREATE INDEX idx_customer_phone_email
ON Customers(phone, email);

EXPLAIN
SELECT *
FROM Rentals
WHERE car_id = 1
AND pickup_date < '2026-11-15'
AND return_date > '2026-11-10';

EXPLAIN
SELECT *
FROM Rentals
WHERE DATEDIFF(return_date, pickup_date) > 3;




CREATE VIEW AvailableCars AS
SELECT
    c.car_id,
    c.brand,
    c.model,
    c.registration_no,
    c.fuel_type,
    c.daily_rate,
    c.car_status
FROM Cars c
WHERE c.car_status = 'Available'
AND NOT EXISTS (
    SELECT 1
    FROM Rentals r
    WHERE r.car_id = c.car_id
    AND r.rental_status IN ('Booked', 'Active')
    AND r.pickup_date <= CURDATE()
    AND r.return_date > CURDATE()
);


SELECT * FROM AvailableCars;

CREATE VIEW CustomerRentalSummary AS
SELECT
    c.customer_id,
    c.name,
    COUNT(r.rental_id) AS total_rentals,
    COALESCE(SUM(r.total_amount), 0) AS total_spend,
    SUM(
        CASE
            WHEN r.actual_return_date > r.return_date
            THEN 1
            ELSE 0
        END
    ) AS late_returns
FROM Customers c
LEFT JOIN Rentals r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.name;

SELECT * FROM CustomerRentalSummary;

CREATE VIEW CarDetails AS
SELECT car_id, brand, model, daily_rate, car_status
FROM Cars;

UPDATE CarDetails
SET daily_rate = 2600
WHERE car_id = 1;


SELECT
    customer_id,
    name,
    total_spend,
    RANK() OVER (
        ORDER BY total_spend DESC
    ) AS spending_rank
FROM CustomerRentalSummary;

SELECT
    MONTH(pickup_date) AS rental_month,
    SUM(total_amount) AS monthly_revenue,
    SUM(SUM(total_amount)) OVER (
        ORDER BY MONTH(pickup_date)
    ) AS running_revenue
FROM Rentals
GROUP BY MONTH(pickup_date);

SELECT
    customer_id,
    rental_id,
    pickup_date,
    LAG(pickup_date) OVER (
        PARTITION BY customer_id
        ORDER BY pickup_date
    ) AS previous_rental_date,
    DATEDIFF(
        pickup_date,
        LAG(pickup_date) OVER (
            PARTITION BY customer_id
            ORDER BY pickup_date
        )
    ) AS gap_days
FROM Rentals;


ALTER TABLE Cars
ADD COLUMN car_category VARCHAR(30);

UPDATE Cars
SET car_category =
    CASE
        WHEN brand IN ('Toyota', 'Kia', 'Hyundai', 'Tata')
            THEN 'SUV'
        WHEN brand = 'Maruti'
            THEN 'Hatchback'
        ELSE 'Other'
    END
WHERE car_id > 0;

SELECT car_id, brand, model, car_category
FROM Cars;

    
    
    SELECT *
FROM (
    SELECT
        ca.car_category,
        ca.brand,
        ca.model,
        COUNT(r.rental_id) AS rental_count,
        ROW_NUMBER() OVER (
            PARTITION BY ca.car_category
            ORDER BY COUNT(r.rental_id) DESC
        ) AS car_rank
    FROM Cars ca
    LEFT JOIN Rentals r
        ON ca.car_id = r.car_id
    GROUP BY
        ca.car_id,
        ca.car_category,
        ca.brand,
        ca.model
) AS ranked_cars
WHERE car_rank = 1;


USE CarRentalDB;

CREATE TABLE Branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

INSERT INTO Branches (branch_name, city)
VALUES
('Gurgaon Central', 'Gurgaon'),
('Delhi Airport', 'Delhi'),
('Hyderabad Central', 'Hyderabad');

ALTER TABLE Rentals
ADD CONSTRAINT fk_rental_branch
FOREIGN KEY (branch_id)
REFERENCES Branches(branch_id);

UPDATE Rentals
SET branch_id = CASE
    WHEN rental_id IN (1, 2) THEN 1
    WHEN rental_id IN (3, 4) THEN 2
    WHEN rental_id = 5 THEN 3
END
WHERE rental_id > 0;

SELECT
    r.rental_id,
    c.name AS customer_name,
    b.branch_name,
    r.total_amount
FROM Rentals r
JOIN Customers c
    ON r.customer_id = c.customer_id
JOIN Branches b
    ON r.branch_id = b.branch_id;
    
SELECT
    b.branch_name,
    c.name,
    SUM(r.total_amount) AS total_spend,
    RANK() OVER (
        PARTITION BY b.branch_id
        ORDER BY SUM(r.total_amount) DESC
    ) AS spending_rank
FROM Rentals r
JOIN Customers c
    ON r.customer_id = c.customer_id
JOIN Branches b
    ON r.branch_id = b.branch_id
GROUP BY
    b.branch_id,
    b.branch_name,
    c.customer_id,
    c.name;
    
SELECT
    b.branch_name,
    DATE_FORMAT(r.pickup_date, '%Y-%m') AS rental_month,
    SUM(r.total_amount) AS monthly_revenue,
    SUM(SUM(r.total_amount)) OVER (
        PARTITION BY b.branch_id
        ORDER BY DATE_FORMAT(r.pickup_date, '%Y-%m')
    ) AS running_revenue
FROM Rentals r
JOIN Branches b
    ON r.branch_id = b.branch_id
GROUP BY
    b.branch_id,
    b.branch_name,
    DATE_FORMAT(r.pickup_date, '%Y-%m');
    
SELECT
    customer_id,
    rental_id,
    pickup_date,
    LAG(pickup_date) OVER (
        PARTITION BY customer_id
        ORDER BY pickup_date
    ) AS previous_rental,
    DATEDIFF(
        pickup_date,
        LAG(pickup_date) OVER (
            PARTITION BY customer_id
            ORDER BY pickup_date
        )
    ) AS gap_days
FROM Rentals;

SHOW TABLES;

SHOW FULL TABLES
WHERE Table_type = 'VIEW';

