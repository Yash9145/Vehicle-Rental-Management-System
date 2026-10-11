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
