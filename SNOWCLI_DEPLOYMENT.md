# 🚀 SnowCLI Deployment Guide

Complete guide to deploying the Insurance Customer Management System using SnowCLI.

## Prerequisites

### 1. Install SnowCLI

```bash
# Using pip
pip install snowflake-cli-labs

# Or using pipx (recommended)
pipx install snowflake-cli-labs

# Verify installation
snow --version
```

### 2. Configure SnowCLI Connection

Create or update `~/.snowflake/config.toml`:

```toml
[connections.default]
account = "your-account"
user = "your-username"
password = "your-password"  # Or use authenticator
warehouse = "compute_wh"
database = "INSURANCE_DB"
schema = "CUSTOMER_MGMT"
role = "your-role"

# Alternative: Use SSO/External Browser
# authenticator = "externalbrowser"
```

**Or configure interactively:**
```bash
snow connection add
```

**Test connection:**
```bash
snow connection test
```

---

## Step-by-Step Deployment

### Step 1: Setup Database Objects

First, create the database, schema, and tables:

```bash
# Navigate to project directory
cd /Users/cgavazenni/unipolstreamlit

# Execute setup script
snow sql -f setup_database.sql
```

**Or manually in Snowflake:**
```bash
# Connect to Snowflake
snow sql

# Then paste the contents of setup_database.sql
```

**Verify:**
```bash
snow sql -q "SELECT COUNT(*) FROM INSURANCE_DB.CUSTOMER_MGMT.CUSTOMERS;"
# Should return: 8
```

### Step 2: Review Configuration

Check `snowflake.yml` and update if needed:

```bash
# View current configuration
cat snowflake.yml

# Key settings to verify:
# - query_warehouse: Your warehouse name
# - name: App name in Snowflake
# - main_file: streamlit_app.py
```

### Step 3: Deploy Streamlit App

```bash
# Deploy the app
snow streamlit deploy \
  --replace \
  --connection default

# The --replace flag will overwrite if app already exists
```

**Expected output:**
```
Streamlit successfully deployed and available under:
https://your-account.snowflakecomputing.com/...
```

### Step 4: Verify Deployment

```bash
# List deployed Streamlit apps
snow streamlit list

# Get app details
snow streamlit describe insurance_customer_management

# Check app URL
snow streamlit get-url insurance_customer_management
```

### Step 5: Open the App

```bash
# Open app in browser
snow streamlit open insurance_customer_management
```

---

## Alternative Deployment Commands

### Deploy with Custom Connection

```bash
snow streamlit deploy \
  --connection myconnection \
  --replace
```

### Deploy to Specific Database/Schema

```bash
# First, update your connection or use env vars
export SNOWFLAKE_DATABASE=INSURANCE_DB
export SNOWFLAKE_SCHEMA=CUSTOMER_MGMT

snow streamlit deploy --replace
```

### Deploy with Custom Configuration File

```bash
snow streamlit deploy \
  --config snowflake.yml \
  --replace
```

---

## Complete Deployment Script

Save this as `deploy.sh` for easy deployment:

```bash
#!/bin/bash

# deploy.sh - Complete deployment script

set -e  # Exit on error

echo "🚀 Starting deployment..."

# 1. Test connection
echo "📡 Testing Snowflake connection..."
snow connection test

# 2. Setup database (if not exists)
echo "🗄️  Setting up database..."
snow sql -q "CREATE DATABASE IF NOT EXISTS INSURANCE_DB;"
snow sql -q "USE DATABASE INSURANCE_DB;"
snow sql -q "CREATE SCHEMA IF NOT EXISTS CUSTOMER_MGMT;"
snow sql -q "USE SCHEMA CUSTOMER_MGMT;"

# 3. Create tables and load data
echo "📊 Creating tables..."
snow sql -f setup_database.sql

# 4. Verify data
echo "✅ Verifying data..."
CUSTOMER_COUNT=$(snow sql -q "SELECT COUNT(*) FROM CUSTOMERS;" -o plain)
echo "Customer count: $CUSTOMER_COUNT"

# 5. Deploy Streamlit app
echo "🎨 Deploying Streamlit app..."
snow streamlit deploy --replace

# 6. Get app URL
echo "🌐 Getting app URL..."
snow streamlit get-url insurance_customer_management

echo "✨ Deployment complete!"
```

