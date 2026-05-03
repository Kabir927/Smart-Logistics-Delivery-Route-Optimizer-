# SLDRO - Database Connection Module


import oracledb

# Database configuration
DB_CONFIG = {
    "user":     "C##sldro",
    "password": "sldro123",
    "host":     "localhost",
    "port":     1521,
    "sid":      "xe"
}

def get_connection():
    # Creates and returns Oracle DB connection
    try:
        dsn = oracledb.makedsn(
            DB_CONFIG["host"],
            DB_CONFIG["port"],
            sid=DB_CONFIG["sid"]
        )
        connection = oracledb.connect(
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
            dsn=dsn
        )
        print("Database connected successfully!")
        return connection

    except oracledb.DatabaseError as e:
        print(f"Connection failed: {e}")
        return None


def fetch_pending_orders():
    # Fetches all pending orders from database
    connection = get_connection()
    if connection is None:
        return []

    try:
        cursor = connection.cursor()
        cursor.execute("""
            SELECT
                order_id, customer_name, customer_phone,
                pickup_address, drop_address,
                pickup_lat, pickup_lng,
                drop_lat, drop_lng,
                weight_kg, priority, status
            FROM orders
            WHERE status = 'pending'
            ORDER BY
                CASE priority
                    WHEN 'urgent' THEN 1
                    WHEN 'high'   THEN 2
                    WHEN 'normal' THEN 3
                    WHEN 'low'    THEN 4
                END
        """)

        columns = [col[0].lower() for col in cursor.description]
        orders = [dict(zip(columns, row)) for row in cursor.fetchall()]

        print(f"Fetched {len(orders)} pending orders.")
        cursor.close()
        connection.close()
        return orders

    except oracledb.DatabaseError as e:
        print(f"Error fetching orders: {e}")
        return []


def update_order_status(order_id, new_status):
    # Updates the status of a specific order
    connection = get_connection()
    if connection is None:
        return False

    try:
        cursor = connection.cursor()
        cursor.execute("""
            UPDATE orders
            SET status = :status
            WHERE order_id = :order_id
        """, {"status": new_status, "order_id": order_id})

        connection.commit()
        print(f"Order #{order_id} status updated to: {new_status}")
        cursor.close()
        connection.close()
        return True

    except oracledb.DatabaseError as e:
        print(f"Error updating order: {e}")
        return False


def save_route(vehicle_id, route_name, total_distance,
               estimated_time, cluster_id):
    # Saves AI-generated route to database
    connection = get_connection()
    if connection is None:
        return False

    try:
        cursor = connection.cursor()
        cursor.execute("""
            INSERT INTO routes (
                vehicle_id, route_name,
                total_distance, estimated_time,
                cluster_id, status
            ) VALUES (
                :vehicle_id, :route_name,
                :total_distance, :estimated_time,
                :cluster_id, 'planned'
            )
        """, {
            "vehicle_id":     vehicle_id,
            "route_name":     route_name,
            "total_distance": total_distance,
            "estimated_time": estimated_time,
            "cluster_id":     cluster_id
        })

        connection.commit()
        print(f"Route '{route_name}' saved to database.")
        cursor.close()
        connection.close()
        return True

    except oracledb.DatabaseError as e:
        print(f"Error saving route: {e}")
        return False


if __name__ == "__main__":
    print("--- Testing Database Connection ---")

    conn = get_connection()
    if conn:
        conn.close()
        print("Test 1: Connection = PASSED")
    else:
        print("Test 1: Connection = FAILED")

    print("\nTest 2: Fetching pending orders...")
    orders = fetch_pending_orders()
    if orders:
        print(f"Found {len(orders)} pending orders:")
        for order in orders:
            print(f"  Order #{order['order_id']} | "
                  f"{order['customer_name']} | "
                  f"Priority: {order['priority']}")
    else:
        print("No orders found.")

    print("--- Test Complete ---")