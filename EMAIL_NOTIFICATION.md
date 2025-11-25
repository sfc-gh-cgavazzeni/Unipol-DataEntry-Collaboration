# 📧 Email Notification per Note Tabella

## Funzionalità Aggiunta

Quando un utente salva una nota a livello di tabella, viene **automaticamente inviata un'email** a `cristian.gavazzeni@snowflake.com` con:
- ✅ Nome della tabella
- ✅ Nome utente
- ✅ Timestamp
- ✅ Contenuto della nota

---

## 🎯 Come Funziona

### Workflow

```
1. Utente clicca "📝 Note"
   ↓
2. Scrive la nota
   ↓
3. Clicca "💾 Salva Nota"
   ↓
4. Nota salvata in TABLE_NOTES
   ↓
5. ✉️ EMAIL INVIATA automaticamente
   ↓
6. Email arriva a cristian.gavazzeni@snowflake.com
```

---

## 📧 Contenuto Email

### Subject
```
Unipol - Nuova Nota su Tabella: CUSTOMERS
```

### Body (HTML)
```
┌─────────────────────────────────────────┐
│ Unipol Customer Management System       │
├─────────────────────────────────────────┤
│                                         │
│ Nuova Nota Aggiunta                     │
│                                         │
│ Una nuova nota è stata aggiunta         │
│ alla tabella CUSTOMERS                  │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Tabella: CUSTOMERS                  │ │
│ │ Utente: CGAVAZZENI                  │ │
│ │ Data/Ora: 2025-11-25 16:30:00       │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Contenuto Nota:                         │
│ Aggiornati i dati dei clienti...       │
│                                         │
│ ─────────────────────────────────────  │
│ Notifica automatica dal sistema        │
└─────────────────────────────────────────┘
```

---

## 🛠️ Setup Richiesto

### ⚠️ IMPORTANTE: Scegli UNA delle 3 opzioni

---

### **Opzione 1: SendGrid** (⭐ CONSIGLIATA - Più Semplice)

#### Vantaggi
- ✅ Gratuita (100 email/giorno)
- ✅ Non richiede ACCOUNTADMIN
- ✅ Setup veloce (10 minuti)
- ✅ API moderna e affidabile

#### Setup

**Step 1:** Crea account SendGrid
```
1. Vai su https://sendgrid.com/
2. Registrati (account gratuito)
3. Verifica email
```

**Step 2:** Genera API Key
```
1. Dashboard → Settings → API Keys
2. Create API Key
3. Copia la chiave (formato: SG.xxxx...)
```

**Step 3:** Verifica Sender Email
```
1. Settings → Sender Authentication
2. Single Sender Verification
3. Aggiungi noreply@unipol.it (o il tuo dominio)
4. Verifica via email
```

**Step 4:** Configura in Snowflake
```sql
-- Esegui il file setup_email_sendgrid.sql
-- ma PRIMA modifica:

SENDGRID_API_KEY = 'SG.your_actual_api_key_here'
sender = 'noreply@unipol.it'  -- Tua email verificata
```

**Step 5:** Esegui setup
```bash
cd /Users/cgavazenni/unipolstreamlit
snow sql --database INSURANCE_DB --schema CUSTOMER_MGMT \
  -f setup_email_sendgrid.sql
```

**Step 6:** Testa
```sql
CALL SEND_NOTE_EMAIL(
    'CUSTOMERS',
    'TEST_USER',
    'Test email notification',
    CURRENT_TIMESTAMP()::VARCHAR
);
```

---

### **Opzione 2: SMTP (Gmail, Office365)**

#### Vantaggi
- ✅ Usi email aziendale esistente
- ✅ Non richiede ACCOUNTADMIN
- ✅ Controllo completo

#### Setup per Gmail

**Step 1:** Abilita 2FA su Gmail
```
1. Google Account → Security
2. Enable 2-Step Verification
```

