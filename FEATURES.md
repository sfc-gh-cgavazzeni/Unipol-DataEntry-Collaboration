# ✨ Feature Overview

## Core Features

### 1. 📋 Customer Data Management

#### View Customer Records
- **Expandable Cards:** Each customer displayed in a clean, collapsible card format
- **Key Information:** Name, policy details, contact info, premium amount
- **Status Badges:** Visual indicators for Active, Pending, Suspended, Cancelled
- **Sortable:** Records sorted by Customer ID by default

**Example Display:**
```
👤 Mario Rossi - POL-AUTO-001 (Active)
   └─ Customer ID: 1
      Email: mario.rossi@email.it
      Phone: +39 340 1234567
      Policy: Auto | €850.00
      Start: 2023-01-15
```

#### Filter & Search
- **Status Filter:** Filter by Active, Pending, Suspended, Cancelled, or All
- **Policy Type Filter:** Filter by Auto, Home, Life, Health, or All
- **Text Search:** Search across names, emails, and policy numbers
- **Real-time Results:** Instant filtering as you type
- **Result Count:** Shows number of matching customers

**Filter Combinations:**
- Status: Active + Policy Type: Auto → All active auto policies
- Search: "mario" → All customers with "mario" in name or email
- Multiple filters work together for precise results

### 2. ✏️ Inline Record Editing

#### Edit Interface
- **Per-Record Editing:** "Edit Record" button next to each customer
- **Full Field Access:** Edit all customer fields in one form
- **Type-Appropriate Inputs:**
  - Text fields for names, email, phone
  - Dropdowns for status and policy type
  - Number input for premium amount
  - Date picker for start date (inherited)

#### Edit Flow
```
1. Click "✏️ Edit Record" → Edit form expands
2. Modify desired fields → Changes staged locally
3. Enter mandatory comment → Explain the changes
4. Click "✅ Commit" → Save to database + log audit
   OR
   Click "❌ Cancel" → Discard changes
```

#### Validation
- **Required Comment:** Cannot commit without explanation
- **Field Validation:** Email format, phone format, positive premium
- **Status Values:** Restricted to valid options
- **Policy Types:** Restricted to Auto, Home, Life, Health

#### User Experience
- **Single Edit Mode:** Only one customer editable at a time (prevents confusion)
- **Visual Feedback:** Success/error messages after commit
- **Auto-Refresh:** Table refreshes after successful commit
- **State Preservation:** Form remembers values until committed/cancelled

### 3. 📊 Audit Trail & Change Tracking

#### Audit Log Table
**Purpose:** Complete history of all modifications

**Captured Data:**
- 🆔 **Audit ID:** Unique identifier for each change
- 👤 **Customer ID & Name:** Which customer was modified
- 🧑‍💼 **Modified By:** Snowflake username who made change
- ⏰ **Modified At:** Exact timestamp of change
- 💬 **Comment:** User-provided explanation (mandatory)
- 🔄 **Change Type:** UPDATE, INSERT, DELETE
- 📦 **Old Values:** Complete record before change (JSON)
- 📦 **New Values:** Complete record after change (JSON)

**Display:**
```
Recent Updates:
┌────────┬────────────┬─────────────────────┬──────────────┬─────────────────────┬──────────────────────┐
│Audit ID│Customer ID │Customer Name        │Modified By   │Timestamp            │Comment               │
├────────┼────────────┼─────────────────────┼──────────────┼─────────────────────┼──────────────────────┤
│   15   │     1      │Mario Rossi          │ADMIN_USER    │2024-11-20 10:30:15  │Updated policy status │
│   14   │     3      │Giuseppe Verdi       │AGENT_SMITH   │2024-11-20 09:15:42  │Premium adjustment    │
└────────┴────────────┴─────────────────────┴──────────────┴─────────────────────┴──────────────────────┘
```

**Use Cases:**
- Compliance auditing
- Change history review
- User activity monitoring
- Rollback information
- Training and quality assurance

#### Snowflake Streams (CDC)
**Purpose:** Real-time change data capture

