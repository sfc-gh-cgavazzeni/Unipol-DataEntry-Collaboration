"""
Unipol - Insurance Customer Management System
Streamlit Application for Snowflake
"""

import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col
import json
from datetime import datetime

# Get the Snowflake session
# When running on Snowflake, this will automatically connect
try:
    session = get_active_session()
    SNOWFLAKE_MODE = True
except:
    # For local testing, you'll need to create a session manually
    st.error("⚠️ This app is designed to run on Snowflake. Please deploy it to Snowflake Streamlit.")
    SNOWFLAKE_MODE = False
    st.stop()

# Page configuration with Unipol branding
st.set_page_config(
    page_title="Unipol - Customer Management",
    page_icon="🔷",  # Using a blue diamond as placeholder
    layout="wide",
    initial_sidebar_state="expanded"
)

# Unipol Brand Colors and Custom CSS
st.markdown("""
<style>
    /* Unipol Brand Colors */
    :root {
        --unipol-blue: #003d7a;
        --unipol-red: #e30613;
        --unipol-green: #00a650;
        --unipol-light-blue: #0066b3;
        --unipol-gray: #6c757d;
    }
    
    /* Header Styling */
    .main-header {
        background: linear-gradient(to right, 
            var(--unipol-red) 0%, var(--unipol-red) 33%,
            var(--unipol-green) 33%, var(--unipol-green) 66%,
            var(--unipol-blue) 66%, var(--unipol-blue) 100%);
        height: 5px;
        margin-bottom: 2rem;
        border-radius: 2px;
    }
    
    /* Title Styling */
    .unipol-title {
        color: var(--unipol-blue);
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        font-weight: 700;
        font-size: 2.5rem;
        margin-bottom: 0.5rem;
    }
    
    .unipol-subtitle {
        color: var(--unipol-gray);
        font-size: 1.1rem;
        margin-bottom: 2rem;
    }
    
    /* Sidebar Styling */
    [data-testid="stSidebar"] {
        background-color: #f8f9fa;
    }
    
    /* Button Styling */
    .stButton>button {
        background-color: var(--unipol-blue);
        color: white;
        border-radius: 4px;
        border: none;
        padding: 0.5rem 1rem;
        font-weight: 500;
    }
    
    .stButton>button:hover {
        background-color: var(--unipol-light-blue);
    }
    
    /* Primary Button */
    .stButton>button[kind="primary"] {
        background-color: var(--unipol-red);
    }
    
    .stButton>button[kind="primary"]:hover {
        background-color: #c00510;
    }
    
    /* Info Box Styling */
    .stInfo {
        background-color: #e7f3ff;
        border-left: 4px solid var(--unipol-blue);
    }
    
    /* Expander Styling */
    .streamlit-expanderHeader {
        background-color: #f8f9fa;
        border-radius: 4px;
        color: var(--unipol-blue);
        font-weight: 600;
    }
    
    /* Card-like containers */
    div[data-testid="stExpander"] {
        border: 1px solid #dee2e6;
        border-radius: 8px;
        margin-bottom: 1rem;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    
    /* Success messages */
    .stSuccess {
        background-color: #d4edda;
        border-left: 4px solid var(--unipol-green);
    }
    
    /* Error messages */
    .stError {
        background-color: #f8d7da;
        border-left: 4px solid var(--unipol-red);
    }
    
    /* Tabs styling */
    .stTabs [data-baseweb="tab-list"] {
        gap: 2rem;
    }
    
    .stTabs [data-baseweb="tab"] {
        color: var(--unipol-blue);
        font-weight: 600;
    }
    
    .stTabs [aria-selected="true"] {
        border-bottom-color: var(--unipol-red);
    }
</style>
""", unsafe_allow_html=True)

# Initialize session state
if 'editing_customer_id' not in st.session_state:
    st.session_state.editing_customer_id = None
if 'edit_mode' not in st.session_state:
    st.session_state.edit_mode = False
if 'refresh_trigger' not in st.session_state:
    st.session_state.refresh_trigger = 0

def reset_edit_mode():
    """Reset editing state"""
    st.session_state.editing_customer_id = None
    st.session_state.edit_mode = False

