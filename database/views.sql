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
