-- Vehicle Rental Management System
-- MySQL 8.0+
CREATE DATABASE IF NOT EXISTS vehicle_rental_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vehicle_rental_db;

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('Admin','Staff') NOT NULL DEFAULT 'Staff',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    address VARCHAR(255),
    driving_license_no VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vehicle_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    daily_rate DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_daily_rate CHECK (daily_rate > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    vehicle_number VARCHAR(20) NOT NULL UNIQUE,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    manufacture_year YEAR,
    color VARCHAR(30),
    fuel_type ENUM('Petrol','Diesel','Electric','CNG','Hybrid') NOT NULL,
    transmission ENUM('Manual','Automatic') NOT NULL,
    seating_capacity INT NOT NULL,
    status ENUM('Available','Rented','Maintenance') NOT NULL DEFAULT 'Available',
    CONSTRAINT fk_vehicle_category FOREIGN KEY (category_id)
        REFERENCES vehicle_categories(category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_seating_capacity CHECK (seating_capacity > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    rental_date DATE NOT NULL,
    expected_return_date DATE NOT NULL,
    actual_return_date DATE NULL,
    daily_rate DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    rental_status ENUM('Booked','Active','Completed','Cancelled') NOT NULL DEFAULT 'Booked',
    notes VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_rental_vehicle FOREIGN KEY (vehicle_id)
        REFERENCES vehicles(vehicle_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_rental_dates CHECK (expected_return_date >= rental_date),
    CONSTRAINT chk_rental_rate CHECK (daily_rate > 0),
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_actual_return CHECK (actual_return_date IS NULL OR actual_return_date >= rental_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Cash','UPI','Credit Card','Debit Card','Net Banking') NOT NULL,
    payment_status ENUM('Pending','Paid','Refunded') NOT NULL DEFAULT 'Pending',
    transaction_reference VARCHAR(100) UNIQUE,
    CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id)
        REFERENCES rentals(rental_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_payment_amount CHECK (amount > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS maintenance (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    service_date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
    cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    maintenance_status ENUM('Scheduled','In Progress','Completed') NOT NULL DEFAULT 'Scheduled',
    next_service_date DATE,
    CONSTRAINT fk_maintenance_vehicle FOREIGN KEY (vehicle_id)
        REFERENCES vehicles(vehicle_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_maintenance_cost CHECK (cost >= 0)
) ENGINE=InnoDB;

CREATE INDEX idx_customer_name ON customers(full_name);
CREATE INDEX idx_vehicle_status ON vehicles(status);
CREATE INDEX idx_vehicle_category ON vehicles(category_id);
CREATE INDEX idx_rental_customer ON rentals(customer_id);
CREATE INDEX idx_rental_vehicle ON rentals(vehicle_id);
CREATE INDEX idx_rental_status ON rentals(rental_status);
CREATE INDEX idx_rental_date ON rentals(rental_date);
CREATE INDEX idx_payment_rental ON payments(rental_id);
CREATE INDEX idx_maintenance_vehicle ON maintenance(vehicle_id);


USE vehicle_rental_db;

INSERT INTO users (full_name, username, password, role)
SELECT 'System Administrator','admin','admin123','Admin'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='admin');

INSERT INTO users (full_name, username, password, role)
SELECT 'Rental Staff','staff','staff123','Staff'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='staff');

INSERT INTO vehicle_categories (category_name, description, daily_rate)
SELECT 'Economy Car','Affordable cars for city travel',1200.00
WHERE NOT EXISTS (SELECT 1 FROM vehicle_categories WHERE category_name='Economy Car');

INSERT INTO vehicle_categories (category_name, description, daily_rate)
SELECT 'SUV','Spacious sport utility vehicles',2200.00
WHERE NOT EXISTS (SELECT 1 FROM vehicle_categories WHERE category_name='SUV');

INSERT INTO vehicle_categories (category_name, description, daily_rate)
SELECT 'Bike','Two-wheelers for convenient travel',700.00
WHERE NOT EXISTS (SELECT 1 FROM vehicle_categories WHERE category_name='Bike');

INSERT INTO vehicle_categories (category_name, description, daily_rate)
SELECT 'Luxury Car','Premium vehicles for special occasions',4500.00
WHERE NOT EXISTS (SELECT 1 FROM vehicle_categories WHERE category_name='Luxury Car');

INSERT INTO customers (full_name,email,phone,address,driving_license_no)
SELECT 'Aarav Sharma','aarav.sharma@example.com','9876543210','Nagpur, Maharashtra','MH31-2024-1001'
WHERE NOT EXISTS (SELECT 1 FROM customers WHERE email='aarav.sharma@example.com');

INSERT INTO customers (full_name,email,phone,address,driving_license_no)
SELECT 'Priya Patil','priya.patil@example.com','9876543211','Pune, Maharashtra','MH12-2023-2002'
WHERE NOT EXISTS (SELECT 1 FROM customers WHERE email='priya.patil@example.com');

INSERT INTO customers (full_name,email,phone,address,driving_license_no)
SELECT 'Rohan Verma','rohan.verma@example.com','9876543212','Indore, Madhya Pradesh','MP09-2024-3003'
WHERE NOT EXISTS (SELECT 1 FROM customers WHERE email='rohan.verma@example.com');

INSERT INTO vehicles (category_id,vehicle_number,brand,model,manufacture_year,color,fuel_type,transmission,seating_capacity,status)
SELECT c.category_id,'MH31AB1234','Maruti','Swift',2023,'White','Petrol','Manual',5,'Available'
FROM vehicle_categories c WHERE c.category_name='Economy Car'
AND NOT EXISTS (SELECT 1 FROM vehicles WHERE vehicle_number='MH31AB1234');

INSERT INTO vehicles (category_id,vehicle_number,brand,model,manufacture_year,color,fuel_type,transmission,seating_capacity,status)
SELECT c.category_id,'MH31CD5678','Hyundai','Creta',2024,'Black','Diesel','Automatic',5,'Available'
FROM vehicle_categories c WHERE c.category_name='SUV'
AND NOT EXISTS (SELECT 1 FROM vehicles WHERE vehicle_number='MH31CD5678');

INSERT INTO vehicles (category_id,vehicle_number,brand,model,manufacture_year,color,fuel_type,transmission,seating_capacity,status)
SELECT c.category_id,'MH31EF9012','Honda','Activa 6G',2024,'Blue','Petrol','Automatic',2,'Available'
FROM vehicle_categories c WHERE c.category_name='Bike'
AND NOT EXISTS (SELECT 1 FROM vehicles WHERE vehicle_number='MH31EF9012');

INSERT INTO vehicles (category_id,vehicle_number,brand,model,manufacture_year,color,fuel_type,transmission,seating_capacity,status)
SELECT c.category_id,'MH31GH3456','Toyota','Fortuner',2022,'Grey','Diesel','Automatic',7,'Maintenance'
FROM vehicle_categories c WHERE c.category_name='SUV'
AND NOT EXISTS (SELECT 1 FROM vehicles WHERE vehicle_number='MH31GH3456');

INSERT INTO maintenance (vehicle_id,service_date,description,cost,maintenance_status,next_service_date)
SELECT v.vehicle_id,'2026-10-05','Routine engine and brake service',8500,'In Progress','2027-04-05'
FROM vehicles v WHERE v.vehicle_number='MH31GH3456'
AND NOT EXISTS (SELECT 1 FROM maintenance m WHERE m.vehicle_id=v.vehicle_id AND m.service_date='2026-10-05');


USE vehicle_rental_db;

DROP VIEW IF EXISTS vw_rental_details;
CREATE VIEW vw_rental_details AS
SELECT
    r.rental_id,
    c.full_name AS customer_name,
    c.phone AS customer_phone,
    v.vehicle_number,
    CONCAT(v.brand, ' ', v.model) AS vehicle_name,
    vc.category_name,
    r.rental_date,
    r.expected_return_date,
    r.actual_return_date,
    r.daily_rate,
    r.total_amount,
    r.rental_status
FROM rentals r
JOIN customers c ON c.customer_id = r.customer_id
JOIN vehicles v ON v.vehicle_id = r.vehicle_id
JOIN vehicle_categories vc ON vc.category_id = v.category_id;

DROP VIEW IF EXISTS vw_revenue_summary;
CREATE VIEW vw_revenue_summary AS
SELECT
    DATE_FORMAT(p.payment_date,'%Y-%m') AS revenue_month,
    COUNT(p.payment_id) AS payment_count,
    SUM(CASE WHEN p.payment_status='Paid' THEN p.amount ELSE 0 END) AS paid_revenue
FROM payments p
GROUP BY DATE_FORMAT(p.payment_date,'%Y-%m');


USE vehicle_rental_db;

DROP TRIGGER IF EXISTS trg_rental_before_insert;
DROP TRIGGER IF EXISTS trg_rental_after_insert;
DROP TRIGGER IF EXISTS trg_rental_after_update;

DELIMITER $$

CREATE TRIGGER trg_rental_before_insert
BEFORE INSERT ON rentals
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_rate DECIMAL(10,2);

    SELECT v.status, vc.daily_rate
      INTO v_status, v_rate
    FROM vehicles v
    JOIN vehicle_categories vc ON vc.category_id = v.category_id
    WHERE v.vehicle_id = NEW.vehicle_id
    FOR UPDATE;

    IF v_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Selected vehicle is not available.';
    END IF;

    SET NEW.daily_rate = v_rate;
    SET NEW.total_amount = GREATEST(DATEDIFF(NEW.expected_return_date, NEW.rental_date), 1) * v_rate;
    SET NEW.rental_status = 'Active';
END$$

CREATE TRIGGER trg_rental_after_insert
AFTER INSERT ON rentals
FOR EACH ROW
BEGIN
    UPDATE vehicles
       SET status='Rented'
     WHERE vehicle_id=NEW.vehicle_id;
END$$

CREATE TRIGGER trg_rental_after_update
AFTER UPDATE ON rentals
FOR EACH ROW
BEGIN
    IF NEW.rental_status='Completed' OR NEW.rental_status='Cancelled' THEN
        UPDATE vehicles
           SET status='Available'
         WHERE vehicle_id=NEW.vehicle_id;
    END IF;
END$$

DELIMITER ;


USE vehicle_rental_db;

DROP PROCEDURE IF EXISTS sp_create_rental;
DROP PROCEDURE IF EXISTS sp_complete_rental;

DELIMITER $$

CREATE PROCEDURE sp_create_rental(
    IN p_customer_id INT,
    IN p_vehicle_id INT,
    IN p_rental_date DATE,
    IN p_expected_return_date DATE,
    IN p_notes VARCHAR(500),
    OUT p_rental_id INT
)
BEGIN
    INSERT INTO rentals (
        customer_id, vehicle_id, rental_date,
        expected_return_date, notes
    )
    VALUES (
        p_customer_id, p_vehicle_id, p_rental_date,
        p_expected_return_date, p_notes
    );

    SET p_rental_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_complete_rental(
    IN p_rental_id INT,
    IN p_actual_return_date DATE
)
BEGIN
    DECLARE v_start DATE;
    DECLARE v_rate DECIMAL(10,2);

    SELECT rental_date, daily_rate
      INTO v_start, v_rate
    FROM rentals
    WHERE rental_id=p_rental_id
    FOR UPDATE;

    UPDATE rentals
       SET actual_return_date=p_actual_return_date,
           total_amount=GREATEST(DATEDIFF(p_actual_return_date, v_start),1) * v_rate,
           rental_status='Completed'
     WHERE rental_id=p_rental_id;
END$$

DELIMITER ;
