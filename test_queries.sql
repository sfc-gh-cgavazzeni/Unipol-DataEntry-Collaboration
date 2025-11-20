-- ============================================
-- Test Queries for Insurance Customer Management System
-- Run these queries to verify your setup
-- ============================================

-- ============================================
-- 1. BASIC VERIFICATION
-- ============================================

-- Check if tables exist
SHOW TABLES IN SCHEMA CUSTOMER_MGMT;

-- Check if stream exists
SHOW STREAMS IN SCHEMA CUSTOMER_MGMT;

-- Count customers (should be 8)
SELECT COUNT(*) as TOTAL_CUSTOMERS FROM CUSTOMERS;

-- View all customers
SELECT 
    CUSTOMER_ID,
    FIRST_NAME || ' ' || LAST_NAME as CUSTOMER_NAME,
    EMAIL,
    POLICY_TYPE,
    POLICY_NUMBER,
    PREMIUM_AMOUNT,
    STATUS
FROM CUSTOMERS
ORDER BY CUSTOMER_ID;

-- ============================================
-- 2. FILTERING TESTS
-- ============================================

-- Find all active customers
SELECT COUNT(*) as ACTIVE_CUSTOMERS 
FROM CUSTOMERS 
WHERE STATUS = 'Active';

-- Find all auto policies
SELECT 
    FIRST_NAME || ' ' || LAST_NAME as CUSTOMER_NAME,
    POLICY_NUMBER,
    PREMIUM_AMOUNT
FROM CUSTOMERS
WHERE POLICY_TYPE = 'Auto'
ORDER BY PREMIUM_AMOUNT DESC;

-- Find customers with premium > €2000
SELECT 
    FIRST_NAME || ' ' || LAST_NAME as CUSTOMER_NAME,
    POLICY_TYPE,
    PREMIUM_AMOUNT
FROM CUSTOMERS
WHERE PREMIUM_AMOUNT > 2000
ORDER BY PREMIUM_AMOUNT DESC;

-- Search for specific customer (example: Mario)
SELECT * 
FROM CUSTOMERS 
WHERE FIRST_NAME ILIKE '%mario%' 
   OR LAST_NAME ILIKE '%mario%' 
   OR EMAIL ILIKE '%mario%';

-- ============================================
-- 3. AGGREGATION QUERIES
-- ============================================

-- Count customers by policy type
SELECT 
    POLICY_TYPE,
    COUNT(*) as CUSTOMER_COUNT,
    AVG(PREMIUM_AMOUNT) as AVG_PREMIUM,
    SUM(PREMIUM_AMOUNT) as TOTAL_PREMIUM
FROM CUSTOMERS
GROUP BY POLICY_TYPE
ORDER BY TOTAL_PREMIUM DESC;

-- Count customers by status
SELECT 
    STATUS,
    COUNT(*) as COUNT
FROM CUSTOMERS
GROUP BY STATUS
ORDER BY COUNT DESC;

-- Calculate total premiums by status
SELECT 
    STATUS,
    COUNT(*) as CUSTOMER_COUNT,
    SUM(PREMIUM_AMOUNT) as TOTAL_PREMIUM,
    AVG(PREMIUM_AMOUNT) as AVG_PREMIUM
FROM CUSTOMERS
GROUP BY STATUS;

-- ============================================
-- 4. AUDIT LOG TESTS
-- ============================================

-- Check audit log (will be empty initially)
SELECT COUNT(*) as TOTAL_AUDIT_RECORDS 
FROM CUSTOMER_AUDIT_LOG;

-- View recent audit entries
SELECT 
    AUDIT_ID,
    CUSTOMER_ID,
    MODIFIED_BY,
    TO_VARCHAR(MODIFIED_AT, 'YYYY-MM-DD HH24:MI:SS') as MODIFIED_AT,
    CHANGE_TYPE,
    COMMENT
FROM CUSTOMER_AUDIT_LOG
ORDER BY MODIFIED_AT DESC
LIMIT 10;

