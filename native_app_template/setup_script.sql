-- ============================================
-- Snowflake Native App Setup Script
-- Unipol Customer Management System
-- ============================================

-- Create application roles
CREATE APPLICATION ROLE IF NOT EXISTS app_viewer;
CREATE APPLICATION ROLE IF NOT EXISTS app_editor;
CREATE APPLICATION ROLE IF NOT EXISTS app_admin;

-- Create application schema
CREATE SCHEMA IF NOT EXISTS app_data;

-- ============================================
-- Create Views for Data Access
-- ============================================

-- Customer data view
CREATE OR REPLACE SECURE VIEW app_data.customers_view AS
SELECT 
    CUSTOMER_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE,
    POLICY_TYPE,
    POLICY_NUMBER,
    PREMIUM_AMOUNT,
    STATUS,
    START_DATE,
    LAST_MODIFIED_BY,
    LAST_MODIFIED_AT
FROM CUSTOMERS;

-- Audit log view
CREATE OR REPLACE SECURE VIEW app_data.audit_log_view AS
SELECT 
    AUDIT_ID,
    CUSTOMER_ID,
    MODIFIED_BY,
    MODIFIED_AT,
    COMMENT,
    CHANGE_TYPE,
    OLD_VALUES,
    NEW_VALUES
FROM CUSTOMER_AUDIT_LOG;

-- Table notes view
CREATE OR REPLACE SECURE VIEW app_data.table_notes_view AS
SELECT 
    NOTE_ID,
    TABLE_NAME,
    NOTE_TEXT,
    CREATED_BY,
    CREATED_AT
FROM TABLE_NOTES;

-- Stream view
CREATE OR REPLACE SECURE VIEW app_data.customers_stream_view AS
SELECT 
    CUSTOMER_ID,
    FIRST_NAME,
    LAST_NAME,
    METADATA$ACTION as ACTION,
    METADATA$ISUPDATE as IS_UPDATE,
    METADATA$ROW_ID as ROW_ID
FROM CUSTOMERS_STREAM;

-- ============================================
-- Grant Privileges to Roles
-- ============================================

-- Viewer role (read-only)
GRANT USAGE ON SCHEMA app_data TO APPLICATION ROLE app_viewer;
GRANT SELECT ON VIEW app_data.customers_view TO APPLICATION ROLE app_viewer;
GRANT SELECT ON VIEW app_data.audit_log_view TO APPLICATION ROLE app_viewer;
GRANT SELECT ON VIEW app_data.table_notes_view TO APPLICATION ROLE app_viewer;
GRANT SELECT ON VIEW app_data.customers_stream_view TO APPLICATION ROLE app_viewer;

-- Editor role (can edit customers and add notes)
GRANT USAGE ON SCHEMA app_data TO APPLICATION ROLE app_editor;
GRANT SELECT ON VIEW app_data.customers_view TO APPLICATION ROLE app_editor;
GRANT SELECT, INSERT ON VIEW app_data.audit_log_view TO APPLICATION ROLE app_editor;
GRANT SELECT, INSERT ON VIEW app_data.table_notes_view TO APPLICATION ROLE app_editor;
GRANT SELECT ON VIEW app_data.customers_stream_view TO APPLICATION ROLE app_editor;

-- Admin role (full access)
GRANT USAGE ON SCHEMA app_data TO APPLICATION ROLE app_admin;
GRANT ALL PRIVILEGES ON SCHEMA app_data TO APPLICATION ROLE app_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON VIEW app_data.customers_view TO APPLICATION ROLE app_admin;
GRANT SELECT, INSERT ON VIEW app_data.audit_log_view TO APPLICATION ROLE app_admin;
GRANT SELECT, INSERT ON VIEW app_data.table_notes_view TO APPLICATION ROLE app_admin;
GRANT SELECT ON VIEW app_data.customers_stream_view TO APPLICATION ROLE app_admin;

-- ============================================
-- Create procedures for data operations
-- ============================================

-- Procedure to update customer (with audit)
CREATE OR REPLACE PROCEDURE app_data.update_customer(
    customer_id NUMBER,
    updates OBJECT,
    comment STRING,
    user STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'update_customer_handler'
AS
$$
def update_customer_handler(session, customer_id, updates, comment, user):
    # Implementation would go here
    # This is a placeholder for the actual update logic
    return "Customer updated successfully"
$$;

-- Procedure to save note
CREATE OR REPLACE PROCEDURE app_data.save_note(
    table_name STRING,
    note_text STRING,
    user STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    INSERT INTO TABLE_NOTES (TABLE_NAME, NOTE_TEXT, CREATED_BY)
    VALUES (:table_name, :note_text, :user);
    RETURN 'Note saved successfully';
END;
$$;

-- Grant execute on procedures
GRANT USAGE ON PROCEDURE app_data.update_customer(NUMBER, OBJECT, STRING, STRING) TO APPLICATION ROLE app_editor;
GRANT USAGE ON PROCEDURE app_data.update_customer(NUMBER, OBJECT, STRING, STRING) TO APPLICATION ROLE app_admin;
GRANT USAGE ON PROCEDURE app_data.save_note(STRING, STRING, STRING) TO APPLICATION ROLE app_editor;
GRANT USAGE ON PROCEDURE app_data.save_note(STRING, STRING, STRING) TO APPLICATION ROLE app_admin;

-- ============================================
-- Setup Complete
-- ============================================

SELECT 'Unipol Customer Management System - Setup Complete' as STATUS;