def get_current_user():
    """Get current Snowflake user"""
    try:
        user_query = session.sql("SELECT CURRENT_USER() as user").collect()
        return user_query[0]['USER']
    except:
        return "UNKNOWN_USER"

def load_customers(filters=None):
    """Load customers from Snowflake table"""
    query = """
    SELECT 
        CUSTOMER_ID,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        PHONE,
        POLICY_TYPE,
        POLICY_NUMBER,
        PREMIUM_AMOUNT,
        STATUS,
        START_DATE,
        LAST_MODIFIED_BY,
        LAST_MODIFIED_AT
    FROM CUSTOMERS
    ORDER BY CUSTOMER_ID
    """
    
    df = session.sql(query).to_pandas()
    
    # Convert string columns to proper types to avoid Snowflake type issues
    string_columns = ['FIRST_NAME', 'LAST_NAME', 'EMAIL', 'PHONE', 'POLICY_TYPE', 'POLICY_NUMBER', 'STATUS', 'LAST_MODIFIED_BY']
    for col in string_columns:
        if col in df.columns:
            df[col] = df[col].astype(str)
    
    # Apply filters if provided
    if filters:
        if filters.get('status') and filters['status'] != 'All':
            df = df[df['STATUS'] == filters['status']]
        if filters.get('policy_type') and filters['policy_type'] != 'All':
            df = df[df['POLICY_TYPE'] == filters['policy_type']]
        if filters.get('search'):
            search_term = filters['search'].lower()
            df = df[
                df['FIRST_NAME'].str.lower().str.contains(search_term, na=False) |
                df['LAST_NAME'].str.lower().str.contains(search_term, na=False) |
                df['EMAIL'].str.lower().str.contains(search_term, na=False) |
                df['POLICY_NUMBER'].str.lower().str.contains(search_term, na=False)
            ]
    
    return df

def get_customer_by_id(customer_id):
    """Get a specific customer by ID"""
    query = f"""
    SELECT * FROM CUSTOMERS 
    WHERE CUSTOMER_ID = {customer_id}
    """
    df = session.sql(query).to_pandas()
    return df.iloc[0].to_dict() if not df.empty else None

def update_customer(customer_id, updates, comment, user):
    """Update customer record and log the change"""
    # Get old values
    old_record = get_customer_by_id(customer_id)
    
    if not old_record:
        return False, "Customer not found"
    
    # Build update query
    set_clauses = []
    for field, value in updates.items():
        if isinstance(value, str):
            # Escape single quotes by doubling them for SQL
            escaped_value = value.replace("'", "''")
            set_clauses.append(f"{field} = '{escaped_value}'")
        elif value is None:
            set_clauses.append(f"{field} = NULL")
        else:
            set_clauses.append(f"{field} = {value}")
    
    escaped_user = user.replace("'", "''")
    set_clauses.append(f"LAST_MODIFIED_BY = '{escaped_user}'")
    set_clauses.append("LAST_MODIFIED_AT = CURRENT_TIMESTAMP()")
    
    update_query = f"""
    UPDATE CUSTOMERS 
    SET {', '.join(set_clauses)}
    WHERE CUSTOMER_ID = {customer_id}
    """
    
    try:
        # Execute update
        session.sql(update_query).collect()
        
        # Get new values
        new_record = get_customer_by_id(customer_id)
        
        # Escape values for SQL
        escaped_user = user.replace("'", "''")
        escaped_comment = comment.replace("'", "''")
        
        # Convert dictionaries to JSON strings and escape for SQL
        old_json_str = json.dumps(old_record, default=str).replace("'", "''")
        new_json_str = json.dumps(new_record, default=str).replace("'", "''")
        
        # Insert audit log - explicitly specify columns (exclude AUDIT_ID which is autoincrement)
        # Use TO_VARIANT to convert JSON string to VARIANT type
        audit_query = f"""
        INSERT INTO CUSTOMER_AUDIT_LOG 
            (CUSTOMER_ID, MODIFIED_BY, MODIFIED_AT, COMMENT, CHANGE_TYPE, OLD_VALUES, NEW_VALUES)
        SELECT 
            {customer_id},
            '{escaped_user}',
            CURRENT_TIMESTAMP(),
            '{escaped_comment}',
            'UPDATE',
            TO_VARIANT(PARSE_JSON('{old_json_str}')),
            TO_VARIANT(PARSE_JSON('{new_json_str}'))
        """
        session.sql(audit_query).collect()
        
        return True, "Customer updated successfully"
    except Exception as e:
        return False, f"Error updating customer: {str(e)}"

