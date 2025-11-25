-- ============================================
-- Setup Email Notification for Table Notes
-- ============================================

-- This script sets up email notifications to be sent when table notes are saved

-- ============================================
-- Option 1: Using Snowflake Email Integration
-- ============================================

-- Note: This requires ACCOUNTADMIN privileges to set up

-- Step 1: Create Email Integration (run as ACCOUNTADMIN)
-- CREATE NOTIFICATION INTEGRATION email_int
--   TYPE = EMAIL
--   ENABLED = TRUE
--   ALLOWED_RECIPIENTS = ('cristian.gavazzeni@snowflake.com');

-- Step 2: Grant usage on integration
-- GRANT USAGE ON INTEGRATION email_int TO ROLE <your_role>;

-- ============================================
-- Option 2: Create Stored Procedure for Email
-- ============================================

-- Create procedure to send email notification
CREATE OR REPLACE PROCEDURE SEND_NOTE_EMAIL(
    table_name VARCHAR,
    username VARCHAR,
    note_text VARCHAR,
    timestamp VARCHAR
)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'send_email_handler'
AS
$$
def send_email_handler(session, table_name, username, note_text, timestamp):
    """
    Send email notification when a table note is saved
    """
    try:
        # Email details
        recipient = 'cristian.gavazzeni@snowflake.com'
        subject = f'Table Note Added: {table_name}'
        
        # Email body
        body = f"""
        A new note has been added to table: {table_name}
        
        Details:
        - Table: {table_name}
        - User: {username}
        - Timestamp: {timestamp}
        
        Note Content:
        {note_text}
        
        ---
        This is an automated notification from Unipol Customer Management System
        """
        
        # Use Snowflake's SYSTEM$SEND_EMAIL function
        # Note: Requires email integration to be set up
        email_query = f"""
        CALL SYSTEM$SEND_EMAIL(
            'email_int',
            '{recipient}',
            'Table Note: {table_name}',
            '{body.replace("'", "''")}'
        )
        """
        
        result = session.sql(email_query).collect()
        return f"Email sent successfully to {recipient}"
        
    except Exception as e:
        # If email fails, log but don't stop the note from being saved
        return f"Note saved but email failed: {str(e)}"
$$;

-- Grant execute permission
GRANT USAGE ON PROCEDURE SEND_NOTE_EMAIL(VARCHAR, VARCHAR, VARCHAR, VARCHAR) 
  TO ROLE PUBLIC;

-- ============================================
-- Alternative: Using External Email Service
-- ============================================

-- If Snowflake email integration is not available, you can use an external service
-- like SendGrid, AWS SES, or similar via External Function

-- Example with External Function (requires setup):
-- CREATE OR REPLACE EXTERNAL FUNCTION send_email_external(
--     recipient VARCHAR,
--     subject VARCHAR,
--     body VARCHAR
-- )
-- RETURNS VARIANT
-- API_INTEGRATION = <your_api_integration>
-- AS '<your_api_endpoint>';

-- ============================================
-- Test Email Function
-- ============================================

-- Test the email procedure (uncomment to test)
-- CALL SEND_NOTE_EMAIL(
--     'CUSTOMERS',
--     'TEST_USER',
--     'This is a test note',
--     CURRENT_TIMESTAMP()::VARCHAR
-- );

-- ============================================
-- Verification
-- ============================================

SELECT 'Email notification setup complete. Remember to configure email integration!' AS STATUS;