Make it executable:
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## Configuration Options

### snowflake.yml Customization

```yaml
definition_version: 1

streamlit:
  # App name (must be unique in schema)
  name: insurance_customer_management
  
  # Stage for storing app files
  stage: streamlit
  
  # Warehouse for running the app
  query_warehouse: compute_wh
  
  # Main Python file
  main_file: streamlit_app.py
  
  # App title (shown in browser)
  title: "Insurance Customer Management"
  
  # Additional pages (if multi-page app)
  pages_dir: null
  
  # Environment variables file
  env_file: null
  
  # Additional artifacts to upload
  artifacts:
    - streamlit_app.py
    - requirements.txt
    - environment.yml
```

### Advanced Configuration

```yaml
streamlit:
  name: insurance_customer_management
  stage: streamlit
  query_warehouse: compute_wh
  main_file: streamlit_app.py
  title: "Insurance Customer Management"
  
  # Specify database and schema
  database: INSURANCE_DB
  schema: CUSTOMER_MGMT
  
  # Auto-suspend warehouse after inactivity
  warehouse_options:
    auto_suspend: 60
    
  # Package dependencies
  packages:
    - streamlit>=1.28.0
    - pandas>=1.5.0
    - snowflake-snowpark-python>=1.9.0
```

---

## Useful SnowCLI Commands

### App Management

```bash
# List all Streamlit apps
snow streamlit list

# Describe specific app
snow streamlit describe insurance_customer_management

# Get app URL
snow streamlit get-url insurance_customer_management

# Open app in browser
snow streamlit open insurance_customer_management

# Drop/delete app
snow streamlit drop insurance_customer_management
```

### Database Operations

```bash
# Run SQL query
snow sql -q "SELECT * FROM CUSTOMERS LIMIT 5;"

# Run SQL file
snow sql -f setup_database.sql

# Interactive SQL
snow sql

# Check table counts
snow sql -q "SELECT COUNT(*) FROM CUSTOMERS;"
snow sql -q "SELECT COUNT(*) FROM CUSTOMER_AUDIT_LOG;"
```

### Connection Management

```bash
# List connections
snow connection list

# Test connection
snow connection test

# Add new connection
snow connection add

# Set default connection
snow connection set-default myconnection
```

### Logs and Debugging

```bash
# View app logs (if available)
snow streamlit logs insurance_customer_management

# Verbose output
snow streamlit deploy --replace -v

# Debug mode
snow streamlit deploy --replace --debug
```

---

## Troubleshooting

### Issue: "Connection failed"

**Solution:**
```bash
# Check config file
cat ~/.snowflake/config.toml

# Test connection
snow connection test

# Add connection interactively
snow connection add
```

### Issue: "Warehouse not found"

**Solution:**
```bash
# Update snowflake.yml with correct warehouse name
query_warehouse: YOUR_WAREHOUSE_NAME

# Or use environment variable
export SNOWFLAKE_WAREHOUSE=YOUR_WAREHOUSE_NAME
```

### Issue: "Database/Schema not found"

**Solution:**
```bash
# Create database and schema first
snow sql -q "CREATE DATABASE IF NOT EXISTS INSURANCE_DB;"
snow sql -q "CREATE SCHEMA IF NOT EXISTS INSURANCE_DB.CUSTOMER_MGMT;"
snow sql -q "USE SCHEMA INSURANCE_DB.CUSTOMER_MGMT;"

# Then run setup script
snow sql -f setup_database.sql
```

### Issue: "Permission denied"