**Captured Metadata:**
- Customer ID
- Customer Name
- Action Type (INSERT, UPDATE, DELETE)
- Is Update flag
- Row ID (unique change identifier)
- Automatic timestamp tracking

**Benefits:**
- **Zero Configuration:** Automatic tracking after stream creation
- **Low Overhead:** Minimal performance impact
- **Real-Time:** Captures changes as they happen
- **Metadata Rich:** Includes operation type and flags
- **Downstream Integration:** Can feed other systems

**Display:**
```
Stream Changes:
┌────────────┬────────────┬────────────┬────────┬───────────┬────────┐
│Customer ID │First Name  │Last Name   │Action  │Is Update  │Row ID  │
├────────────┼────────────┼────────────┼────────┼───────────┼────────┤
│     1      │Mario       │Rossi       │UPDATE  │   true    │ 1234   │
│     5      │Franco      │Ferrari     │INSERT  │   false   │ 1235   │
└────────────┴────────────┴────────────┴────────┴───────────┴────────┘
```

### 4. 🔐 User Tracking

#### Automatic User Detection
- **Current User Display:** Shows logged-in Snowflake user in sidebar
- **Automatic Capture:** No manual user input required
- **Audit Trail:** Every change tagged with user who made it
- **Snowflake Integration:** Uses CURRENT_USER() function

**Example:**
```
Sidebar:
┌─────────────────────────┐
│ 👤 Logged in as:        │
│    ADMIN_USER           │
└─────────────────────────┘
```

### 5. 🎨 User Interface Features

#### Responsive Layout
- **Wide Layout:** Utilizes full screen width
- **Columnar Design:** Information organized in logical columns
- **Collapsible Sections:** Expand/collapse for focused viewing
- **Tabbed Interface:** Separate tabs for different views

#### Visual Feedback
- **✅ Success Messages:** Green confirmation on successful saves
- **❌ Error Messages:** Red alerts for validation errors
- **⚠️ Warning Messages:** Yellow notices for important info
- **ℹ️ Info Messages:** Blue informational notes

#### Icons & Emoji
- 👤 Customer indicators
- ✏️ Edit actions
- 🔍 Search/filter
- 📋 Data tables
- 📊 Analytics/reports
- 🔄 Refresh actions
- ✅ Confirm actions
- ❌ Cancel actions

#### Interactive Elements
- **Buttons:** Clear call-to-action buttons
- **Dropdowns:** Easy selection for predefined values
- **Text Inputs:** Clean input fields with placeholders
- **Text Areas:** Large comment boxes
- **Expanders:** Show/hide detailed information

### 6. 💾 Data Persistence

#### Database Integration
- **Direct Snowflake Connection:** Native Snowpark integration
- **Transactional Updates:** ACID-compliant changes
- **Immediate Consistency:** Changes visible immediately
- **No Cache Issues:** Direct database queries

#### Update Process
```
1. User commits changes
   ↓
2. Application captures old values
   ↓
3. UPDATE CUSTOMERS table
   ↓
4. Capture new values
   ↓
5. INSERT into CUSTOMER_AUDIT_LOG
   ↓
6. Stream automatically captures change
   ↓
7. UI refreshes with new data
```

### 7. 🔍 Advanced Filtering

#### Multi-Criteria Filtering
**Status Filter:**
- All (no filter)
- Active
- Pending
- Suspended
- Cancelled

**Policy Type Filter:**
- All (no filter)
- Auto
- Home
- Life
- Health

**Text Search:**
- Searches: First Name, Last Name, Email, Policy Number
- Case-insensitive
- Partial matches
- Real-time results

**Combined Filters:**
```python
# Example: Find suspended health policies with "mario" in name
Status: Suspended
Policy Type: Health
Search: mario
→ Returns only customers matching ALL criteria
```

### 8. 📈 Change Analytics

#### Recent Activity Dashboard
- **Last 20 Changes:** Most recent modifications displayed
- **User Activity:** See who's making changes
- **Time Distribution:** When changes occur
- **Customer Focus:** Which customers modified most frequently

