# 🚀 Converting to Snowflake Native Application

## Overview

This guide explains how to convert the current Streamlit in Snowflake (SiS) app into a **Snowflake Native Application** for better isolation and security.

---

## 🎯 Why Convert to Native App?

### Current Limitations (SiS)
- Users see full Snowflake interface (Snowsight)
- Users can navigate to worksheets, dashboards, other databases
- Requires full Snowflake account access
- Not distributable to external parties

### Native App Benefits
- ✅ **Isolated UI** - Users only see your application
- ✅ **Controlled Access** - Define exactly what users can see/do
- ✅ **No Snowsight** - Clean, standalone experience
- ✅ **Distributable** - Share via Snowflake Marketplace
- ✅ **Version Control** - Manage app versions
- ✅ **Provider/Consumer Model** - Share data securely
- ✅ **Professional** - Branded, dedicated interface

---

## 📋 Conversion Steps

### 1. **Create Native App Structure**

```
native_app/
├── manifest.yml           # App metadata and configuration
├── setup_script.sql       # Installation script
├── README.md             # App documentation
└── streamlit/
    └── streamlit_app.py  # Your Streamlit code
```

### 2. **Create manifest.yml**

```yaml
manifest_version: 1

version:
  name: V1_0
  label: "Unipol Customer Management v1.0"
  comment: "Insurance Customer Management System"

artifacts:
  readme: README.md
  setup_script: setup_script.sql
  default_streamlit: streamlit/streamlit_app.py

configuration:
  log_level: INFO
  trace_level: OFF

privileges:
  - SELECT:
      description: "Allows reading customer data"
  - INSERT:
      description: "Allows creating audit logs and notes"
  - UPDATE:
      description: "Allows updating customer information"
```

### 3. **Create setup_script.sql**

```sql
-- Application setup script
CREATE APPLICATION ROLE IF NOT EXISTS app_user;
CREATE APPLICATION ROLE IF NOT EXISTS app_admin;

-- Create schema for application
CREATE SCHEMA IF NOT EXISTS app_schema;

-- Grant privileges
GRANT USAGE ON SCHEMA app_schema TO APPLICATION ROLE app_user;
GRANT SELECT ON ALL TABLES IN SCHEMA app_schema TO APPLICATION ROLE app_user;

-- Create or reference tables
CREATE OR REPLACE VIEW app_schema.customers_view AS
SELECT * FROM CUSTOMERS;

CREATE OR REPLACE VIEW app_schema.audit_log_view AS
SELECT * FROM CUSTOMER_AUDIT_LOG;

-- Grant access to views
GRANT SELECT ON VIEW app_schema.customers_view TO APPLICATION ROLE app_user;
GRANT SELECT, INSERT ON VIEW app_schema.audit_log_view TO APPLICATION ROLE app_user;
```

### 4. **Modify Streamlit Code**

Update `streamlit_app.py` to use Native App session:

```python
# Instead of:
# session = get_active_session()

# Use:
from snowflake.snowpark.context import get_active_session
session = get_active_session()

# Query from app-specific views
query = "SELECT * FROM app_schema.customers_view"
```

---

## 🔧 **Detailed Implementation**

### Step-by-Step Process

#### **Step 1: Create Application Package**

```sql
-- Create application package
CREATE APPLICATION PACKAGE unipol_customer_mgmt_pkg;

-- Use the package
USE APPLICATION PACKAGE unipol_customer_mgmt_pkg;

-- Create schema for versions
CREATE SCHEMA stage_content;
```

#### **Step 2: Upload Files to Stage**

```sql
-- Create stage for app files
CREATE OR REPLACE STAGE unipol_customer_mgmt_pkg.stage_content.app_stage;

-- Upload files (via SnowSQL or UI)
PUT file:///path/to/manifest.yml @app_stage AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/setup_script.sql @app_stage AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
PUT file:///path/to/streamlit_app.py @app_stage/streamlit/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
```

#### **Step 3: Create Version**

```sql
-- Create version from staged files
ALTER APPLICATION PACKAGE unipol_customer_mgmt_pkg
  ADD VERSION V1_0 USING '@app_stage';
```

#### **Step 4: Create Application Instance**

```sql
-- Install the application
CREATE APPLICATION unipol_customer_mgmt
  FROM APPLICATION PACKAGE unipol_customer_mgmt_pkg
  USING VERSION V1_0;
```

#### **Step 5: Grant Permissions**

```sql
-- Grant access to the application
GRANT USAGE ON APPLICATION unipol_customer_mgmt TO ROLE user_role;

-- Grant application access to data
GRANT REFERENCE_USAGE ON DATABASE insurance_db 
  TO SHARE IN APPLICATION PACKAGE unipol_customer_mgmt_pkg;
```

---

## 🎨 **User Experience Comparison**

### Before (SiS)
```
┌─────────────────────────────────────────┐
│ ☰ Snowflake Menu                        │
│ ├─ Worksheets                           │
│ ├─ Dashboards                           │
│ ├─ Data                                 │
│ ├─ Streamlit (Your App Here)           │
│ └─ Admin                                │
│                                         │
│ [Your Streamlit App with Snowsight UI] │
└─────────────────────────────────────────┘
```

