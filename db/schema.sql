
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE logs CASCADE CONSTRAINTS';
   EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE routes CASCADE CONSTRAINTS';
   EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE orders CASCADE CONSTRAINTS';
   EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE vehicles CASCADE CONSTRAINTS';
   EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS';
   EXCEPTION WHEN OTHERS THEN NULL;
END;
/


-- TABLE 1: USERS

CREATE TABLE users (
    user_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username      VARCHAR2(50)  NOT NULL UNIQUE,
    password_hash VARCHAR2(255) NOT NULL,
    full_name     VARCHAR2(100) NOT NULL,
    email         VARCHAR2(100) UNIQUE,
    phone         VARCHAR2(20),
    role          VARCHAR2(20)  DEFAULT 'driver'
                  CHECK (role IN ('admin','driver','manager')),
    is_active     NUMBER(1)     DEFAULT 1,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);



-- TABLE 2: VEHICLES
-- Stores delivery vehicle information

CREATE TABLE vehicles (
    vehicle_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    plate_number  VARCHAR2(20)  NOT NULL UNIQUE,
    vehicle_type  VARCHAR2(30)  CHECK (vehicle_type IN ('bike','van','truck')),
    capacity_kg   NUMBER(10,2)  NOT NULL,
    driver_id     NUMBER        REFERENCES users(user_id),
    status        VARCHAR2(20)  DEFAULT 'available'
                  CHECK (status IN ('available','on_route','maintenance')),
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);


-- TABLE 3: ORDERS
-- Stores all delivery orders

CREATE TABLE orders (
    order_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_name   VARCHAR2(100) NOT NULL,
    customer_phone  VARCHAR2(20),
    pickup_address  VARCHAR2(255) NOT NULL,
    drop_address    VARCHAR2(255) NOT NULL,
    pickup_lat      NUMBER(10,6),
    pickup_lng      NUMBER(10,6),
    drop_lat        NUMBER(10,6),
    drop_lng        NUMBER(10,6),
    weight_kg       NUMBER(10,2) DEFAULT 1,
    priority        VARCHAR2(10) DEFAULT 'normal'
                    CHECK (priority IN ('low','normal','high','urgent')),
    status          VARCHAR2(20) DEFAULT 'pending'
                    CHECK (status IN ('pending','assigned',
                                      'in_transit','delivered','cancelled')),
    assigned_vehicle NUMBER      REFERENCES vehicles(vehicle_id),
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    delivered_at    TIMESTAMP
);


-- TABLE 4: ROUTES
-- Stores AI-optimized delivery routes

CREATE TABLE routes (
    route_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vehicle_id      NUMBER        REFERENCES vehicles(vehicle_id),
    route_name      VARCHAR2(100),
    total_distance  NUMBER(10,2),
    estimated_time  NUMBER(10,2),
    cluster_id      NUMBER,
    status          VARCHAR2(20) DEFAULT 'planned'
                    CHECK (status IN ('planned','active','completed')),
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);


-- TABLE 5: LOGS
-- Automatically records every action

CREATE TABLE logs (
    log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    action_type VARCHAR2(50)  NOT NULL,
    table_name  VARCHAR2(50)  NOT NULL,
    record_id   NUMBER,
    action_by   VARCHAR2(50),
    description VARCHAR2(500),
    action_time TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);


CREATE SEQUENCE seq_user_id    START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_order_id   START WITH 2001 INCREMENT BY 1;
CREATE SEQUENCE seq_vehicle_id START WITH 3001 INCREMENT BY 1;
CREATE SEQUENCE seq_route_id   START WITH 4001 INCREMENT BY 1;

COMMIT;