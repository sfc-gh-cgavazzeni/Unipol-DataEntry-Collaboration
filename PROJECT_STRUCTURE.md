# 📁 Project Structure

```
unipolstreamlit/
│
├── streamlit_app.py           # Main Streamlit application
│   ├── Customer viewing & filtering
│   ├── Inline editing interface
│   ├── Audit trail tracking
│   └── Snowflake Streams integration
│
├── setup_database.sql         # Database initialization script
│   ├── CUSTOMERS table creation
│   ├── CUSTOMER_AUDIT_LOG table creation
│   ├── CUSTOMERS_STREAM creation
│   └── Sample data insertion (8 customers)
│
├── requirements.txt           # Python dependencies
│   ├── streamlit>=1.28.0
│   ├── pandas>=1.5.0
│   └── snowflake-snowpark-python>=1.9.0
│
├── environment.yml            # Conda environment (for Snowflake)
│
├── README.md                  # Complete documentation
│   ├── Feature overview
│   ├── Database schema
│   ├── Installation guide
│   ├── Usage instructions
│   └── Troubleshooting
│
├── QUICKSTART.md             # 10-minute setup guide
│   ├── Quick 3-step setup
│   ├── Sample data overview
│   ├── Common tasks
│   └── Quick troubleshooting
│
├── DEPLOYMENT_GUIDE.md       # Detailed deployment instructions
│   ├── Step-by-step deployment
│   ├── Permission configuration
│   ├── Advanced troubleshooting
│   ├── Monitoring & maintenance
│   └── Security best practices
│
├── .gitignore                # Git ignore rules
│
└── PROJECT_STRUCTURE.md      # This file
```

## File Descriptions

### Core Application Files

#### `streamlit_app.py` (Main Application - 500+ lines)
The heart of the application. Contains:

**Functions:**
- `get_current_user()` - Retrieves Snowflake username
- `load_customers(filters)` - Fetches customer data with filtering
- `get_customer_by_id(customer_id)` - Retrieves single customer
- `update_customer(customer_id, updates, comment, user)` - Updates customer and logs change
- `load_recent_changes(limit)` - Fetches audit log entries
- `load_stream_changes()` - Retrieves Snowflake Stream data

**UI Components:**
- Header with title and user info
- Sidebar filters (Status, Policy Type, Search)
- Customer cards with expand/collapse
- Inline edit forms
- Commit/Cancel buttons
- Dual-tab change tracking (Audit Log + Stream Changes)

**State Management:**
- Session state for edit mode tracking
- Refresh trigger for data reloading
- Customer ID tracking for inline editing

#### `setup_database.sql` (Database Setup - ~100 lines)
SQL script that creates entire database structure:

**Tables:**
```sql
CUSTOMERS (
    CUSTOMER_ID NUMBER PRIMARY KEY,
    FIRST_NAME, LAST_NAME, EMAIL, PHONE,
    POLICY_TYPE, POLICY_NUMBER,
    PREMIUM_AMOUNT, STATUS, START_DATE,
    LAST_MODIFIED_BY, LAST_MODIFIED_AT
)

CUSTOMER_AUDIT_LOG (
    AUDIT_ID NUMBER PRIMARY KEY,
    CUSTOMER_ID, MODIFIED_BY, MODIFIED_AT,
    COMMENT, CHANGE_TYPE,
    OLD_VALUES VARIANT, NEW_VALUES VARIANT
)
```

**Streams:**
```sql
CUSTOMERS_STREAM (
    Tracks all DML on CUSTOMERS table
)
```

**Sample Data:**
- 8 Italian insurance customers
- Mix of Auto, Home, Life, Health policies
- Various statuses (Active, Pending, Suspended)
- Premiums from €850 to €3,200

### Documentation Files

#### `README.md` (Complete Documentation)
Comprehensive guide covering:
- All features in detail
- Database schema with field descriptions
- Full installation and deployment process
- Complete usage guide with examples
- Architecture diagram
- Customization instructions
- Detailed troubleshooting

**Target Audience:** Developers and administrators

#### `QUICKSTART.md` (Fast Setup Guide)
Condensed 10-minute setup guide:
- 3-step deployment process
- Quick command reference
- Sample data table
- Common tasks walkthrough
- Quick troubleshooting

**Target Audience:** Users who want to get started immediately

#### `DEPLOYMENT_GUIDE.md` (Advanced Deployment)
In-depth deployment documentation:
- Prerequisites checklist
- Step-by-step deployment (both UI and SQL methods)
- Permission configuration examples
- Performance tuning recommendations
- Security best practices
- Monitoring and maintenance queries
- Cost management tips
- Update procedures

**Target Audience:** DevOps, DBAs, production deployments

### Configuration Files