**Solution:**
```bash
# Check current role
snow sql -q "SELECT CURRENT_ROLE();"

# Grant necessary permissions
snow sql -q "GRANT USAGE ON DATABASE INSURANCE_DB TO ROLE YOUR_ROLE;"
snow sql -q "GRANT USAGE ON SCHEMA CUSTOMER_MGMT TO ROLE YOUR_ROLE;"
snow sql -q "GRANT CREATE STREAMLIT ON SCHEMA CUSTOMER_MGMT TO ROLE YOUR_ROLE;"
```

### Issue: "App already exists"

**Solution:**
```bash
# Use --replace flag
snow streamlit deploy --replace

# Or drop and redeploy
snow streamlit drop insurance_customer_management
snow streamlit deploy
```

### Issue: "Requirements not found"

**Solution:**
```bash
# Ensure requirements.txt exists
ls requirements.txt

# Verify snowflake.yml artifacts section includes it
cat snowflake.yml | grep requirements.txt

# Redeploy
snow streamlit deploy --replace
```

---

## Update Workflow

### Updating the App

```bash
# 1. Make changes to streamlit_app.py
nano streamlit_app.py  # or your editor

# 2. Redeploy
snow streamlit deploy --replace

# 3. Refresh browser to see changes
```

### Updating Database Schema

```bash
# 1. Modify setup_database.sql
nano setup_database.sql

# 2. Run ALTER statements (don't drop tables with data!)
snow sql -q "ALTER TABLE CUSTOMERS ADD COLUMN NEW_FIELD VARCHAR(100);"

# 3. Update app code to use new fields
nano streamlit_app.py

# 4. Redeploy app
snow streamlit deploy --replace
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/deploy.yml
name: Deploy to Snowflake

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install SnowCLI
        run: pip install snowflake-cli-labs
      
      - name: Configure Snowflake
        run: |
          mkdir -p ~/.snowflake
          cat > ~/.snowflake/config.toml << EOF
          [connections.default]
          account = "${{ secrets.SNOWFLAKE_ACCOUNT }}"
          user = "${{ secrets.SNOWFLAKE_USER }}"
          password = "${{ secrets.SNOWFLAKE_PASSWORD }}"
          warehouse = "COMPUTE_WH"
          database = "INSURANCE_DB"
          schema = "CUSTOMER_MGMT"
          EOF
      
      - name: Deploy App
        run: snow streamlit deploy --replace
```

---

## Best Practices

### 1. Use Version Control
```bash
# Initialize git repo
git init
git add .
git commit -m "Initial commit"
```

### 2. Separate Environments
```toml
# ~/.snowflake/config.toml

[connections.dev]
account = "your-account"
database = "INSURANCE_DB_DEV"
schema = "CUSTOMER_MGMT"

[connections.prod]
account = "your-account"
database = "INSURANCE_DB_PROD"
schema = "CUSTOMER_MGMT"
```

Deploy to dev:
```bash
snow streamlit deploy --connection dev --replace
```

### 3. Backup Before Updates
```bash
# Backup tables
snow sql -q "CREATE TABLE CUSTOMERS_BACKUP AS SELECT * FROM CUSTOMERS;"
snow sql -q "CREATE TABLE AUDIT_LOG_BACKUP AS SELECT * FROM CUSTOMER_AUDIT_LOG;"
```

### 4. Test Locally First
```bash
# Validate SQL
snow sql -f setup_database.sql --dry-run

# Test queries
snow sql -f test_queries.sql
```

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `snow --version` | Check SnowCLI version |
| `snow connection test` | Test Snowflake connection |
| `snow sql -f file.sql` | Execute SQL file |
| `snow streamlit deploy --replace` | Deploy/update app |
| `snow streamlit list` | List all apps |
| `snow streamlit get-url <app>` | Get app URL |
| `snow streamlit open <app>` | Open app in browser |
| `snow streamlit drop <app>` | Delete app |

---

## Next Steps

1. ✅ Install SnowCLI
2. ✅ Configure connection
3. ✅ Run setup_database.sql
4. ✅ Deploy app
5. ✅ Test in browser
6. 🎉 Start managing customers!

---

**Ready to deploy? Run: `snow streamlit deploy --replace`** 🚀