-- Find all changes by a specific user (replace 'YOUR_USER')
SELECT 
    CUSTOMER_ID,
    MODIFIED_AT,
    CHANGE_TYPE,
    COMMENT
FROM CUSTOMER_AUDIT_LOG
WHERE MODIFIED_BY = 'YOUR_USER'
ORDER BY MODIFIED_AT DESC;

-- ============================================
-- 5. STREAM TESTS
-- ============================================

-- Check stream status
DESCRIBE STREAM CUSTOMERS_STREAM;

-- View stream changes (empty initially, populates after edits)
SELECT * FROM CUSTOMERS_STREAM;

-- Count changes in stream
SELECT 
    METADATA$ACTION as ACTION,
    COUNT(*) as COUNT
FROM CUSTOMERS_STREAM
GROUP BY METADATA$ACTION;

-- ============================================
-- 6. MANUAL UPDATE TEST (Optional)
-- ============================================

-- Test updating a customer (simulates app edit)
-- This will create audit log and stream entries

-- Get current value
SELECT * FROM CUSTOMERS WHERE CUSTOMER_ID = 1;

-- Update customer
UPDATE CUSTOMERS 
SET 
    STATUS = 'Active',
    PREMIUM_AMOUNT = 900.00,
    LAST_MODIFIED_BY = CURRENT_USER(),
    LAST_MODIFIED_AT = CURRENT_TIMESTAMP()
WHERE CUSTOMER_ID = 1;

-- Insert audit log entry
INSERT INTO CUSTOMER_AUDIT_LOG 
    (CUSTOMER_ID, MODIFIED_BY, COMMENT, CHANGE_TYPE, OLD_VALUES, NEW_VALUES)
VALUES (
    1,
    CURRENT_USER(),
    'Manual test update',
    'UPDATE',
    PARSE_JSON('{"PREMIUM_AMOUNT": 850.00, "STATUS": "Active"}'),
    PARSE_JSON('{"PREMIUM_AMOUNT": 900.00, "STATUS": "Active"}')
);

-- Verify update
SELECT * FROM CUSTOMERS WHERE CUSTOMER_ID = 1;

-- Check audit log
SELECT * FROM CUSTOMER_AUDIT_LOG ORDER BY AUDIT_ID DESC LIMIT 1;

-- Check stream (should show the change)
SELECT * FROM CUSTOMERS_STREAM LIMIT 5;

-- ============================================
-- 7. PERMISSIONS CHECK
-- ============================================

-- Check current user
SELECT CURRENT_USER() as USER_NAME;

-- Check current role
SELECT CURRENT_ROLE() as ROLE_NAME;

-- Check current database and schema
SELECT CURRENT_DATABASE() as DATABASE_NAME;
SELECT CURRENT_SCHEMA() as SCHEMA_NAME;

-- Check grants on CUSTOMERS table
SHOW GRANTS ON TABLE CUSTOMERS;

-- Check grants on CUSTOMER_AUDIT_LOG table
SHOW GRANTS ON TABLE CUSTOMER_AUDIT_LOG;

-- Check grants on CUSTOMERS_STREAM
SHOW GRANTS ON STREAM CUSTOMERS_STREAM;

-- ============================================
-- 8. DATA QUALITY CHECKS
-- ============================================

-- Find customers with missing emails
SELECT * FROM CUSTOMERS WHERE EMAIL IS NULL OR EMAIL = '';

-- Find customers with invalid premium (negative or zero)
SELECT * FROM CUSTOMERS WHERE PREMIUM_AMOUNT <= 0;

-- Find duplicate policy numbers (should be none)
SELECT 
    POLICY_NUMBER,
    COUNT(*) as COUNT
FROM CUSTOMERS
GROUP BY POLICY_NUMBER
HAVING COUNT(*) > 1;

-- Find customers without phone numbers
SELECT * FROM CUSTOMERS WHERE PHONE IS NULL OR PHONE = '';

