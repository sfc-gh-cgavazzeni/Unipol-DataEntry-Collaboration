# 🏥 Insurance Customer Management System

A comprehensive Streamlit application for managing insurance customer data, hosted on Snowflake with real-time change tracking.

## Features

### 📋 Customer Management
- **View Customer Records**: Display all insurance customers in an expandable card format
- **Advanced Filtering**: Filter customers by status, policy type, or search by name/email/policy number
- **Detailed Information**: View complete customer details including contact info, policy details, and premium amounts

### ✏️ Edit Functionality
- **Inline Editing**: Click "Edit Record" button next to any customer to modify their information
- **Field Validation**: Edit all customer fields with appropriate input controls
- **Mandatory Comments**: Require comments when committing changes for audit trail
- **Commit Changes**: Save updates to the database with user tracking

### 📊 Change Tracking
- **Audit Log**: Complete history of all changes with user, timestamp, and comments
- **Snowflake Streams**: Real-time change detection using Snowflake's CDC capabilities
- **Dual Tracking**: Separate tables for customer data and audit logs

## Database Schema

### CUSTOMERS Table
Stores customer information:
- `CUSTOMER_ID` (Primary Key)
- `FIRST_NAME`, `LAST_NAME`
- `EMAIL`, `PHONE`
- `POLICY_TYPE` (Auto, Home, Life, Health)
- `POLICY_NUMBER`
- `PREMIUM_AMOUNT`
- `STATUS` (Active, Pending, Suspended, Cancelled)
- `START_DATE`
- `LAST_MODIFIED_BY`
- `LAST_MODIFIED_AT`

### CUSTOMER_AUDIT_LOG Table
Tracks all changes:
- `AUDIT_ID` (Primary Key)
- `CUSTOMER_ID` (Foreign Key)
- `MODIFIED_BY` (Snowflake user)
- `MODIFIED_AT` (Timestamp)
- `COMMENT` (User-provided description)
- `CHANGE_TYPE` (UPDATE, INSERT, DELETE)
- `OLD_VALUES` (JSON)
- `NEW_VALUES` (JSON)

### CUSTOMERS_STREAM
Snowflake stream for real-time change detection

## Installation & Deployment

### Step 1: Setup Snowflake Database

1. Connect to your Snowflake account
2. Run the setup script:

```sql
-- Execute setup_database.sql in Snowflake
-- This will create:
-- - CUSTOMERS table with sample data
-- - CUSTOMER_AUDIT_LOG table
-- - CUSTOMERS_STREAM for change tracking
```

### Step 2: Deploy to Snowflake

1. **Navigate to Snowflake Streamlit**:
   - Log in to your Snowflake account
   - Go to `Streamlit` in the left navigation
   - Click `+ Streamlit App`

2. **Create New Streamlit App**:
   - Choose your database and schema
   - Name your app (e.g., "Insurance Customer Management")
   - Select the warehouse

3. **Upload Application Code**:
   - Copy the contents of `streamlit_app.py` into the Streamlit editor
   - The app will automatically use `get_active_session()` to connect to Snowflake

4. **Configure Permissions**:
   ```sql
   -- Grant necessary permissions to your role
   GRANT SELECT, INSERT, UPDATE ON TABLE CUSTOMERS TO ROLE YOUR_ROLE;
   GRANT SELECT, INSERT ON TABLE CUSTOMER_AUDIT_LOG TO ROLE YOUR_ROLE;
   GRANT SELECT ON STREAM CUSTOMERS_STREAM TO ROLE YOUR_ROLE;
   ```

5. **Run the App**:
   - Click "Run" in the Streamlit interface
   - Your app will be available at a Snowflake-hosted URL

## Usage Guide

### Viewing Customers
1. Use the sidebar filters to narrow down customers by:
   - Status (Active, Pending, Suspended, Cancelled)
   - Policy Type (Auto, Home, Life, Health)
   - Search text (matches name, email, or policy number)

### Editing a Customer
1. Find the customer you want to edit
2. Click the "✏️ Edit Record" button
3. Modify any fields in the edit form
4. Enter a mandatory comment describing the changes
5. Click "✅ Commit" to save changes
6. Click "❌ Cancel" to discard changes

### Tracking Changes
1. **Audit Log Tab**: View the complete history of changes including:
   - Who made the change
   - When it was made
   - The comment provided
   - Customer affected
   
2. **Stream Changes Tab**: View real-time changes captured by Snowflake Streams
   - Shows DML operations (INSERT, UPDATE, DELETE)
   - Tracks metadata about changes

## Sample Data

The application comes pre-loaded with 8 sample insurance customers representing:
- Italian names and contact information
- Various policy types (Auto, Home, Life, Health)
- Different statuses (Active, Pending, Suspended)
- Premium amounts ranging from €850 to €3,200

## Architecture

```
┌─────────────────┐
│  Streamlit UI   │
│  (Frontend)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Snowflake     │
│   Session       │
└────────┬────────┘
         │
    ┌────┴────────────────┐
    ▼                     ▼
┌──────────┐      ┌─────────────────┐
│CUSTOMERS │◄─────┤CUSTOMERS_STREAM │
│  Table   │      │   (CDC)         │
└────┬─────┘      └─────────────────┘
     │
     ▼
┌──────────────────┐
│CUSTOMER_AUDIT_LOG│
│     Table        │
└──────────────────┘
```

## Key Technologies

- **Streamlit**: Interactive web application framework
- **Snowflake**: Cloud data warehouse and hosting platform
- **Snowpark**: Python API for Snowflake
- **Snowflake Streams**: Change data capture (CDC)

## Security Features

- **User Tracking**: All changes logged with Snowflake username
- **Audit Trail**: Complete history of modifications
- **Mandatory Comments**: Enforced documentation of changes
- **Change Versioning**: Old and new values stored as JSON

## Customization

### Adding More Fields
Edit both `setup_database.sql` and `streamlit_app.py` to add columns to the CUSTOMERS table.

### Changing Sample Data
Modify the INSERT statements in `setup_database.sql` to add/change sample customers.

### Adjusting Filters
Update the filter section in `streamlit_app.py` to add more filter options.

## Troubleshooting

### App won't connect to Snowflake
- Ensure you're running the app within Snowflake Streamlit (not locally)
- Check that your role has necessary permissions

### Can't see changes in Stream
- Streams only show changes after they're created
- Consume stream data by querying it
- Streams reset after being consumed in a transaction

### Audit log not updating
- Check INSERT permissions on CUSTOMER_AUDIT_LOG table
- Verify the trigger logic in the update_customer function

## License

This is a sample application for demonstration purposes.

## Support

For issues or questions, please contact your Snowflake administrator.