#### `requirements.txt`
Python package dependencies for Streamlit on Snowflake:
```
streamlit>=1.28.0
pandas>=1.5.0
snowflake-snowpark-python>=1.9.0
```

#### `environment.yml`
Conda environment specification for Snowflake Streamlit:
```yaml
name: streamlit
channels: [snowflake]
dependencies:
  - streamlit>=1.28.0
  - pandas>=1.5.0
  - snowflake-snowpark-python>=1.9.0
```

#### `.gitignore`
Prevents committing:
- Python cache files
- Virtual environments
- IDE configuration
- Snowflake secrets
- Log files

## Data Flow

```
1. USER ACTION (Streamlit UI)
   ↓
2. STREAMLIT APP (streamlit_app.py)
   ↓
3. SNOWPARK SESSION (get_active_session)
   ↓
4. SQL EXECUTION (session.sql)
   ↓
5. SNOWFLAKE TABLES
   ├── CUSTOMERS (main data)
   ├── CUSTOMER_AUDIT_LOG (change history)
   └── CUSTOMERS_STREAM (CDC tracking)
   ↓
6. RESULTS RETURNED TO UI
   ↓
7. DISPLAY TO USER
```

## Key Features by File

### Customer Management (`streamlit_app.py`)
- **Lines 1-50:** Imports and session setup
- **Lines 51-100:** Utility functions
- **Lines 101-200:** Data loading functions
- **Lines 201-300:** Update and audit functions
- **Lines 301-400:** Filter interface
- **Lines 401-550:** Customer display and edit UI
- **Lines 551-600:** Change tracking display

### Database Structure (`setup_database.sql`)
- **Lines 1-20:** Schema creation
- **Lines 21-40:** CUSTOMERS table
- **Lines 41-60:** CUSTOMER_AUDIT_LOG table
- **Lines 61-70:** CUSTOMERS_STREAM
- **Lines 71-110:** Sample data inserts

## Customization Points

### Add New Customer Fields
1. **Update SQL:** `setup_database.sql` - Add column to CUSTOMERS table
2. **Update App:** `streamlit_app.py` - Add field to display/edit forms
3. **Update Docs:** Reflect changes in README.md

### Change Sample Data
1. **Edit:** `setup_database.sql` INSERT statements
2. **Re-run:** Drop and recreate tables or TRUNCATE + INSERT

### Modify UI Layout
1. **Edit:** `streamlit_app.py` Streamlit components
2. **Customize:** Colors, layout, column widths, expander behavior

### Add New Filters
1. **Edit:** `streamlit_app.py` sidebar section
2. **Update:** `load_customers()` function to handle new filter
3. **Test:** Verify filtering logic

## Dependencies

### Python Packages
- **streamlit:** Web app framework
- **pandas:** Data manipulation
- **snowflake-snowpark-python:** Snowflake Python API

### Snowflake Objects
- **Database:** INSURANCE_DB
- **Schema:** CUSTOMER_MGMT
- **Tables:** CUSTOMERS, CUSTOMER_AUDIT_LOG
- **Stream:** CUSTOMERS_STREAM
- **Warehouse:** Any (X-Small recommended for testing)

### Permissions Required
- **Tables:** SELECT, INSERT, UPDATE on CUSTOMERS
- **Audit Log:** SELECT, INSERT on CUSTOMER_AUDIT_LOG
- **Stream:** SELECT on CUSTOMERS_STREAM
- **Warehouse:** USAGE

## Development Workflow

### Initial Setup
1. Read QUICKSTART.md
2. Run setup_database.sql in Snowflake
3. Deploy streamlit_app.py to Snowflake Streamlit
4. Test basic functionality

### Making Changes
1. Edit files locally
2. Test changes (if possible)
3. Update Snowflake Streamlit app
4. Verify in production
5. Update documentation

### Adding Features
1. Plan feature requirements
2. Update database schema if needed (setup_database.sql)
3. Modify application code (streamlit_app.py)
4. Test thoroughly
5. Update all documentation

## Size Statistics

- **Total Files:** 8
- **Code Files:** 2 (streamlit_app.py, setup_database.sql)
- **Documentation:** 4 (README, QUICKSTART, DEPLOYMENT_GUIDE, this file)
- **Configuration:** 3 (requirements.txt, environment.yml, .gitignore)
- **Total Lines:** ~1,500+ lines

## Deployment Checklist

- [ ] Snowflake account ready
- [ ] Database and schema created
- [ ] setup_database.sql executed successfully
- [ ] Permissions granted to role
- [ ] Warehouse available
- [ ] Streamlit app created in Snowflake
- [ ] streamlit_app.py code uploaded
- [ ] App runs without errors
- [ ] Sample data visible
- [ ] Edit functionality works
- [ ] Audit log recording changes
- [ ] Stream tracking active

---

**Complete, production-ready insurance customer management system!**

