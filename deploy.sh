#!/bin/bash

# ============================================
# Deployment Script for Insurance Customer Management System
# Using Snowflake SnowCLI
# ============================================

set -e  # Exit on error

echo "🚀 Insurance Customer Management - SnowCLI Deployment"
echo "======================================================="
echo ""

# Configuration - UPDATE THESE VALUES
DATABASE="INSURANCE_DB"
SCHEMA="CUSTOMER_MGMT"
WAREHOUSE="COMPUTE_WH"  # Change to your warehouse name
CONNECTION="default"     # Change to your connection name if different

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if SnowCLI is installed
print_step "Checking SnowCLI installation..."
if ! command -v snow &> /dev/null; then
    print_error "SnowCLI is not installed!"
    echo "Please install it with: pip install snowflake-cli-labs"
    exit 1
fi
SNOW_VERSION=$(snow --version)
print_success "SnowCLI is installed: $SNOW_VERSION"
echo ""

# Test Snowflake connection
print_step "Testing Snowflake connection..."
if snow connection test --connection "$CONNECTION" &> /dev/null; then
    print_success "Connection successful!"
else
    print_error "Connection failed!"
    echo "Please configure your connection with: snow connection add"
    exit 1
fi
echo ""

# Create database and schema
print_step "Setting up database and schema..."
snow sql --connection "$CONNECTION" -q "CREATE DATABASE IF NOT EXISTS $DATABASE;" > /dev/null
print_success "Database $DATABASE created/verified"

snow sql --connection "$CONNECTION" -q "USE DATABASE $DATABASE;" > /dev/null
snow sql --connection "$CONNECTION" -q "CREATE SCHEMA IF NOT EXISTS $SCHEMA;" > /dev/null
print_success "Schema $SCHEMA created/verified"

snow sql --connection "$CONNECTION" -q "USE SCHEMA $SCHEMA;" > /dev/null
print_success "Using $DATABASE.$SCHEMA"
echo ""

# Create tables and load data
print_step "Creating tables and loading sample data..."
if snow sql --connection "$CONNECTION" -f setup_database.sql > /dev/null 2>&1; then
    print_success "Tables created successfully"
else
    print_warning "Tables may already exist (this is OK)"
fi
echo ""

# Verify data
print_step "Verifying data..."
CUSTOMER_COUNT=$(snow sql --connection "$CONNECTION" -q "SELECT COUNT(*) as count FROM $DATABASE.$SCHEMA.CUSTOMERS;" -o json 2>/dev/null | grep -o '"COUNT":[0-9]*' | grep -o '[0-9]*' || echo "0")

if [ "$CUSTOMER_COUNT" -ge 8 ]; then
    print_success "Found $CUSTOMER_COUNT customer records"
else
    print_warning "Expected 8 customers, found $CUSTOMER_COUNT"
fi
echo ""

# Check if tables exist
print_step "Checking database objects..."
TABLES=$(snow sql --connection "$CONNECTION" -q "SHOW TABLES IN SCHEMA $DATABASE.$SCHEMA;" -o plain 2>/dev/null | grep -E "CUSTOMERS|CUSTOMER_AUDIT_LOG" | wc -l)
if [ "$TABLES" -ge 2 ]; then
    print_success "All required tables exist"
else
    print_warning "Some tables may be missing"
fi

STREAMS=$(snow sql --connection "$CONNECTION" -q "SHOW STREAMS IN SCHEMA $DATABASE.$SCHEMA;" -o plain 2>/dev/null | grep "CUSTOMERS_STREAM" | wc -l)
if [ "$STREAMS" -ge 1 ]; then
    print_success "Stream exists"
else
    print_warning "Stream may be missing"
fi
echo ""

# Update snowflake.yml with correct warehouse
print_step "Updating configuration..."
if [ -f "snowflake.yml" ]; then
    # Backup original
    cp snowflake.yml snowflake.yml.bak
    # Update warehouse name
    sed -i.tmp "s/query_warehouse:.*/query_warehouse: $WAREHOUSE/" snowflake.yml
    rm snowflake.yml.tmp 2>/dev/null || true
    print_success "Configuration updated"
else
    print_warning "snowflake.yml not found"
fi
echo ""

# Deploy Streamlit app
print_step "Deploying Streamlit app..."
echo "This may take a minute..."
if snow streamlit deploy --connection "$CONNECTION" --replace 2>&1 | tee /tmp/deploy.log; then
    print_success "Streamlit app deployed successfully!"
else
    print_error "Deployment failed. Check logs above."
    exit 1
fi
echo ""

# Get app URL
print_step "Getting app URL..."
APP_URL=$(snow streamlit get-url --connection "$CONNECTION" insurance_customer_management 2>/dev/null || echo "")
if [ -n "$APP_URL" ]; then
    print_success "App URL: $APP_URL"
else
    print_warning "Could not retrieve app URL automatically"
    echo "List your apps with: snow streamlit list"
fi
echo ""

# Summary
echo "======================================================="
echo -e "${GREEN}✨ Deployment Complete!${NC}"
echo "======================================================="
echo ""
echo "📋 Summary:"
echo "  • Database: $DATABASE"
echo "  • Schema: $SCHEMA"
echo "  • Customers: $CUSTOMER_COUNT records"
echo "  • App: insurance_customer_management"
if [ -n "$APP_URL" ]; then
    echo "  • URL: $APP_URL"
fi
echo ""
echo "🎯 Next Steps:"
echo "  1. Open app: snow streamlit open insurance_customer_management"
echo "  2. Or visit the URL in your browser"
echo "  3. Test filtering and editing features"
echo "  4. Check audit log at the bottom of the app"
echo ""
echo "📚 Useful Commands:"
echo "  • List apps: snow streamlit list"
echo "  • View logs: snow streamlit logs insurance_customer_management"
echo "  • Update app: ./deploy.sh (run this script again)"
echo "  • Drop app: snow streamlit drop insurance_customer_management"
echo ""
print_success "Happy customer managing! 🎉"