-- ============================================
-- 9. TEMPORAL QUERIES
-- ============================================

-- Customers added in last 30 days
SELECT 
    FIRST_NAME || ' ' || LAST_NAME as CUSTOMER_NAME,
    START_DATE,
    DATEDIFF('day', START_DATE, CURRENT_DATE()) as DAYS_SINCE_START
FROM CUSTOMERS
WHERE START_DATE >= DATEADD('day', -30, CURRENT_DATE())
ORDER BY START_DATE DESC;

-- Recent modifications (last 7 days)
SELECT 
    c.FIRST_NAME || ' ' || c.LAST_NAME as CUSTOMER_NAME,
    c.LAST_MODIFIED_BY,
    c.LAST_MODIFIED_AT,
    DATEDIFF('hour', c.LAST_MODIFIED_AT, CURRENT_TIMESTAMP()) as HOURS_AGO
FROM CUSTOMERS c
WHERE c.LAST_MODIFIED_AT >= DATEADD('day', -7, CURRENT_TIMESTAMP())
ORDER BY c.LAST_MODIFIED_AT DESC;

-- ============================================
-- 10. CLEANUP/RESET (Use with caution!)
-- ============================================

-- Uncomment these only if you want to reset data

-- Reset to original sample data
-- TRUNCATE TABLE CUSTOMERS;
-- TRUNCATE TABLE CUSTOMER_AUDIT_LOG;
-- -- Re-run the INSERT statements from setup_database.sql

-- Delete all audit logs older than 90 days
-- DELETE FROM CUSTOMER_AUDIT_LOG 
-- WHERE MODIFIED_AT < DATEADD('day', -90, CURRENT_TIMESTAMP());

-- ============================================
-- 11. PERFORMANCE CHECKS
-- ============================================

-- Check table size
SELECT 
    'CUSTOMERS' as TABLE_NAME,
    COUNT(*) as ROW_COUNT
FROM CUSTOMERS
UNION ALL
SELECT 
    'CUSTOMER_AUDIT_LOG' as TABLE_NAME,
    COUNT(*) as ROW_COUNT
FROM CUSTOMER_AUDIT_LOG;

-- Most frequently modified customers
SELECT 
    c.CUSTOMER_ID,
    c.FIRST_NAME || ' ' || c.LAST_NAME as CUSTOMER_NAME,
    COUNT(a.AUDIT_ID) as MODIFICATION_COUNT
FROM CUSTOMERS c
LEFT JOIN CUSTOMER_AUDIT_LOG a ON c.CUSTOMER_ID = a.CUSTOMER_ID
GROUP BY c.CUSTOMER_ID, c.FIRST_NAME, c.LAST_NAME
ORDER BY MODIFICATION_COUNT DESC;

-- User activity summary
SELECT 
    MODIFIED_BY,
    COUNT(*) as CHANGES_MADE,
    MIN(MODIFIED_AT) as FIRST_CHANGE,
    MAX(MODIFIED_AT) as LAST_CHANGE
FROM CUSTOMER_AUDIT_LOG
GROUP BY MODIFIED_BY
ORDER BY CHANGES_MADE DESC;

-- ============================================
-- 12. EXPECTED RESULTS SUMMARY
-- ============================================

/*
After running setup_database.sql, you should see:

1. TOTAL_CUSTOMERS: 8
2. ACTIVE_CUSTOMERS: 6
3. Policy Type Distribution:
   - Auto: 2
   - Home: 2
   - Life: 2
   - Health: 2
4. Status Distribution:
   - Active: 6
   - Pending: 1
   - Suspended: 1
5. Premium Range: €850 - €3,200
6. TOTAL_AUDIT_RECORDS: 0 (until first edit)
7. Stream records: 0 (until first edit)

All queries should run without errors if setup is correct.
*/

-- ============================================
-- END OF TEST QUERIES
-- ============================================

