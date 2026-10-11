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
