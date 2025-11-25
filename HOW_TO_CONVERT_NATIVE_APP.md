# 🚀 How to Convert to Native App - Step by Step

## Quick Answer

**YES**, you can convert this to a Snowflake Native Application that provides:
- ✅ **No Snowsight interface** - Users see ONLY your app
- ✅ **Isolated experience** - Clean, standalone application
- ✅ **Controlled access** - You define what users can see/do
- ✅ **Professional** - Looks like a dedicated product

---

## 📋 Conversion Process

### Option 1: Quick Convert (Recommended for Testing)

```bash
# 1. Copy files to native app structure
mkdir -p native_app/streamlit
cp streamlit_app.py native_app/streamlit/
cp native_app_template/* native_app/

# 2. Create package in Snowflake
cd native_app
snow app create --name unipol_customer_mgmt

# 3. Test the app
snow app open unipol_customer_mgmt
```

### Option 2: Manual Convert (Full Control)

#### Step 1: Create Application Package

```sql
-- Run in Snowflake
CREATE APPLICATION PACKAGE unipol_customer_mgmt_pkg;
USE APPLICATION PACKAGE unipol_customer_mgmt_pkg;
CREATE SCHEMA stage_content;
CREATE STAGE stage_content.app_stage;
```

#### Step 2: Upload Files

```bash
# Upload manifest
PUT file:///Users/cgavazenni/unipolstreamlit/native_app_template/manifest.yml 
  @unipol_customer_mgmt_pkg.stage_content.app_stage 
  AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

# Upload setup script
PUT file:///Users/cgavazenni/unipolstreamlit/native_app_template/setup_script.sql 
  @unipol_customer_mgmt_pkg.stage_content.app_stage 
  AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

# Upload README
PUT file:///Users/cgavazenni/unipolstreamlit/native_app_template/README.md 
  @unipol_customer_mgmt_pkg.stage_content.app_stage 
  AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

# Upload Streamlit app
PUT file:///Users/cgavazenni/unipolstreamlit/streamlit_app.py 
  @unipol_customer_mgmt_pkg.stage_content.app_stage/streamlit/ 
  AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
```

#### Step 3: Create Version

```sql
-- Create version from staged files
ALTER APPLICATION PACKAGE unipol_customer_mgmt_pkg
  ADD VERSION V1_0 USING '@stage_content.app_stage';

-- Set default version
ALTER APPLICATION PACKAGE unipol_customer_mgmt_pkg
  SET DEFAULT RELEASE DIRECTIVE VERSION = V1_0 PATCH = 0;
```

#### Step 4: Grant Data Access

```sql
-- Grant package access to your data
GRANT REFERENCE_USAGE ON DATABASE INSURANCE_DB 
  TO SHARE IN APPLICATION PACKAGE unipol_customer_mgmt_pkg;

-- Grant specific table access
GRANT SELECT ON TABLE INSURANCE_DB.CUSTOMER_MGMT.CUSTOMERS 
  TO SHARE IN APPLICATION PACKAGE unipol_customer_mgmt_pkg;

GRANT SELECT, INSERT ON TABLE INSURANCE_DB.CUSTOMER_MGMT.CUSTOMER_AUDIT_LOG 
  TO SHARE IN APPLICATION PACKAGE unipol_customer_mgmt_pkg;

GRANT SELECT, INSERT ON TABLE INSURANCE_DB.CUSTOMER_MGMT.TABLE_NOTES 
  TO SHARE IN APPLICATION PACKAGE unipol_customer_mgmt_pkg;
```

#### Step 5: Install Application

```sql
-- Create application instance
CREATE APPLICATION unipol_customer_mgmt
  FROM APPLICATION PACKAGE unipol_customer_mgmt_pkg
  USING VERSION V1_0;

-- Grant access to users
GRANT USAGE ON APPLICATION unipol_customer_mgmt TO ROLE your_user_role;
```

#### Step 6: Open the App

```sql
-- Get app URL
SELECT SYSTEM$GET_STREAMLIT_APP_URL('unipol_customer_mgmt') AS APP_URL;
```

Or navigate to: **Apps** → **Installed Apps** → **unipol_customer_mgmt**

---

## 🎯 What Users Will See