def load_recent_changes(limit=10):
    """Load recent changes from audit log"""
    query = f"""
    SELECT 
        a.AUDIT_ID,
        a.CUSTOMER_ID,
        c.FIRST_NAME || ' ' || c.LAST_NAME as CUSTOMER_NAME,
        a.MODIFIED_BY,
        a.MODIFIED_AT,
        a.COMMENT,
        a.CHANGE_TYPE
    FROM CUSTOMER_AUDIT_LOG a
    LEFT JOIN CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID
    ORDER BY a.MODIFIED_AT DESC
    LIMIT {limit}
    """
    
    try:
        df = session.sql(query).to_pandas()
        return df
    except:
        return pd.DataFrame()

def load_stream_changes():
    """Load changes from Snowflake stream"""
    query = """
    SELECT 
        CUSTOMER_ID,
        FIRST_NAME,
        LAST_NAME,
        METADATA$ACTION as ACTION,
        METADATA$ISUPDATE as IS_UPDATE,
        METADATA$ROW_ID as ROW_ID
    FROM CUSTOMERS_STREAM
    ORDER BY METADATA$ROW_ID DESC
    LIMIT 20
    """
    
    try:
        df = session.sql(query).to_pandas()
        return df
    except Exception as e:
        return pd.DataFrame()

# ============================================
# MAIN APPLICATION
# ============================================

# Unipol Header with brand colors
st.markdown('<div class="main-header"></div>', unsafe_allow_html=True)

# Create columns for logo and title
col_logo, col_title = st.columns([1, 5])

with col_logo:
    # Using text representation of Unipol logo
    st.markdown("""
    <div style="font-family: Arial, sans-serif; font-weight: bold; font-size: 2rem; color: #003d7a; line-height: 1.2;">
        Unipol
    </div>
    <div style="height: 3px; background: linear-gradient(to right, #e30613 33%, #00a650 33%, #00a650 66%, #003d7a 66%); margin-top: 5px;"></div>
    """, unsafe_allow_html=True)

with col_title:
    st.markdown('<h1 class="unipol-title">Customer Management System</h1>', unsafe_allow_html=True)
    st.markdown('<p class="unipol-subtitle">Gestione Clienti Assicurativi</p>', unsafe_allow_html=True)

st.markdown("<br>", unsafe_allow_html=True)

# Get current user
current_user = get_current_user()
st.sidebar.info(f"👤 Utente: **{current_user}**")

# ============================================
# FILTERS SECTION
# ============================================

st.sidebar.markdown('<h3 style="color: #003d7a;">🔍 Filtri</h3>', unsafe_allow_html=True)

# Get unique values for filters
try:
    all_customers = session.sql("SELECT DISTINCT STATUS, POLICY_TYPE FROM CUSTOMERS").to_pandas()
    status_options = ['All'] + sorted([str(x) for x in all_customers['STATUS'].dropna().unique().tolist()])
    policy_type_options = ['All'] + sorted([str(x) for x in all_customers['POLICY_TYPE'].dropna().unique().tolist()])
except:
    status_options = ['All']
    policy_type_options = ['All']

status_filter = st.sidebar.selectbox("Status", status_options)
policy_type_filter = st.sidebar.selectbox("Policy Type", policy_type_options)
search_filter = st.sidebar.text_input("Search (Name, Email, Policy Number)")

filters = {
    'status': status_filter,
    'policy_type': policy_type_filter,
    'search': search_filter
}

if st.sidebar.button("🔄 Refresh Data"):
    st.session_state.refresh_trigger += 1
    reset_edit_mode()
    st.rerun()

# ============================================
# CUSTOMER TABLE SECTION
# ============================================

