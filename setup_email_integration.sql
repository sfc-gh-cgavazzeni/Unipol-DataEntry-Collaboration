-- ============================================
-- Setup Snowflake Email Integration
-- ============================================
-- This script must be run as ACCOUNTADMIN

-- Switch to ACCOUNTADMIN role
USE ROLE ACCOUNTADMIN;

-- Create Email Integration
CREATE OR REPLACE NOTIFICATION INTEGRATION email_int
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('cristian.gavazzeni@snowflake.com');

-- Verify integration created
DESC INTEGRATION email_int;

-- Grant usage to roles that need it
GRANT USAGE ON INTEGRATION email_int TO ROLE SYSADMIN;
GRANT USAGE ON INTEGRATION email_int TO ROLE PUBLIC;

-- Optional: Grant to specific role if needed
-- GRANT USAGE ON INTEGRATION email_int TO ROLE <your_custom_role>;

-- Verification
SELECT 'Email Integration created successfully!' AS STATUS;

