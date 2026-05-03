
-- TRIGGER 1: Log every NEW order inserted
-- Fires automatically after INSERT on orders
CREATE OR REPLACE TRIGGER trg_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO logs (
        action_type,
        table_name,
        record_id,
        action_by,
        description
    ) VALUES (
        'INSERT',
        'ORDERS',
        :NEW.order_id,
        'SYSTEM',
        'New order created for customer: ' || :NEW.customer_name ||
        ' | Priority: ' || :NEW.priority ||
        ' | Status: ' || :NEW.status
    );
END;
/


-- TRIGGER 2: Log every order STATUS change
-- Fires automatically after UPDATE on orders

CREATE OR REPLACE TRIGGER trg_order_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Only log if status actually changed
    IF :OLD.status != :NEW.status THEN
        INSERT INTO logs (
            action_type,
            table_name,
            record_id,
            action_by,
            description
        ) VALUES (
            'UPDATE',
            'ORDERS',
            :NEW.order_id,
            'SYSTEM',
            'Order #' || :NEW.order_id ||
            ' status changed from [' || :OLD.status ||
            '] to [' || :NEW.status || ']'
        );
    END IF;
END;
/


-- TRIGGER 3: Log every VEHICLE status change
-- Fires automatically after UPDATE on vehicles

CREATE OR REPLACE TRIGGER trg_vehicle_update
AFTER UPDATE ON vehicles
FOR EACH ROW
BEGIN
    IF :OLD.status != :NEW.status THEN
        INSERT INTO logs (
            action_type,
            table_name,
            record_id,
            action_by,
            description
        ) VALUES (
            'UPDATE',
            'VEHICLES',
            :NEW.vehicle_id,
            'SYSTEM',
            'Vehicle ' || :NEW.plate_number ||
            ' status changed from [' || :OLD.status ||
            '] to [' || :NEW.status || ']'
        );
    END IF;
END;
/


-- TRIGGER 4: Prevent deleting delivered orders
-- Fires automatically BEFORE DELETE on orders

CREATE OR REPLACE TRIGGER trg_prevent_delete
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    IF :OLD.status = 'delivered' THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'ERROR: Cannot delete a delivered order! Order #' ||
            :OLD.order_id || ' is already delivered.'
        );
    END IF;
END;
/

-- TRIGGER 5: Auto-set delivered_at timestamp
-- Fires when order status becomes "delivered"
CREATE OR REPLACE TRIGGER trg_set_delivered_time
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF :NEW.status = 'delivered' AND :OLD.status != 'delivered' THEN
        :NEW.delivered_at := CURRENT_TIMESTAMP;
    END IF;
END;
/

COMMIT;