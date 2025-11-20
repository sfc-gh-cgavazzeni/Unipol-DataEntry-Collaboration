# 🚀 Deployment Guide - Insurance Customer Management System

This guide will walk you through deploying the Insurance Customer Management application to Snowflake.

## Prerequisites

- Active Snowflake account
- Appropriate role with permissions to:
  - Create databases, schemas, tables, and streams
  - Create Streamlit apps
  - Execute SQL queries
- Access to Snowflake UI

## Step-by-Step Deployment

### Step 1: Prepare Your Snowflake Environment

1. **Log in to Snowflake**
   - Navigate to your Snowflake account URL
   - Sign in with your credentials

2. **Choose or Create a Database and Schema**
   ```sql
   -- Option 1: Create new database and schema
   CREATE DATABASE IF NOT EXISTS INSURANCE_DB;
   USE DATABASE INSURANCE_DB;
   CREATE SCHEMA IF NOT EXISTS CUSTOMER_MGMT;
   USE SCHEMA CUSTOMER_MGMT;
   
   -- Option 2: Use existing database/schema
   USE DATABASE YOUR_DATABASE;
   USE SCHEMA YOUR_SCHEMA;
   ```

### Step 2: Create Database Objects

1. **Open a new SQL Worksheet** in Snowflake

2. **Copy and execute the setup script**:
   - Open `setup_database.sql`
   - Copy the entire contents
   - Paste into Snowflake SQL Worksheet
   - Execute the script (this will create tables, streams, and insert sample data)

3. **Verify the setup**:
   ```sql
   -- Check that tables were created
   SHOW TABLES;
   
   -- Verify sample data
   SELECT COUNT(*) FROM CUSTOMERS;  -- Should return 8
   
   -- Check stream
   SHOW STREAMS;
   
   -- Verify audit log table
   SELECT * FROM CUSTOMER_AUDIT_LOG;  -- Should be empty initially
   ```

### Step 3: Configure Permissions

Grant necessary permissions to the role that will run the Streamlit app:

```sql
-- Replace YOUR_ROLE with your actual role name
GRANT USAGE ON DATABASE INSURANCE_DB TO ROLE YOUR_ROLE;
GRANT USAGE ON SCHEMA INSURANCE_DB.CUSTOMER_MGMT TO ROLE YOUR_ROLE;
GRANT SELECT, INSERT, UPDATE ON TABLE INSURANCE_DB.CUSTOMER_MGMT.CUSTOMERS TO ROLE YOUR_ROLE;
GRANT SELECT, INSERT ON TABLE INSURANCE_DB.CUSTOMER_MGMT.CUSTOMER_AUDIT_LOG TO ROLE YOUR_ROLE;
GRANT SELECT ON STREAM INSURANCE_DB.CUSTOMER_MGMT.CUSTOMERS_STREAM TO ROLE YOUR_ROLE;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE YOUR_WAREHOUSE TO ROLE YOUR_ROLE;
```

### Step 4: Deploy Streamlit App

#### Method 1: Using Snowflake UI (Recommended)

1. **Navigate to Streamlit**:
   - In Snowflake UI, click on "Streamlit" in the left sidebar
   - Click "+ Streamlit App" button

2. **Configure the App**:
   - **App name**: `Insurance_Customer_Management`
   - **Location**: 
     - Database: `INSURANCE_DB` (or your database)
     - Schema: `CUSTOMER_MGMT` (or your schema)
   - **App warehouse**: Select an appropriate warehouse
   
3. **Upload the Code**:
   - In the Streamlit editor that opens:
   - Delete any default code
   - Open `streamlit_app.py` from this project
   - Copy the entire contents
   - Paste into the Streamlit editor

4. **Run the App**:
   - Click "Run" button in the top right
   - The app should start and connect automatically to Snowflake
   - You should see the customer management interface

#### Method 2: Using SnowSQL (Advanced)

```sql
-- Create Streamlit app using SQL
CREATE STREAMLIT INSURANCE_DB.CUSTOMER_MGMT.INSURANCE_CUSTOMER_MGMT
    ROOT_LOCATION = '@INSURANCE_DB.CUSTOMER_MGMT.STREAMLIT_STAGE'
    MAIN_FILE = 'streamlit_app.py'
    QUERY_WAREHOUSE = 'YOUR_WAREHOUSE';

-- Upload file to stage (use SnowSQL or PUT command)
PUT file:///path/to/streamlit_app.py @INSURANCE_DB.CUSTOMER_MGMT.STREAMLIT_STAGE;
```

### Step 5: Test the Application

1. **Verify Connection**:
   - Check that the app shows customer data
   - Verify that filters work in the sidebar
   - Confirm user name appears in sidebar

2. **Test Edit Functionality**:
   - Click "Edit Record" on any customer
   - Modify some fields
   - Add a comment
   - Click "Commit"
   - Verify the changes are saved

3. **Check Audit Trail**:
   - Scroll to "Recent Changes & Activity Log" section
   - Verify your edit appears in the Audit Log tab
   - Check the Stream Changes tab

4. **Verify Database Updates**:
   ```sql
   -- Check updated customer
   SELECT * FROM CUSTOMERS WHERE CUSTOMER_ID = 1;
   
   -- Check audit log
   SELECT * FROM CUSTOMER_AUDIT_LOG ORDER BY MODIFIED_AT DESC LIMIT 5;
   
   -- Check stream (shows changes since last query)
   SELECT * FROM CUSTOMERS_STREAM;
   ```

