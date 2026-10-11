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
