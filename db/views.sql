
-- VIEW 1: Pending Orders with Full Details

CREATE OR REPLACE VIEW vw_pending_orders AS
SELECT
    o.order_id,
    o.customer_name,
    o.customer_phone,
    o.pickup_address,
    o.drop_address,
    o.pickup_lat,
    o.pickup_lng,
    o.drop_lat,
    o.drop_lng,
    o.weight_kg,
    o.priority,
    o.status,
    o.created_at,
    ROUND((CAST(CURRENT_TIMESTAMP AS DATE) -
           CAST(o.created_at AS DATE)) * 24 * 60) AS waiting_minutes
FROM orders o
WHERE o.status = 'pending'
ORDER BY
    CASE o.priority
        WHEN 'urgent' THEN 1
        WHEN 'high'   THEN 2
        WHEN 'normal' THEN 3
        WHEN 'low'    THEN 4
    END;


-- VIEW 2: Active Routes with Vehicle Info

CREATE OR REPLACE VIEW vw_active_routes AS
SELECT
    r.route_id,
    r.route_name,
    r.total_distance,
    r.estimated_time,
    r.cluster_id,
    r.status AS route_status,
    v.plate_number,
    v.vehicle_type,
    v.capacity_kg,
    u.full_name AS driver_name,
    u.phone AS driver_phone,
    r.created_at
FROM routes r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
JOIN users u    ON v.driver_id  = u.user_id
WHERE r.status IN ('planned', 'active');


-- VIEW 3: Complete Delivery Summary
-- Shows statistics for dashboard

CREATE OR REPLACE VIEW vw_delivery_summary AS
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'pending'    THEN 1 ELSE 0 END) AS pending_orders,
    SUM(CASE WHEN status = 'assigned'   THEN 1 ELSE 0 END) AS assigned_orders,
    SUM(CASE WHEN status = 'in_transit' THEN 1 ELSE 0 END) AS in_transit_orders,
    SUM(CASE WHEN status = 'delivered'  THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN status = 'cancelled'  THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(
        SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0), 2
    ) AS success_rate_percent
FROM orders;


-- VIEW 4: Vehicle Status with Driver Info
-- Shows all vehicles and their current status

CREATE OR REPLACE VIEW vw_vehicle_status AS
SELECT
    v.vehicle_id,
    v.plate_number,
    v.vehicle_type,
    v.capacity_kg,
    v.status AS vehicle_status,
    u.full_name AS driver_name,
    u.phone AS driver_phone,
    u.email AS driver_email,
    (SELECT COUNT(*)
     FROM orders o
     WHERE o.assigned_vehicle = v.vehicle_id) AS total_orders_assigned
FROM vehicles v
LEFT JOIN users u ON v.driver_id = u.user_id;

COMMIT;