## Configuration Options

### Customizing the Application

1. **Change Database/Schema References**:
   - Update `setup_database.sql` with your database names
   - Modify table references in `streamlit_app.py` if needed

2. **Adjust Sample Data**:
   - Edit the INSERT statements in `setup_database.sql`
   - Add more customers or change existing ones

3. **Modify Styling**:
   - Edit `streamlit_app.py` to change UI elements
   - Update page configuration, colors, or layout

### Performance Tuning

1. **Choose Appropriate Warehouse**:
   - For testing: X-Small warehouse
   - For production: Small or Medium warehouse
   - Enable auto-suspend to save costs

2. **Limit Data Display**:
   - Adjust the `LIMIT` in query functions
   - Use pagination for large datasets

## Troubleshooting

### Issue: "Cannot get active session"

**Solution**:
- Ensure you're running the app within Snowflake Streamlit
- The app won't work locally without additional configuration
- Use Snowflake's hosted Streamlit environment

### Issue: Permission Denied

**Solution**:
```sql
-- Check current role
SELECT CURRENT_ROLE();

-- Grant missing permissions
GRANT SELECT, UPDATE ON TABLE CUSTOMERS TO ROLE YOUR_ROLE;
GRANT INSERT ON TABLE CUSTOMER_AUDIT_LOG TO ROLE YOUR_ROLE;
```

### Issue: Stream Shows No Data

**Solution**:
- Streams only capture changes after creation
- Make an edit to see stream data
- Query the stream to consume changes:
  ```sql
  SELECT * FROM CUSTOMERS_STREAM;
  ```

### Issue: App Runs Slowly

**Solution**:
- Use a larger warehouse
- Add filters to reduce data volume
- Optimize queries in the application
- Cache frequently accessed data

### Issue: Changes Not Appearing in Audit Log

**Solution**:
- Check that INSERT permissions exist for CUSTOMER_AUDIT_LOG
- Verify the update_customer function is being called
- Check for SQL errors in Streamlit logs

## Monitoring & Maintenance

### Monitor App Usage

```sql
-- Check Streamlit query history
SELECT 
    query_text,
    user_name,
    execution_time,
    warehouse_name
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_text LIKE '%CUSTOMERS%'
ORDER BY start_time DESC
LIMIT 20;
```

### Clean Up Old Audit Records

```sql
-- Archive old audit logs (older than 1 year)
CREATE TABLE CUSTOMER_AUDIT_LOG_ARCHIVE AS
SELECT * FROM CUSTOMER_AUDIT_LOG
WHERE MODIFIED_AT < DATEADD(year, -1, CURRENT_TIMESTAMP());

-- Delete archived records
DELETE FROM CUSTOMER_AUDIT_LOG
WHERE MODIFIED_AT < DATEADD(year, -1, CURRENT_TIMESTAMP());
```

### Backup Data

```sql
-- Create backup of customers table
CREATE TABLE CUSTOMERS_BACKUP AS SELECT * FROM CUSTOMERS;

-- Create backup of audit log
CREATE TABLE CUSTOMER_AUDIT_LOG_BACKUP AS SELECT * FROM CUSTOMER_AUDIT_LOG;
```

## Security Best Practices

1. **Use Role-Based Access Control**:
   - Create specific roles for different user types
   - Grant minimum necessary privileges

2. **Enable MFA**:
   - Require multi-factor authentication for users

3. **Audit Access**:
   - Regularly review audit logs
   - Monitor for unusual activity

4. **Encrypt Sensitive Data**:
   - Use Snowflake's encryption features
   - Consider column-level encryption for PII

## Updating the Application

1. **Make Code Changes**:
   - Edit `streamlit_app.py` locally
   - Test changes if possible

2. **Deploy Updates**:
   - Open your Streamlit app in Snowflake
   - Replace the code in the editor
   - Click "Run" to restart with new code

3. **Database Schema Changes**:
   ```sql
   -- Example: Add new column
   ALTER TABLE CUSTOMERS ADD COLUMN NEW_FIELD VARCHAR(100);
   
   -- Update Streamlit code to display new field
   ```

## Cost Management

1. **Auto-Suspend Warehouse**:
   ```sql
   ALTER WAREHOUSE YOUR_WAREHOUSE SET AUTO_SUSPEND = 60;
   ```

2. **Monitor Credits**:
   ```sql
   SELECT * FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY(
       DATE_RANGE_START => DATEADD('days', -7, CURRENT_DATE()),
       DATE_RANGE_END => CURRENT_DATE()
   ));
   ```

3. **Use Appropriate Warehouse Sizes**:
   - Start small and scale up only if needed
   - X-Small is often sufficient for this app

## Next Steps

- Add more customers to the database
- Customize the UI to match your branding
- Add additional features (bulk updates, exports, etc.)
- Integrate with other Snowflake tables
- Set up scheduled backups

## Support

For Snowflake-specific issues:
- Visit [Snowflake Documentation](https://docs.snowflake.com/)
- Contact Snowflake Support

For application issues:
- Review the README.md
- Check Streamlit logs in Snowflake
- Verify database permissions and connectivity

---

**Happy Deploying! 🚀**

