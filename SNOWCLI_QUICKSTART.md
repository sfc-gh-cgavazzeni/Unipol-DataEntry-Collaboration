# ⚡ SnowCLI Quick Start - 5 Minutes to Deploy

Deploy your Insurance Customer Management app to Snowflake in 5 minutes using SnowCLI.

## Prerequisites (2 minutes)

### 1. Install SnowCLI

```bash
pip install snowflake-cli-labs
```

### 2. Configure Connection

```bash
# Interactive setup
snow connection add

# Follow prompts to enter:
# - Connection name: default
# - Account: your-account.snowflakecomputing.com
# - Username: your-username
# - Password: your-password (or use authenticator = externalbrowser)
# - Warehouse: COMPUTE_WH (or your warehouse name)
# - Database: INSURANCE_DB
# - Schema: CUSTOMER_MGMT
# - Role: your-role
```

### 3. Test Connection

```bash
snow connection test
```

## Deploy in 3 Steps (3 minutes)

### Option A: Automated Deployment (Easiest)

```bash
cd /Users/cgavazenni/unipolstreamlit

# Run the deployment script
./deploy.sh
```

That's it! The script will:
- ✅ Test your connection
- ✅ Create database and schema
- ✅ Create tables and load sample data
- ✅ Deploy the Streamlit app
- ✅ Provide you with the app URL

### Option B: Manual Steps

If you prefer manual control:

#### Step 1: Setup Database
```bash
cd /Users/cgavazenni/unipolstreamlit

# Create database structure
snow sql -q "CREATE DATABASE IF NOT EXISTS INSURANCE_DB;"
snow sql -q "USE DATABASE INSURANCE_DB;"
snow sql -q "CREATE SCHEMA IF NOT EXISTS CUSTOMER_MGMT;"
snow sql -q "USE SCHEMA CUSTOMER_MGMT;"

# Create tables and load data
snow sql -f setup_database.sql
```

#### Step 2: Update Configuration
Edit `snowflake.yml` and change `query_warehouse` to your warehouse name:
```yaml
query_warehouse: YOUR_WAREHOUSE_NAME  # Change this
```

#### Step 3: Deploy App
```bash
snow streamlit deploy --replace
```

#### Step 4: Open App
```bash
# Get the URL
snow streamlit get-url insurance_customer_management

# Or open directly in browser
snow streamlit open insurance_customer_management
```

## Verify Deployment

```bash
# Check customers were loaded
snow sql -q "SELECT COUNT(*) FROM INSURANCE_DB.CUSTOMER_MGMT.CUSTOMERS;"
# Should return: 8

# List your Streamlit apps
snow streamlit list

# Get app details
snow streamlit describe insurance_customer_management
```

## Quick Commands Reference

```bash
# Deploy/Update app
snow streamlit deploy --replace

# Open app in browser
snow streamlit open insurance_customer_management

# View app URL
snow streamlit get-url insurance_customer_management

# List all apps
snow streamlit list

# Run SQL queries
snow sql -q "SELECT * FROM CUSTOMERS LIMIT 5;"

# Interactive SQL
snow sql
```

## Troubleshooting

### Connection Issues
```bash
# Check your config
cat ~/.snowflake/config.toml

# Reconfigure
snow connection add
```

### Warehouse Not Found
```bash
# Update snowflake.yml with your warehouse name
nano snowflake.yml
# Change: query_warehouse: YOUR_WAREHOUSE_NAME
```

### Permission Issues
```bash
# Grant required permissions (run in Snowflake as admin)
snow sql -q "GRANT USAGE ON DATABASE INSURANCE_DB TO ROLE YOUR_ROLE;"
snow sql -q "GRANT CREATE STREAMLIT ON SCHEMA CUSTOMER_MGMT TO ROLE YOUR_ROLE;"
```

## Update the App

After making changes to `streamlit_app.py`:

```bash
# Redeploy
snow streamlit deploy --replace

# Or use the script
./deploy.sh
```

## What's Next?

1. **Open your app** and test the features
2. **Edit a customer** - Click "Edit Record", make changes, add a comment
3. **Check audit trail** - Scroll to bottom to see your changes
4. **Customize** - Edit `streamlit_app.py` to fit your needs

## Need Help?

- **Detailed Guide**: See `SNOWCLI_DEPLOYMENT.md`
- **Full Docs**: See `README.md`
- **SnowCLI Docs**: https://docs.snowflake.com/en/developer-guide/snowflake-cli

---

**Ready? Run: `./deploy.sh` and you're live in minutes!** 🚀

