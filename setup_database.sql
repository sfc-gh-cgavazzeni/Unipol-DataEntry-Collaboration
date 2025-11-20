-- ============================================
-- Snowflake Database Setup Script
-- Insurance Customer Management System
-- ============================================

-- Create database and schema (adjust as needed)
-- CREATE DATABASE IF NOT EXISTS INSURANCE_DB;
-- USE DATABASE INSURANCE_DB;
-- CREATE SCHEMA IF NOT EXISTS CUSTOMER_MGMT;
-- USE SCHEMA CUSTOMER_MGMT;

-- Main customer table
CREATE OR REPLACE TABLE CUSTOMERS (
    CUSTOMER_ID NUMBER AUTOINCREMENT PRIMARY KEY,
    FIRST_NAME VARCHAR(100),
    LAST_NAME VARCHAR(100),
    EMAIL VARCHAR(200),
    PHONE VARCHAR(20),
    POLICY_TYPE VARCHAR(50),
    POLICY_NUMBER VARCHAR(50),
    PREMIUM_AMOUNT NUMBER(10, 2),
    STATUS VARCHAR(20),
    START_DATE DATE,
    LAST_MODIFIED_BY VARCHAR(100),
    LAST_MODIFIED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Audit log table to track all changes
CREATE OR REPLACE TABLE CUSTOMER_AUDIT_LOG (
    AUDIT_ID NUMBER AUTOINCREMENT PRIMARY KEY,
    CUSTOMER_ID NUMBER,
    MODIFIED_BY VARCHAR(100),
    MODIFIED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    COMMENT TEXT,
    CHANGE_TYPE VARCHAR(20), -- 'UPDATE', 'INSERT', 'DELETE'
    OLD_VALUES VARIANT,
    NEW_VALUES VARIANT
);

-- Create a stream on the customers table to track changes
CREATE OR REPLACE STREAM CUSTOMERS_STREAM ON TABLE CUSTOMERS
    SHOW_INITIAL_ROWS = FALSE;

-- Insert sample data
INSERT INTO CUSTOMERS (FIRST_NAME, LAST_NAME, EMAIL, PHONE, POLICY_TYPE, POLICY_NUMBER, PREMIUM_AMOUNT, STATUS, START_DATE, LAST_MODIFIED_BY)
VALUES
    ('Mario', 'Rossi', 'mario.rossi@email.it', '+39 340 1234567', 'Auto', 'POL-AUTO-001', 850.00, 'Active', '2023-01-15', 'SYSTEM'),
    ('Laura', 'Bianchi', 'laura.bianchi@email.it', '+39 348 7654321', 'Home', 'POL-HOME-002', 1200.00, 'Active', '2023-03-22', 'SYSTEM'),
    ('Giuseppe', 'Verdi', 'giuseppe.verdi@email.it', '+39 335 9876543', 'Life', 'POL-LIFE-003', 2500.00, 'Active', '2022-11-10', 'SYSTEM'),
    ('Anna', 'Russo', 'anna.russo@email.it', '+39 347 5551234', 'Health', 'POL-HEALTH-004', 1800.00, 'Active', '2023-05-08', 'SYSTEM'),
    ('Franco', 'Ferrari', 'franco.ferrari@email.it', '+39 333 4445566', 'Auto', 'POL-AUTO-005', 920.00, 'Pending', '2024-01-20', 'SYSTEM'),
    ('Giulia', 'Romano', 'giulia.romano@email.it', '+39 349 7778889', 'Home', 'POL-HOME-006', 1350.00, 'Active', '2023-07-14', 'SYSTEM'),
    ('Roberto', 'Esposito', 'roberto.esposito@email.it', '+39 338 2223334', 'Life', 'POL-LIFE-007', 3200.00, 'Active', '2022-09-05', 'SYSTEM'),
    ('Chiara', 'Colombo', 'chiara.colombo@email.it', '+39 346 6667778', 'Health', 'POL-HEALTH-008', 1650.00, 'Suspended', '2023-02-18', 'SYSTEM');

-- Grant necessary permissions (adjust based on your Snowflake setup)
-- GRANT SELECT, INSERT, UPDATE ON TABLE CUSTOMERS TO ROLE YOUR_ROLE;
-- GRANT SELECT, INSERT ON TABLE CUSTOMER_AUDIT_LOG TO ROLE YOUR_ROLE;
-- GRANT SELECT ON STREAM CUSTOMERS_STREAM TO ROLE YOUR_ROLE;

-- Verify data
SELECT * FROM CUSTOMERS ORDER BY CUSTOMER_ID;
SELECT * FROM CUSTOMER_AUDIT_LOG ORDER BY AUDIT_ID DESC;
SELECT * FROM CUSTOMERS_STREAM;