#### Stream Monitoring
- **Real-Time CDC:** Live view of database changes
- **Operation Types:** INSERT, UPDATE, DELETE tracking
- **Change Velocity:** How often data changes
- **Integration Ready:** Data available for downstream systems

## Technical Features

### Architecture

#### Single-Page Application
- **No Page Reloads:** Smooth, app-like experience
- **State Management:** Session state tracks edit mode
- **Dynamic Content:** UI updates based on user actions

#### Snowflake-Native
- **Snowpark Integration:** Direct Python API access
- **SQL Execution:** Efficient query execution
- **Streams & Tables:** Native Snowflake objects
- **Security:** Inherits Snowflake security model

### Performance

#### Optimized Queries
- **Selective Loading:** Load only needed columns
- **Filtered Results:** Filter at database level
- **Indexed Lookups:** Fast customer retrieval by ID
- **Limited Results:** Audit log limited to recent entries

#### Efficient Updates
- **Minimal Writes:** Only changed fields updated
- **Batch Operations:** Single transaction per edit
- **Stream Efficiency:** Low-overhead CDC
- **Session Reuse:** Persistent Snowpark session

### Security

#### Access Control
- **Snowflake Roles:** Respects role-based permissions
- **User Authentication:** Snowflake login required
- **Audit Trail:** Every change tracked with user
- **Read-Only Stream:** Streams don't affect source data

#### Data Validation
- **Input Validation:** Type checking on all fields
- **SQL Injection Protection:** Parameterized queries
- **Comment Requirement:** Ensures change documentation
- **Error Handling:** Graceful error messages

## Data Features

### Sample Dataset

#### 8 Insurance Customers
**Demographics:**
- Italian names and contact info
- Mix of policy types
- Range of premium amounts (€850 - €3,200)
- Various statuses

**Policy Distribution:**
- 2 Auto policies
- 2 Home policies
- 2 Life policies
- 2 Health policies

**Status Distribution:**
- 6 Active
- 1 Pending
- 1 Suspended

### Data Fields

#### Customer Table (12 fields)
1. **CUSTOMER_ID** - Auto-incrementing primary key
2. **FIRST_NAME** - Customer first name
3. **LAST_NAME** - Customer last name
4. **EMAIL** - Contact email
5. **PHONE** - Phone number (Italian format)
6. **POLICY_TYPE** - Auto, Home, Life, or Health
7. **POLICY_NUMBER** - Unique policy identifier
8. **PREMIUM_AMOUNT** - Annual premium in euros
9. **STATUS** - Active, Pending, Suspended, Cancelled
10. **START_DATE** - Policy start date
11. **LAST_MODIFIED_BY** - User who last edited
12. **LAST_MODIFIED_AT** - Timestamp of last edit

#### Audit Log (8 fields)
1. **AUDIT_ID** - Auto-incrementing log ID
2. **CUSTOMER_ID** - Reference to customer
3. **MODIFIED_BY** - Snowflake user
4. **MODIFIED_AT** - Change timestamp
5. **COMMENT** - User explanation
6. **CHANGE_TYPE** - UPDATE, INSERT, DELETE
7. **OLD_VALUES** - JSON of previous values
8. **NEW_VALUES** - JSON of current values

## Integration Features

### Extensibility

#### Easy Customization
- **Add Fields:** Update SQL schema + edit forms
- **Change Validations:** Modify validation logic
- **Adjust UI:** Streamlit components easy to modify
- **Add Features:** Modular function structure

#### Integration Points
- **Streams:** Can feed data warehouses
- **Audit Log:** Can be queried by BI tools
- **REST APIs:** Snowflake external functions
- **Webhooks:** Trigger external systems on changes

### Deployment

#### Snowflake Streamlit
- **Built-in Hosting:** No external server needed
- **Automatic Scaling:** Snowflake manages resources
- **Secure Access:** Snowflake authentication
- **Version Control:** Easy updates through UI

---

**Complete feature set for production insurance customer management!**

