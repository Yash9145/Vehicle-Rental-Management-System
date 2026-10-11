USE vehicle_rental_db;

-- 1. Available vehicles
SELECT v.vehicle_id, v.vehicle_number, v.brand, v.model,
       vc.category_name, vc.daily_rate
FROM vehicles v
JOIN vehicle_categories vc ON vc.category_id=v.category_id
WHERE v.status='Available';

-- 2. Active rentals with customer and vehicle
SELECT r.rental_id, c.full_name, v.vehicle_number,
       r.rental_date, r.expected_return_date, r.total_amount
FROM rentals r
JOIN customers c ON c.customer_id=r.customer_id
JOIN vehicles v ON v.vehicle_id=r.vehicle_id
WHERE r.rental_status='Active';

-- 3. Customer rental history
SELECT c.full_name, v.vehicle_number, r.rental_date,
       r.expected_return_date, r.total_amount, r.rental_status
FROM customers c
LEFT JOIN rentals r ON r.customer_id=c.customer_id
LEFT JOIN vehicles v ON v.vehicle_id=r.vehicle_id
ORDER BY c.full_name, r.rental_date DESC;

-- 4. Revenue by payment method
SELECT payment_method, COUNT(*) AS transactions,
       SUM(amount) AS total_revenue
FROM payments
WHERE payment_status='Paid'
GROUP BY payment_method;

-- 5. Top rented vehicles
SELECT v.vehicle_number, CONCAT(v.brand,' ',v.model) AS vehicle,
       COUNT(r.rental_id) AS rental_count
FROM vehicles v
LEFT JOIN rentals r ON r.vehicle_id=v.vehicle_id
GROUP BY v.vehicle_id
ORDER BY rental_count DESC;

-- 6. Maintenance cost by vehicle
SELECT v.vehicle_number, CONCAT(v.brand,' ',v.model) AS vehicle,
       COALESCE(SUM(m.cost),0) AS maintenance_cost
FROM vehicles v
LEFT JOIN maintenance m ON m.vehicle_id=v.vehicle_id
GROUP BY v.vehicle_id
ORDER BY maintenance_cost DESC;
