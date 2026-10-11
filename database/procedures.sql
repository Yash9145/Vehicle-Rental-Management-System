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
