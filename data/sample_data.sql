

-- USERS (Admin + Drivers)

INSERT INTO users (username, password_hash, full_name, email, phone, role)
VALUES ('admin', 'admin123', 'System Admin', 'admin@sldro.com', '03001234567', 'admin');

INSERT INTO users (username, password_hash, full_name, email, phone, role)
VALUES ('driver1', 'drive123', 'Ali Hassan', 'ali@sldro.com', '03011234567', 'driver');

INSERT INTO users (username, password_hash, full_name, email, phone, role)
VALUES ('driver2', 'drive456', 'Usman Khan', 'usman@sldro.com', '03021234567', 'driver');


-- VEHICLES

INSERT INTO vehicles (plate_number, vehicle_type, capacity_kg, driver_id, status)
VALUES ('ABC-123', 'bike', 20, 2, 'available');

INSERT INTO vehicles (plate_number, vehicle_type, capacity_kg, driver_id, status)
VALUES ('XYZ-456', 'van', 500, 3, 'available');

INSERT INTO vehicles (plate_number, vehicle_type, capacity_kg, driver_id, status)
VALUES ('LMN-789', 'truck', 2000, NULL, 'available');


-- ORDERS (10 realistic orders)

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Ahmed Raza', '03031234567',
        'Model Town, Bahawalpur', 'Satellite Town, Bahawalpur',
        29.3956, 71.6836, 29.3876, 71.6942, 5, 'normal', 'pending');

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Sara Khan', '03041234567',
        'Civil Lines, Bahawalpur', 'Gulshan Colony, Bahawalpur',
        29.3990, 71.6750, 29.3830, 71.6800, 2, 'high', 'pending');

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Bilal Ahmed', '03051234567',
        'Baghdad ul Jadeed, Bahawalpur', 'Chisti Nagar, Bahawalpur',
        29.3800, 71.6900, 29.3750, 71.7000, 8, 'urgent', 'pending');

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Fatima Malik', '03061234567',
        'Farid Gate, Bahawalpur', 'New City, Bahawalpur',
        29.3920, 71.6780, 29.4000, 71.6850, 3, 'normal', 'pending');

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Zain ul Abadin', '03071234567',
        'Shahi Bazar, Bahawalpur', 'Airport Road, Bahawalpur',
        29.3850, 71.6820, 29.3950, 71.7100, 15, 'high', 'pending');

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Hina Butt', '03081234567',
        'Circular Road, Bahawalpur', 'Defence Colony, Bahawalpur',
        29.3880, 71.6760, 29.3820, 71.6950, 1, 'low', 'pending');

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Tariq Mehmood', '03091234567',
        'Kutchery Road, Bahawalpur', 'Model Town, Bahawalpur',
        29.3910, 71.6810, 29.3956, 71.6836, 6, 'urgent', 'pending');

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Nadia Hussain', '03101234567',
        'Gulberg, Bahawalpur', 'Satellite Town, Bahawalpur',
        29.3840, 71.6890, 29.3876, 71.6942, 4, 'normal', 'pending');

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Kamran Ali', '03111234567',
        'Stadium Road, Bahawalpur', 'Civil Lines, Bahawalpur',
        29.3970, 71.6870, 29.3990, 71.6750, 10, 'high', 'pending');

INSERT INTO orders (customer_name, customer_phone, pickup_address, drop_address,
                    pickup_lat, pickup_lng, drop_lat, drop_lng,
                    weight_kg, priority, status)
VALUES ('Sana Nawaz', '03121234567',
        'Nishat Colony, Bahawalpur', 'Baghdad ul Jadeed, Bahawalpur',
        29.3760, 71.6920, 29.3800, 71.6900, 7, 'low', 'pending');

COMMIT;