st.markdown('<h2 style="color: #003d7a; margin-top: 2rem;">📋 Anagrafica Clienti</h2>', unsafe_allow_html=True)

# Load customers
customers_df = load_customers(filters)

if customers_df.empty:
    st.warning("No customers found matching the filters.")
else:
    st.info(f"Showing **{len(customers_df)}** customer(s)")
    
    # Display customers with edit buttons
    for idx, row in customers_df.iterrows():
        with st.container():
            col1, col2 = st.columns([6, 1])
            
            with col1:
                # Create an expander for each customer
                expander_title = f"👤 {str(row['FIRST_NAME'])} {str(row['LAST_NAME'])} - {str(row['POLICY_NUMBER'])} ({str(row['STATUS'])})"
                customer_id = int(row['CUSTOMER_ID'])
                with st.expander(
                    expander_title,
                    expanded=(st.session_state.editing_customer_id == customer_id)
                ):
                    # Display customer details
                    info_col1, info_col2, info_col3 = st.columns(3)
                    
                    with info_col1:
                        st.markdown(f"**Customer ID:** {int(row['CUSTOMER_ID'])}")
                        st.markdown(f"**Email:** {str(row['EMAIL'])}")
                        st.markdown(f"**Phone:** {str(row['PHONE'])}")
                    
                    with info_col2:
                        st.markdown(f"**Policy Type:** {str(row['POLICY_TYPE'])}")
                        st.markdown(f"**Policy Number:** {str(row['POLICY_NUMBER'])}")
                        premium_value = float(row['PREMIUM_AMOUNT']) if row['PREMIUM_AMOUNT'] is not None else 0.0
                        st.markdown(f"**Premium:** €{premium_value:,.2f}")
                    
                    with info_col3:
                        st.markdown(f"**Status:** {str(row['STATUS'])}")
                        st.markdown(f"**Start Date:** {str(row['START_DATE'])}")
                        st.markdown(f"**Last Modified:** {str(row['LAST_MODIFIED_AT'])}")
                    
                    # Edit mode for this customer
                    if st.session_state.editing_customer_id == customer_id:
                        st.markdown("---")
                        st.subheader("✏️ Edit Customer Information")
                        
                        edit_col1, edit_col2 = st.columns(2)
                        
                        with edit_col1:
                            new_first_name = st.text_input("First Name", value=str(row['FIRST_NAME']), key=f"fn_{customer_id}")
                            new_last_name = st.text_input("Last Name", value=str(row['LAST_NAME']), key=f"ln_{customer_id}")
                            new_email = st.text_input("Email", value=str(row['EMAIL']), key=f"email_{customer_id}")
                            new_phone = st.text_input("Phone", value=str(row['PHONE']), key=f"phone_{customer_id}")
                        
                        with edit_col2:
                            policy_type_str = str(row['POLICY_TYPE'])
                            new_policy_type = st.selectbox(
                                "Policy Type", 
                                ['Auto', 'Home', 'Life', 'Health'],
                                index=['Auto', 'Home', 'Life', 'Health'].index(policy_type_str) if policy_type_str in ['Auto', 'Home', 'Life', 'Health'] else 0,
                                key=f"pt_{customer_id}"
                            )
                            new_policy_number = st.text_input("Policy Number", value=str(row['POLICY_NUMBER']), key=f"pn_{customer_id}")
                            premium_value = float(row['PREMIUM_AMOUNT']) if row['PREMIUM_AMOUNT'] is not None else 0.0
                            new_premium = st.number_input("Premium Amount", value=premium_value, min_value=0.0, key=f"prem_{customer_id}")
                            status_str = str(row['STATUS'])
                            new_status = st.selectbox(
                                "Status", 
                                ['Active', 'Pending', 'Suspended', 'Cancelled'],
                                index=['Active', 'Pending', 'Suspended', 'Cancelled'].index(status_str) if status_str in ['Active', 'Pending', 'Suspended', 'Cancelled'] else 0,
                                key=f"stat_{customer_id}"
                            )
                        
                        # Comment field
                        comment = st.text_area("Comment (required)", placeholder="Describe the changes made...", key=f"comment_{customer_id}")
                        
                        # Action buttons
                        btn_col1, btn_col2, btn_col3 = st.columns([1, 1, 4])
                        
                        with btn_col1:
                            if st.button("✅ Commit", key=f"commit_{customer_id}", type="primary"):
                                if not comment or comment.strip() == "":
                                    st.error("⚠️ Please provide a comment describing the changes.")
                                else:
                                    # Prepare updates
                                    updates = {
                                        'FIRST_NAME': new_first_name,
                                        'LAST_NAME': new_last_name,
                                        'EMAIL': new_email,
                                        'PHONE': new_phone,
                                        'POLICY_TYPE': new_policy_type,
                                        'POLICY_NUMBER': new_policy_number,
                                        'PREMIUM_AMOUNT': new_premium,
                                        'STATUS': new_status
                                    }
                                    
                                    # Update customer
                                    success, message = update_customer(
                                        customer_id,
                                        updates,
                                        comment,
                                        current_user
                                    )
                                    
                                    if success:
                                        st.success(f"✅ {message}")
                                        reset_edit_mode()
                                        st.rerun()
                                    else:
                                        st.error(f"❌ {message}")
                        
                        with btn_col2:
                            if st.button("❌ Cancel", key=f"cancel_{customer_id}"):
                                reset_edit_mode()
                                st.rerun()
            
            with col2:
                # Edit button
                if st.session_state.editing_customer_id != customer_id:
                    if st.button("✏️ Edit Record", key=f"edit_btn_{customer_id}", type="secondary"):
                        st.session_state.editing_customer_id = customer_id
                        st.rerun()

