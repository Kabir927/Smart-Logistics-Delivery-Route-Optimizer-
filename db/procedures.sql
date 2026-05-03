
-- PROCEDURE 1: Insert New Order
-- Called by Python when new order arrives

CREATE OR REPLACE PROCEDURE insert_order (
    p_customer_name   IN VARCHAR2,
    p_customer_phone  IN VARCHAR2,
    p_pickup_address  IN VARCHAR2,
    p_drop_address    IN VARCHAR2,
    p_pickup_lat      IN NUMBER,
    p_pickup_lng      IN NUMBER,
    p_drop_lat        IN NUMBER,
    p_drop_lng        IN NUMBER,
    p_weight_kg       IN NUMBER,
    p_priority        IN VARCHAR2,
    p_order_id        OUT NUMBER
)
AS
BEGIN
    -- Insert the new order into orders table
    INSERT INTO orders (
        customer_name,
        customer_phone,
        pickup_address,
        drop_address,
        pickup_lat,
        pickup_lng,
        drop_lat,
        drop_lng,
        weight_kg,
        priority,
        status
    ) VALUES (
        p_customer_name,
        p_customer_phone,
        p_pickup_address,
        p_drop_address,
        p_pickup_lat,
        p_pickup_lng,
        p_drop_lat,
        p_drop_lng,
        p_weight_kg,
        p_priority,
        'pending'
    )
    RETURNING order_id INTO p_order_id;

    COMMIT;


    INSERT INTO logs (action_type, table_name, record_id, action_by, description)
    VALUES ('INSERT', 'ORDERS', p_order_id, 'PYTHON_APP',
            'New order inserted via procedure for: ' || p_customer_name);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END insert_order;
/


-- PROCEDURE 2: Assign Vehicle to Order
-- Called by Python AI after clustering

CREATE OR REPLACE PROCEDURE assign_vehicle (
    p_order_id    IN NUMBER,
    p_vehicle_id  IN NUMBER
)
AS
BEGIN

    UPDATE orders
    SET assigned_vehicle = p_vehicle_id,
        status = 'assigned'
    WHERE order_id = p_order_id
    AND status = 'pending';


    UPDATE vehicles
    SET status = 'on_route'
    WHERE vehicle_id = p_vehicle_id;

    COMMIT;


    INSERT INTO logs (action_type, table_name, record_id, action_by, description)
    VALUES ('UPDATE', 'ORDERS', p_order_id, 'AI_MODULE',
            'Vehicle #' || p_vehicle_id || ' assigned to Order #' || p_order_id);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END assign_vehicle;
/


-- PROCEDURE 3: Update Order Status
-- Called throughout delivery process

CREATE OR REPLACE PROCEDURE update_order_status (
    p_order_id  IN NUMBER,
    p_status    IN VARCHAR2
)
AS
BEGIN
   
    UPDATE orders
    SET status = p_status
    WHERE order_id = p_order_id;

    COMMIT;

   
    INSERT INTO logs (action_type, table_name, record_id, action_by, description)
    VALUES ('UPDATE', 'ORDERS', p_order_id, 'PYTHON_APP',
            'Order #' || p_order_id || ' status updated to: ' || p_status);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END update_order_status;
/


-- PROCEDURE 4: Save AI Route Result
-- Called by Python after route optimization

CREATE OR REPLACE PROCEDURE save_route (
    p_vehicle_id      IN NUMBER,
    p_route_name      IN VARCHAR2,
    p_total_distance  IN NUMBER,
    p_estimated_time  IN NUMBER,
    p_cluster_id      IN NUMBER,
    p_route_id        OUT NUMBER
)
AS
BEGIN

    INSERT INTO routes (
        vehicle_id,
        route_name,
        total_distance,
        estimated_time,
        cluster_id,
        status
    ) VALUES (
        p_vehicle_id,
        p_route_name,
        p_total_distance,
        p_estimated_time,
        p_cluster_id,
        'planned'
    )
    RETURNING route_id INTO p_route_id;

    COMMIT;


    INSERT INTO logs (action_type, table_name, record_id, action_by, description)
    VALUES ('INSERT', 'ROUTES', p_route_id, 'AI_MODULE',
            'AI generated route: ' || p_route_name ||
            ' | Distance: ' || p_total_distance || ' km');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END save_route;
/


-- PROCEDURE 5: Get All Pending Orders
-- Called by Python to fetch orders for AI

CREATE OR REPLACE PROCEDURE get_pending_orders (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    -- Return all pending orders as a cursor
    OPEN p_cursor FOR
        SELECT
            order_id,
            customer_name,
            customer_phone,
            pickup_address,
            drop_address,
            pickup_lat,
            pickup_lng,
            drop_lat,
            drop_lng,
            weight_kg,
            priority,
            status,
            created_at
        FROM orders
        WHERE status = 'pending'
        ORDER BY
            CASE priority
                WHEN 'urgent' THEN 1
                WHEN 'high'   THEN 2
                WHEN 'normal' THEN 3
                WHEN 'low'    THEN 4
            END,
            created_at ASC;
END get_pending_orders;
/

COMMIT;