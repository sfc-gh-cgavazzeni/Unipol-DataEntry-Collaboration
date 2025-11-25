# Unipol Customer Management System

## Native Application for Snowflake

Professional insurance customer management system with audit trails, change tracking, and notes functionality.

---

## Features

- ✅ **Customer Management** - View and edit customer information
- ✅ **Audit Trail** - Complete history of all changes
- ✅ **Change Tracking** - Real-time CDC with Snowflake Streams
- ✅ **Table Notes** - Add contextual notes to tables
- ✅ **Multi-table View** - Switch between different data views
- ✅ **Unipol Branding** - Professional Unipol corporate identity

---

## Installation

### Prerequisites

- Snowflake account
- Appropriate role permissions
- Access to customer data

### Install Application

```sql
-- Install from package
CREATE APPLICATION unipol_customer_mgmt
  FROM APPLICATION PACKAGE unipol_customer_mgmt_pkg
  USING VERSION V1_0;

-- Grant access to users
GRANT USAGE ON APPLICATION unipol_customer_mgmt TO ROLE your_role;
```

---

## User Roles

### Viewer
- Read-only access to all data
- View customers, audit logs, and notes

### Editor
- Edit customer information
- Add audit comments
- Create table notes

### Admin
- Full access to all features
- Manage all data

---

## Usage

1. **Access the application** from your Snowflake account
2. **Select table** to view (Customers or Audit Log)
3. **Filter and search** customer data
4. **Edit records** with mandatory comments
5. **Add notes** for team communication
6. **Track changes** in audit log and streams

---

## Support

For issues or questions, contact your Snowflake administrator.

---

## Version

**Version:** 1.0.0  
**Release Date:** 2025  
**Provider:** Unipol