### After (Native App)
```
┌─────────────────────────────────────────┐
│                                         │
│     Unipol Customer Management          │
│     [Your App - Full Screen]            │
│     [No Snowflake Interface Visible]    │
│                                         │
│     Clean, Isolated Experience          │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🔒 **Security & Access Control**

### Application Roles

Define what users can do:

```sql
-- Viewer role - read only
CREATE APPLICATION ROLE viewer_role;
GRANT SELECT ON app_schema.customers_view TO APPLICATION ROLE viewer_role;

-- Editor role - can edit
CREATE APPLICATION ROLE editor_role;
GRANT SELECT, INSERT, UPDATE ON app_schema.customers_view TO APPLICATION ROLE editor_role;
GRANT INSERT ON app_schema.audit_log TO APPLICATION ROLE editor_role;

-- Admin role - full control
CREATE APPLICATION ROLE admin_role;
GRANT ALL ON SCHEMA app_schema TO APPLICATION ROLE admin_role;
```

### Data Isolation

```sql
-- Users can only access data through your app
-- They cannot:
-- - Query tables directly
-- - See other databases
-- - Access Snowsight interface
-- - Run arbitrary SQL
```

---

## 📦 **Distribution Options**

### Internal Distribution
Share within your organization:
```sql
-- Share with specific accounts
GRANT INSTALL ON APPLICATION PACKAGE unipol_customer_mgmt_pkg 
  TO SHARE consumer_share;
```

### Marketplace Distribution
List on Snowflake Marketplace:
- Make app available to all Snowflake customers
- Can be free or paid
- Automatic updates
- Usage tracking

---

## 🔄 **Update Process**

### Version Management

```sql
-- Create new version
ALTER APPLICATION PACKAGE unipol_customer_mgmt_pkg
  ADD VERSION V1_1 USING '@app_stage_v1_1';

-- Upgrade application
ALTER APPLICATION unipol_customer_mgmt
  UPGRADE USING VERSION V1_1;
```

---

## 💰 **Comparison: SiS vs Native App**

| Feature | Streamlit in Snowflake | Native App |
|---------|----------------------|------------|
| **Development** | ⭐⭐⭐ Easy | ⭐⭐ Moderate |
| **Isolation** | ❌ None | ✅ Complete |
| **UI Clean** | ❌ Snowsight visible | ✅ Standalone |
| **Distribution** | ❌ Limited | ✅ Full |
| **Access Control** | ⭐ Basic | ⭐⭐⭐ Advanced |
| **Versioning** | ❌ Manual | ✅ Built-in |
| **Marketplace** | ❌ No | ✅ Yes |
| **Cost** | Same compute | Same compute |

---

## 🚀 **Quick Start: Convert Current App**

### Minimal Conversion

1. **Create package structure:**
```bash
mkdir -p native_app/streamlit
cp streamlit_app.py native_app/streamlit/
```

2. **Create manifest.yml** (see above)

3. **Create setup_script.sql** (see above)

4. **Package and deploy:**
```sql
-- Via SnowCLI
snow app create --package unipol_customer_mgmt_pkg

-- Via SQL (see detailed steps above)
```

---

## 📊 **Architecture: Native App**

```
┌─────────────────────────────────────────┐
│         Native Application              │
│  ┌───────────────────────────────┐     │
│  │   Streamlit UI (Isolated)     │     │
│  └───────────────────────────────┘     │
│                ↓                        │
│  ┌───────────────────────────────┐     │
│  │   Application Logic           │     │
│  │   - Your Python code          │     │
│  │   - Business rules            │     │
│  └───────────────────────────────┘     │
│                ↓                        │
│  ┌───────────────────────────────┐     │
│  │   App-Specific Views          │     │
│  │   - customers_view            │     │
│  │   - audit_log_view            │     │
│  └───────────────────────────────┘     │
│                ↓                        │
│  ┌───────────────────────────────┐     │
│  │   Shared Data (Provider)      │     │
│  │   - CUSTOMERS table           │     │
│  │   - CUSTOMER_AUDIT_LOG        │     │
│  └───────────────────────────────┘     │
└─────────────────────────────────────────┘
```

---

## ✅ **Recommendation**

### For Your Use Case:

**If internal use only:**
- Current SiS is fine for development
- Consider Native App for production

**If distributing to others:**
- **Definitely use Native App**
- Provides professional, isolated experience
- Better security and control

**If selling/marketplace:**
- **Must use Native App**
- Required for Snowflake Marketplace listing

---

## 🎯 **Next Steps**

### To Convert:

1. **Decide on distribution model**
   - Internal only?
   - External customers?
   - Marketplace?

2. **Create Native App structure**
   - Use templates above
   - Test with pilot users

3. **Package and deploy**
   - Follow detailed steps
   - Version control

4. **Train users**
   - Different access pattern
   - No Snowsight interface

---

## 📚 **Resources**

- [Snowflake Native Apps Documentation](https://docs.snowflake.com/en/developer-guide/native-apps/native-apps-about)
- [Streamlit in Native Apps](https://docs.snowflake.com/en/developer-guide/streamlit/native-apps)
- [Native App Security](https://docs.snowflake.com/en/developer-guide/native-apps/security)

---

## 🎉 **Summary**

**YES**, you can convert to a Native App for:
- ✅ Isolated, standalone experience
- ✅ No Snowsight interface visible
- ✅ Better security and control
- ✅ Professional appearance
- ✅ Distribution capabilities

**The current app can be converted** with moderate effort, and the result is a much more professional, isolated application!