**Step 2:** Crea App Password
```
1. Google Account → Security → App passwords
2. Select app: Mail
3. Select device: Other (Snowflake)
4. Generate
5. Copia password (16 caratteri)
```

**Step 3:** Configura in Snowflake
```sql
-- Nel file setup_email_sendgrid.sql, modifica SEND_NOTE_EMAIL_SMTP:

SMTP_HOST = 'smtp.gmail.com'
SMTP_PORT = 587
SMTP_USER = 'tua_email@gmail.com'
SMTP_PASSWORD = 'app_password_16_char'
```

**Step 4:** Esegui e testa
```sql
-- Esegui setup
\!cd /Users/cgavazenni/unipolstreamlit
\!snow sql -f setup_email_sendgrid.sql

-- Testa
CALL SEND_NOTE_EMAIL_SMTP(
    'CUSTOMERS',
    'TEST_USER',
    'Test SMTP notification',
    CURRENT_TIMESTAMP()::VARCHAR
);
```

---

### **Opzione 3: Snowflake Email Integration**

#### Vantaggi
- ✅ Nativo Snowflake
- ✅ Enterprise-grade

#### Svantaggi
- ❌ Richiede ACCOUNTADMIN
- ❌ Setup più complesso

#### Setup (richiede ACCOUNTADMIN)

```sql
-- Run as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Create email integration
CREATE NOTIFICATION INTEGRATION email_int
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('cristian.gavazzeni@snowflake.com');

-- Grant usage
GRANT USAGE ON INTEGRATION email_int TO ROLE <your_role>;

-- Then use SYSTEM$SEND_EMAIL in the stored procedure
```

Vedi `setup_email_notification.sql` per dettagli completi.

---

## 📁 File Modificati/Creati

### Nuovi File
- ✅ `setup_email_notification.sql` - Setup opzione Snowflake
- ✅ `setup_email_sendgrid.sql` - Setup SendGrid e SMTP
- ✅ `EMAIL_NOTIFICATION.md` - Questa documentazione

### File Modificati
- ✅ `streamlit_app.py` - Aggiunta funzione `send_note_email_notification()`

---

## 🔧 Codice Aggiunto

### In streamlit_app.py

```python
def save_table_note(table_name, note_text, user):
    """Save a note for a table and send email notification"""
    try:
        # ... save note logic ...
        
        # Get timestamp
        timestamp = session.sql("SELECT CURRENT_TIMESTAMP()::VARCHAR").collect()[0][0]
        
        # Send email notification
        try:
            send_note_email_notification(table_name, user, note_text, timestamp)
        except Exception as email_error:
            # Don't fail if email fails
            print(f"Email notification failed: {str(email_error)}")
        
        return True, "Nota salvata con successo"
    except Exception as e:
        return False, f"Errore nel salvare la nota: {str(e)}"

def send_note_email_notification(table_name, username, note_text, timestamp):
    """Send email notification when a note is saved"""
    try:
        # Call Snowflake stored procedure
        email_query = f"""
        CALL SEND_NOTE_EMAIL(
            '{escaped_table}',
            '{escaped_user}',
            '{escaped_note}',
            '{escaped_timestamp}'
        )
        """
        result = session.sql(email_query).collect()
        return True
    except Exception as e:
        print(f"Failed to send email: {str(e)}")
        return False
```

---

## ✅ Checklist Setup

### Prima di usare la funzionalità:

- [ ] **Scegli metodo email** (SendGrid, SMTP, o Snowflake)
- [ ] **Configura credenziali** nel file SQL appropriato
- [ ] **Esegui setup SQL** per creare stored procedure
- [ ] **Testa invio email** con CALL SEND_NOTE_EMAIL(...)
- [ ] **Verifica ricezione** su cristian.gavazzeni@snowflake.com
- [ ] **Deploy app** (quando tutto funziona)

---

## 🧪 Test

### Test Manuale

```sql
-- Test la stored procedure direttamente
CALL SEND_NOTE_EMAIL(
    'CUSTOMERS',
    'TEST_USER',
    'Questa è una nota di test',
    '2025-11-25 16:00:00'
);

-- Verifica che l'email sia arrivata
```

