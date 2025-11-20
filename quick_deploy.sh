#!/bin/bash
# Quick deployment script for Streamlit app

set -e

echo "🚀 Deploying Insurance Customer Management App..."
echo ""

cd "$(dirname "$0")"

# Deploy to Snowflake
snow streamlit deploy --replace --database INSURANCE_DB --schema CUSTOMER_MGMT

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 App URL:"
snow streamlit get-url insurance_customer_management --database INSURANCE_DB --schema CUSTOMER_MGMT