### Before (Current SiS)
```
┌──────────────────────────────────────────────────┐
│ ☰ Snowflake                                      │
│ ┌──────────┬──────────┬──────────┬────────────┐ │
│ │ Home     │ Data     │Worksheets│ Streamlit  │ │
│ └──────────┴──────────┴──────────┴────────────┘ │
│                                                  │
│ ┌─ Left Sidebar ──────────────────────────────┐ │
│ │ • Databases                                 │ │
│ │ • Worksheets                                │ │
│ │ • Dashboards                                │ │
│ │ • Data                                      │ │
│ └─────────────────────────────────────────────┘ │
│                                                  │
│         [Your App in Center]                     │
│                                                  │
└──────────────────────────────────────────────────┘

❌ Users can navigate away
❌ Users see full Snowflake interface
❌ Users can access other features
```

### After (Native App)
```
┌──────────────────────────────────────────────────┐
│                                                  │
│           Unipol Customer Management             │
│           ══════════════════════════              │
│                                                  │
│     [Your Application - Full Screen]             │
│     [Clean, Professional Interface]              │
│     [No Snowflake Branding/Navigation]           │
│                                                  │
│     Customer Management                          │
│     ├─ View Customers                           │
│     ├─ Edit Records                             │
│     ├─ Audit Logs                               │
│     └─ Notes                                    │
│                                                  │
└──────────────────────────────────────────────────┘

✅ Isolated application
✅ No Snowsight interface
✅ Cannot navigate away
✅ Professional, standalone experience
```

---

## 🔒 Access Control Differences

### Current (SiS)
- Users need Snowflake account
- Users see everything they have access to
- Hard to restrict to just your app

### Native App
- Users only see your application
- You control exactly what they can access
- Roles defined in your app (viewer, editor, admin)
- Cannot access other Snowflake features

---

## 💰 Cost Comparison

| Aspect | Current (SiS) | Native App |
|--------|--------------|------------|
| **Compute** | Same | Same |
| **Storage** | Same | Same |
| **Development** | ✅ Easy | Moderate |
| **Maintenance** | Easy | Easy |
| **Distribution** | Limited | Full |

**Result:** Same cost, better experience!

---

## 🎓 When to Use Each

### Keep Current SiS If:
- ✅ Internal development/testing
- ✅ Users are Snowflake power users
- ✅ Users need access to other Snowflake features
- ✅ Quick prototyping

### Convert to Native App If:
- ✅ **Production deployment**
- ✅ **External users** (customers, partners)
- ✅ **Need isolation** from Snowflake interface
- ✅ **Professional branding** required
- ✅ **Distributing to others**
- ✅ **Marketplace listing**

---

## 📝 What Needs to Change in Your Code

### Minimal Changes Required!

The good news: Your Streamlit code stays mostly the same!

**Only change:** Use app-specific views instead of direct tables

```python
# Before (Current):
query = "SELECT * FROM CUSTOMERS"

# After (Native App):
query = "SELECT * FROM app_data.customers_view"
```

**That's it!** The rest of your code works as-is.

---

## 🚀 Recommended Approach

### Phase 1: Keep Current Setup (Now)
- ✅ Continue development with SiS
- ✅ Faster iteration
- ✅ Easier testing

### Phase 2: Convert to Native App (Production)
- ✅ Create native app package
- ✅ Deploy to production
- ✅ Professional user experience
- ✅ Better security

### Phase 3: Maintain Both (Optional)
- ✅ SiS for development
- ✅ Native App for production
- ✅ Best of both worlds

---

## ✅ Next Steps

### To Convert (When Ready):

1. **Decision Time:**
   - Do you need isolation from Snowsight? → Yes = Convert
   - Distributing to external users? → Yes = Convert
   - Internal testing only? → Maybe wait

2. **If Converting:**
   - Use templates in `native_app_template/`
   - Follow Step-by-Step guide above
   - Test with pilot users

3. **Resources:**
   - `NATIVE_APP_CONVERSION.md` - Detailed guide
   - `native_app_template/` - Ready-to-use templates
   - Snowflake docs - Native Apps guide

---

## 📞 Summary

**Question:** Can we hide Snowsight interface?

**Answer:** ✅ **YES!** Use Snowflake Native App

**Benefits:**
- ✅ Completely isolated experience
- ✅ No Snowsight interface visible
- ✅ Professional, standalone app
- ✅ Better security and control
- ✅ Same compute costs

**Files Ready:**
- ✅ Templates created in `native_app_template/`
- ✅ Conversion guide complete
- ✅ Your code needs minimal changes

**Recommendation:**
- 👍 **Now:** Continue with SiS for development
- 🚀 **Later:** Convert to Native App for production

---

**You have everything you need to convert when ready!** 🎉


