CREATE EXTENSION plpython3u;
CREATE EXTENSION jsonb_plpython3u;

CREATE TABLE job (
    job_id SERIAL PRIMARY KEY,
    function VARCHAR(30)
);

CREATE TABLE location (
    location_id SERIAL PRIMARY KEY,
    regional_group VARCHAR(20)
);

CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(14),
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES location (location_id)
);

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(15),
    first_name VARCHAR(15),
    middle_initial VARCHAR(1),
    manager_id INTEGER,
    CONSTRAINT ref_emp_manager FOREIGN KEY (manager_id) REFERENCES employee (employee_id),
    job_id INTEGER,
    hire_date DATE,
    salary NUMERIC(7,2),
    commission NUMERIC(7,2),
    department_id INTEGER,
    FOREIGN KEY (job_id) REFERENCES job (job_id),
    FOREIGN KEY (department_id) REFERENCES department (department_id)
);

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(45),
    address VARCHAR(40),
    city VARCHAR(30),
    state VARCHAR(2),
    zip_code VARCHAR(9),
    area_code SMALLINT,
    phone_number SMALLINT,
    salesperson_id INTEGER,
    credit_limit NUMERIC(9,2),
    comments TEXT,
    FOREIGN KEY (salesperson_id) REFERENCES employee (employee_id)
);

CREATE TABLE sales_order (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    customer_id INTEGER,
    ship_date DATE,
    total NUMERIC(8,2),
    FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
);

CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    description VARCHAR(30)
);

CREATE TABLE item (
    item_id SERIAL,
    order_id INTEGER,
    product_id INTEGER,
    actual_price NUMERIC(8,2),
    quantity INTEGER,
    total NUMERIC(8,2),
    PRIMARY KEY (item_id, order_id),
    FOREIGN KEY (order_id) REFERENCES sales_order (order_id),
    FOREIGN KEY (product_id) REFERENCES product (product_id)
);

CREATE TABLE price (
    product_id INTEGER,
    start_date DATE,
    list_price NUMERIC(8,2),
    min_price NUMERIC(8,2),
    end_date DATE,
    PRIMARY KEY (product_id, start_date),
    FOREIGN KEY (product_id) REFERENCES product (product_id)
);

--Insert data

INSERT INTO job (function) VALUES 
('Function 1'),
('Function 2'),
('Function 3'),
('Function 4'),
('Function 5');

INSERT INTO location (regional_group) VALUES 
('Location 1'),
('Location 2'),
('Location 3'),
('Location 4'),
('Location 5');

INSERT INTO department (name, location_id) VALUES 
('Department 1', 1),
('Department 2', 2),
('Department 3', 3),
('Department 4', 4),
('Department 5', 5);

INSERT INTO employee (last_name, first_name, middle_initial, manager_id, job_id, hire_date, salary, commission, department_id) VALUES
('Brown', 'John', 'A', NULL, 1, '2024-01-05', 90000.00, 1000.00, 1),
('Green', 'Robert', 'B', 3, 2, '2024-02-04', 50000.00, 2000.00, 2),
('White', 'Alex', 'C', NULL, 3, '2024-03-03', 90000.00, 3000.00, 3),
('Black', 'Ash', 'D', 3, 4, '2024-04-02', 60000.00, 4000.00, 4),
('Gray', 'Max', 'E', 1, 5, '2024-05-01', 70000.00, 5000.00, 5);

INSERT INTO customer (name, address, city, state, zip_code, area_code, phone_number, salesperson_id, credit_limit) VALUES
('Gary Greer', '812 Cedar St #246', 'Story City', 'IA', '50248', 123, 4236, 1, 100000.00),
('Mark Jones', ' 21255 County Rd #16', 'Oak Creek', 'CO', '80467', 456, 6523, 2, 200000.00),
('Leonard Clark', '5412 Timberwolf Ct', 'Eielson Afb', 'AK', '99702', 789, 4312, 3, 300000.00),
('Edward Banks', '9 Moss Point Dr', 'Ormond Beach', 'FL', '32174', 987, 7653, 4, 250000.00),
('Ray Schwartz', '416 E Monroe St', 'Sterling', 'KS', '67579', 654, 1235, 5, 150000.00);

INSERT INTO sales_order (order_date, customer_id, ship_date, total) VALUES
('2024-01-01', 1, '2024-06-05', 100000.00),
('2024-02-02', 2, '2024-07-05', 150000.00),
('2024-03-03', 3, '2024-08-05', 200000.00),
('2024-04-04', 4, '2024-09-05', 100000.00),
('2024-05-05', 5, '2024-10-05', 150000.00);

INSERT INTO product (description) VALUES
('Product 1'),
('Product 2'),
('Product 3'),
('Product 4'),
('Product 5');

INSERT INTO item (order_id, product_id, actual_price, quantity, total) VALUES
(1, 1, 1000.00, 110, 110000.00),
(2, 2, 2000.00, 70, 140000.00),
(3, 3, 3000.00, 60, 180000.00),
(4, 4, 4000.00, 30, 120000.00),
(5, 5, 5000.00, 50, 250000.00);

INSERT INTO price (product_id, start_date, list_price, min_price, end_date) VALUES
(1, '2024-01-01', 1000.00, 500.00, '2025-01-01'),
(2, '2024-01-01', 2000.00, 1800.00, '2025-01-01'),
(3, '2024-01-01', 4000.00, 3000.00, '2025-01-01'),
(4, '2024-01-01', 4500.00, 4000.00, '2025-01-01'),
(5, '2024-01-01', 5000.00, 2700.00, '2025-01-01');