### Test nell'App

```
1. Apri app Streamlit
2. Clicca "📝 Note"
3. Scrivi una nota di test
4. Clicca "💾 Salva Nota"
5. Controlla email su cristian.gavazzeni@snowflake.com
```

---

## 🔍 Troubleshooting

### Email non arriva

**1. Verifica stored procedure esiste**
```sql
SHOW PROCEDURES LIKE 'SEND_NOTE_EMAIL';
```

**2. Testa direttamente la procedure**
```sql
CALL SEND_NOTE_EMAIL('TEST', 'USER', 'Note', '2025-11-25');
```

**3. Controlla log**
```sql
-- Vedi l'output della procedure per errori
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME = 'SEND_NOTE_EMAIL'
ORDER BY SCHEDULED_TIME DESC
LIMIT 10;
```

### SendGrid: Error 401

- ❌ API Key non valida
- ✅ Rigenera API key e aggiorna procedura

### SendGrid: Error 403

- ❌ Sender email non verificato
- ✅ Verifica sender in SendGrid dashboard

### SMTP: Authentication failed

- ❌ Password sbagliata o 2FA non abilitato
- ✅ Usa App Password, non password normale

---

## 💰 Costi

| Metodo | Costo |
|--------|-------|
| **SendGrid Free** | $0 (fino a 100 email/giorno) |
| **SendGrid Essentials** | $19.95/mese (100k email/mese) |
| **SMTP Gmail** | $0 (limite: 500 email/giorno) |
| **SMTP Office365** | Incluso con licenza |
| **Snowflake Email** | Incluso (nessun costo extra) |

---

## 🔒 Sicurezza

### Best Practices

✅ **NON hardcodare API keys nel codice**
- Usa Snowflake Secrets (raccomandato)
- O variabili di ambiente

```sql
-- Store API key in Snowflake Secret
CREATE SECRET sendgrid_api_key
  TYPE = GENERIC_STRING
  SECRET_STRING = 'SG.your_key_here';

-- Use in procedure
SELECT SYSTEM$GET_SECRET('sendgrid_api_key');
```

✅ **Limita recipients**
- Solo cristian.gavazzeni@snowflake.com

✅ **Rate limiting**
- SendGrid free: 100/day
- Gmail: 500/day

---

## 📊 Statistiche (Future Enhancement)

Possibile aggiungere tracking:
- Numero email inviate
- Success rate
- Failure log
- Delivery confirmation

```sql
-- Tabella per tracking (opzionale)
CREATE TABLE EMAIL_LOG (
    EMAIL_ID NUMBER AUTOINCREMENT,
    SENT_AT TIMESTAMP_NTZ,
    RECIPIENT VARCHAR,
    SUBJECT VARCHAR,
    STATUS VARCHAR, -- 'sent', 'failed'
    ERROR_MESSAGE VARCHAR
);
```

---

## 🎉 Risultato

Quando tutto è configurato:

```
Utente salva nota → 📧 Email parte automaticamente → ✅ Arriva in pochi secondi
```

**Email professionale con:**
- 🎨 Styling Unipol
- 📋 Tutti i dettagli
- 🔔 Notifica in tempo reale

---

## 🚀 Status

- ✅ Codice implementato in `streamlit_app.py`
- ✅ Stored procedures create (3 opzioni)
- ✅ Documentazione completa
- ⏸️ **Setup credenziali email richiesto**
- ⏸️ **Test email da fare**
- ⏸️ **App NON deployata**

---

## 📝 Next Steps

1. **Scegli metodo** (SendGrid raccomandato)
2. **Configura credenziali** nel file SQL
3. **Esegui setup** in Snowflake
4. **Testa** con CALL
5. **Verifica ricezione** email
6. **Deploy app** quando pronto

---

**Funzionalità email notification pronta! Serve solo configurare il servizio email.** 📧✅

