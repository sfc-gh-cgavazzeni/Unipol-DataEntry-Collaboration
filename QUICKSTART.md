# 🚀 Quick Start Guide

Get your Insurance Customer Management System up and running in 10 minutes!

## Overview

This Streamlit application provides a complete customer management interface for insurance companies with:
- ✅ Customer data viewing and filtering
- ✏️ Inline record editing with audit trail
- 📊 Real-time change tracking using Snowflake Streams
- 💬 Mandatory comments for all changes

## Quick Setup (3 Steps)

### 1️⃣ Setup Database (5 minutes)

```sql
-- In Snowflake SQL Worksheet:

-- A. Create database and schema
CREATE DATABASE INSURANCE_DB;
USE DATABASE INSURANCE_DB;
CREATE SCHEMA CUSTOMER_MGMT;
USE SCHEMA CUSTOMER_MGMT;

-- B. Copy & run the entire setup_database.sql file
-- This creates tables, stream, and loads 8 sample customers

-- C. Verify
SELECT COUNT(*) FROM CUSTOMERS;  -- Should show 8
```

### 2️⃣ Deploy App (3 minutes)

1. In Snowflake UI, go to **Streamlit** (left sidebar)
2. Click **+ Streamlit App**
3. Fill in:
   - Name: `Insurance_Customer_Management`
   - Database: `INSURANCE_DB`
   - Schema: `CUSTOMER_MGMT`
   - Warehouse: Choose any (X-Small is fine)
4. Copy all code from `streamlit_app.py` and paste into editor
5. Click **Run**

### 3️⃣ Start Using (2 minutes)

**View Customers:**
- Browse the 8 pre-loaded sample customers
- Use sidebar filters for Status and Policy Type
- Search by name, email, or policy number

**Edit a Customer:**
1. Click **✏️ Edit Record** next to any customer
2. Modify fields as needed
3. Enter a comment (required!) describing your changes
4. Click **✅ Commit**

**Track Changes:**
- Scroll to bottom of page
- View **Audit Log** tab for all historical changes
- Check **Stream Changes** tab for real-time CDC data

## Sample Data

The app includes 8 Italian insurance customers:

| Name | Policy Type | Premium | Status |
|------|------------|---------|--------|
| Mario Rossi | Auto | €850 | Active |
| Laura Bianchi | Home | €1,200 | Active |
| Giuseppe Verdi | Life | €2,500 | Active |
| Anna Russo | Health | €1,800 | Active |
| Franco Ferrari | Auto | €920 | Pending |
| Giulia Romano | Home | €1,350 | Active |
| Roberto Esposito | Life | €3,200 | Active |
| Chiara Colombo | Health | €1,650 | Suspended |

## Common Tasks

### Filter Active Auto Policies
1. Sidebar → Status: `Active`
2. Sidebar → Policy Type: `Auto`
3. View filtered results

### Update Customer Status
1. Find customer → Click **Edit Record**
2. Change Status dropdown (e.g., Active → Suspended)
3. Comment: "Customer requested policy suspension"
4. Click **Commit**

### View Change History
1. Scroll to "Recent Changes & Activity Log"
2. **Audit Log** tab shows:
   - Who made changes
   - When they occurred
   - Comments provided
   - Which customer was affected

## Architecture at a Glance

```
┌──────────────────────────────────────┐
│     Streamlit UI (Snowflake)        │
│  - Customer table with filters       │
│  - Inline editing interface          │
│  - Change tracking dashboard         │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│         Snowflake Tables             │
│                                      │
│  📋 CUSTOMERS                        │
│     - Main customer data             │
│     - 8 columns, 8 sample rows       │
│                                      │
│  📝 CUSTOMER_AUDIT_LOG               │
│     - Change history                 │
│     - User, timestamp, comments      │
│     - Old/new values as JSON         │
│                                      │
│  🔄 CUSTOMERS_STREAM                 │
│     - Real-time CDC tracking         │
│     - Captures all DML operations    │
└──────────────────────────────────────┘
```

## Troubleshooting

### App won't load?
- Check you're using correct database/schema in Streamlit settings
- Verify warehouse is running
- Refresh the page

### Can't edit records?
- Ensure you have UPDATE permission on CUSTOMERS table
- Check you have INSERT permission on CUSTOMER_AUDIT_LOG table

### Changes not saving?
- Make sure comment field is filled (it's mandatory!)
- Check Snowflake query history for errors

### Stream shows no data?
- Streams only show changes after stream creation
- Make an edit to see data appear
- Previous changes won't be captured

## Next Steps

- 📚 Read [README.md](README.md) for detailed documentation
- 🚀 See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for advanced setup
- ✏️ Customize `streamlit_app.py` for your needs
- 🔧 Modify `setup_database.sql` to add more fields

## Need Help?

1. Check the [README.md](README.md) for detailed feature explanations
2. Review [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) troubleshooting section
3. Consult [Snowflake Documentation](https://docs.snowflake.com/)

---

**You're all set! 🎉**

Now start managing your insurance customers with ease!