st.markdown("---")

# ============================================
# CHANGE TRACKING SECTION
# ============================================

st.markdown('<h2 style="color: #003d7a; margin-top: 3rem;">📊 Registro Modifiche & Attività</h2>', unsafe_allow_html=True)

tab1, tab2 = st.tabs(["📝 Audit Log", "🔄 Stream Changes"])

with tab1:
    st.subheader("Latest Updates")
    recent_changes = load_recent_changes(20)
    
    if recent_changes.empty:
        st.info("No changes recorded yet.")
    else:
        # Format the dataframe for display
        display_df = recent_changes.copy()
        if 'MODIFIED_AT' in display_df.columns:
            display_df['MODIFIED_AT'] = pd.to_datetime(display_df['MODIFIED_AT']).dt.strftime('%Y-%m-%d %H:%M:%S')
        
        st.dataframe(
            display_df,
            column_config={
                "AUDIT_ID": "Audit ID",
                "CUSTOMER_ID": "Customer ID",
                "CUSTOMER_NAME": "Customer Name",
                "MODIFIED_BY": "Modified By",
                "MODIFIED_AT": "Timestamp",
                "COMMENT": "Comment",
                "CHANGE_TYPE": "Type"
            },
            hide_index=True,
            use_container_width=True
        )

with tab2:
    st.subheader("Snowflake Stream Changes")
    st.caption("Real-time tracking of changes captured by Snowflake Streams")
    
    stream_changes = load_stream_changes()
    
    if stream_changes.empty:
        st.info("No stream changes detected. Changes will appear here when data is modified.")
    else:
        st.dataframe(
            stream_changes,
            column_config={
                "CUSTOMER_ID": "Customer ID",
                "FIRST_NAME": "First Name",
                "LAST_NAME": "Last Name",
                "ACTION": "Action",
                "IS_UPDATE": "Is Update",
                "ROW_ID": "Row ID"
            },
            hide_index=True,
            use_container_width=True
        )

# Footer with Unipol branding
st.markdown("<br><br>", unsafe_allow_html=True)
st.markdown('<div class="main-header"></div>', unsafe_allow_html=True)
st.markdown("""
<div style="text-align: center; color: #6c757d; padding: 1rem; font-size: 0.9rem;">
    <div style="margin-bottom: 0.5rem;">
        <strong style="color: #003d7a;">Unipol</strong> Customer Management System
    </div>
    <div>Powered by Snowflake & Streamlit</div>
</div>
""", unsafe_allow_html=True)

