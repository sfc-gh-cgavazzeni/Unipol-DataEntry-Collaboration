-- ============================================
-- Email Notification usando SendGrid API
-- (Alternativa più semplice senza bisogno di ACCOUNTADMIN)
-- ============================================

-- Prerequisito: Hai bisogno di una SendGrid API Key
-- Registrati su: https://sendgrid.com/

-- ============================================
-- Stored Procedure con SendGrid
-- ============================================

CREATE OR REPLACE PROCEDURE SEND_NOTE_EMAIL(
    table_name VARCHAR,
    username VARCHAR,
    note_text VARCHAR,
    timestamp VARCHAR
)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python', 'requests')
HANDLER = 'send_email_handler'
AS
$$
import requests
import json

def send_email_handler(session, table_name, username, note_text, timestamp):
    """
    Send email notification using SendGrid API
    """
    
    # IMPORTANT: Replace with your SendGrid API Key
    # For security, store this in Snowflake Secret or Parameter
    SENDGRID_API_KEY = 'YOUR_SENDGRID_API_KEY_HERE'
    
    # If you want to use Snowflake secrets (recommended):
    # try:
    #     api_key_query = "SELECT SYSTEM$GET_SECRET('sendgrid_api_key')"
    #     SENDGRID_API_KEY = session.sql(api_key_query).collect()[0][0]
    # except:
    #     return "Error: SendGrid API key not configured"
    
    try:
        recipient = 'cristian.gavazzeni@snowflake.com'
        sender = 'noreply@unipol.it'  # Change to your verified sender
        
        subject = f'Unipol - Nuova Nota su Tabella: {table_name}'
        
        html_body = f"""
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; }}
                .header {{ background-color: #003d7a; color: white; padding: 20px; }}
                .content {{ padding: 20px; }}
                .details {{ background-color: #f0f2f6; padding: 15px; margin: 20px 0; }}
                .footer {{ color: #666; font-size: 12px; margin-top: 30px; }}
            </style>
        </head>
        <body>
            <div class="header">
                <h2>Unipol Customer Management System</h2>
            </div>
            <div class="content">
                <h3>Nuova Nota Aggiunta</h3>
                <p>Una nuova nota è stata aggiunta alla tabella <strong>{table_name}</strong></p>
                
                <div class="details">
                    <p><strong>Tabella:</strong> {table_name}</p>
                    <p><strong>Utente:</strong> {username}</p>
                    <p><strong>Data/Ora:</strong> {timestamp}</p>
                </div>
                
                <h4>Contenuto Nota:</h4>
                <p>{note_text}</p>
                
                <div class="footer">
                    <p>Questa è una notifica automatica dal sistema Unipol Customer Management.</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        # SendGrid API endpoint
        url = 'https://api.sendgrid.com/v3/mail/send'
        
        # Request headers
        headers = {
            'Authorization': f'Bearer {SENDGRID_API_KEY}',
            'Content-Type': 'application/json'
        }
        
        # Email payload
        data = {
            'personalizations': [{
                'to': [{'email': recipient}],
                'subject': subject
            }],
            'from': {'email': sender},
            'content': [{
                'type': 'text/html',
                'value': html_body
            }]
        }
        
        # Send request
        response = requests.post(url, headers=headers, json=data)
        
        if response.status_code == 202:
            return f'Email sent successfully to {recipient}'
        else:
            return f'Email send failed: {response.status_code} - {response.text}'
            
    except Exception as e:
        return f'Error sending email: {str(e)}'
$$;

-- ============================================
-- Stored Procedure con SMTP generico
-- ============================================

CREATE OR REPLACE PROCEDURE SEND_NOTE_EMAIL_SMTP(
    table_name VARCHAR,
    username VARCHAR,
    note_text VARCHAR,
    timestamp VARCHAR
)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'send_email_smtp_handler'
AS
$$
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email_smtp_handler(session, table_name, username, note_text, timestamp):
    """
    Send email notification using SMTP
    """
    
    # SMTP Configuration - Replace with your SMTP settings
    SMTP_HOST = 'smtp.gmail.com'  # Or your SMTP server
    SMTP_PORT = 587
    SMTP_USER = 'your_email@gmail.com'
    SMTP_PASSWORD = 'your_app_password'
    
    try:
        recipient = 'cristian.gavazzeni@snowflake.com'
        sender = SMTP_USER
        
        subject = f'Unipol - Nuova Nota su Tabella: {table_name}'
        
        # Create message
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From'] = sender
        msg['To'] = recipient
        
        # HTML body
        html = f"""
        <html>
        <body>
            <h2 style="color: #003d7a;">Unipol Customer Management System</h2>
            <h3>Nuova Nota Aggiunta</h3>
            <p>Una nuova nota è stata aggiunta alla tabella <strong>{table_name}</strong></p>
            
            <div style="background-color: #f0f2f6; padding: 15px; margin: 20px 0;">
                <p><strong>Tabella:</strong> {table_name}</p>
                <p><strong>Utente:</strong> {username}</p>
                <p><strong>Data/Ora:</strong> {timestamp}</p>
            </div>
            
            <h4>Contenuto Nota:</h4>
            <p>{note_text}</p>
            
            <hr>
            <p style="color: #666; font-size: 12px;">
                Questa è una notifica automatica dal sistema Unipol Customer Management.
            </p>
        </body>
        </html>
        """
        
        part = MIMEText(html, 'html')
        msg.attach(part)
        
        # Send email
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
            server.starttls()
            server.login(SMTP_USER, SMTP_PASSWORD)
            server.send_message(msg)
        
        return f'Email sent successfully to {recipient}'
        
    except Exception as e:
        return f'Error sending email: {str(e)}'
$$;

-- ============================================
-- Grant Permissions
-- ============================================

GRANT USAGE ON PROCEDURE SEND_NOTE_EMAIL(VARCHAR, VARCHAR, VARCHAR, VARCHAR) 
  TO ROLE PUBLIC;

GRANT USAGE ON PROCEDURE SEND_NOTE_EMAIL_SMTP(VARCHAR, VARCHAR, VARCHAR, VARCHAR) 
  TO ROLE PUBLIC;

-- ============================================
-- Test (Uncomment to test)
-- ============================================

-- Test SendGrid version
-- CALL SEND_NOTE_EMAIL(
--     'CUSTOMERS',
--     'TEST_USER',
--     'This is a test note',
--     CURRENT_TIMESTAMP()::VARCHAR
-- );

-- ============================================
-- Setup Instructions
-- ============================================

/*
SETUP INSTRUCTIONS:

Option 1: SendGrid (Recommended)
---------------------------------
1. Create free account at https://sendgrid.com/
2. Generate API Key in SendGrid dashboard
3. Replace 'YOUR_SENDGRID_API_KEY_HERE' in the procedure above
4. Verify sender email in SendGrid
5. Update 'sender' email to your verified email

Option 2: SMTP (Gmail, Office365, etc.)
----------------------------------------
1. Get SMTP credentials from your email provider
2. For Gmail: Enable 2FA and create App Password
3. Update SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD
4. Run the SEND_NOTE_EMAIL_SMTP procedure

Option 3: Snowflake Email Integration (Requires ACCOUNTADMIN)
--------------------------------------------------------------
1. Ask your Snowflake admin to create email integration
2. Use SYSTEM$SEND_EMAIL function
3. See setup_email_notification.sql for details

*/

