# ⚡ Quick Email Setup - 5 Minuti

## Setup Veloce con SendGrid (RACCOMANDATO)

---

## 📋 Prerequisiti

- Account SendGrid (gratuito)
- 5 minuti di tempo
- Accesso a Snowflake

---

## 🚀 Setup in 5 Step

### Step 1: Crea Account SendGrid (2 minuti)

```
1. Vai su: https://sendgrid.com/
2. Click "Start for Free"
3. Compila form registrazione
4. Verifica email
```

### Step 2: Genera API Key (1 minuto)

```
1. Login SendGrid
2. Settings → API Keys
3. "Create API Key"
4. Nome: "Unipol_Snowflake"
5. Full Access
6. Create & View
7. COPIA la chiave (inizia con SG....)
```

⚠️ **IMPORTANTE:** Salva subito la chiave, non la vedrai più!

### Step 3: Verifica Sender (1 minuto)

```
1. Settings → Sender Authentication
2. Single Sender Verification
3. From Email: noreply@unipol.it (o tua email)
4. From Name: Unipol System
5. Verify
6. Controlla inbox e clicca link verifica
```

### Step 4: Configura Snowflake (1 minuto)

Apri il file `setup_email_sendgrid.sql` e modifica:

```sql
-- Linea ~45, sostituisci:
SENDGRID_API_KEY = 'SG.your_actual_key_here'  # ← Incolla tua API key

-- Linea ~55, sostituisci:
sender = 'noreply@unipol.it'  # ← Tua email verificata
```

Poi esegui:

```bash
cd /Users/cgavazenni/unipolstreamlit
snow sql --database INSURANCE_DB --schema CUSTOMER_MGMT \
  -f setup_email_sendgrid.sql
```

### Step 5: Test! (30 secondi)

```sql
-- Testa l'invio email
CALL SEND_NOTE_EMAIL(
    'CUSTOMERS',
    'TEST_USER',
    'Test email notification - funziona!',
    CURRENT_TIMESTAMP()::VARCHAR
);
```

Controlla inbox di `cristian.gavazzeni@snowflake.com` 📧

---

## ✅ Fatto!

Se vedi l'email arrivare, sei pronto! 🎉

---

## 📧 Deploy App

Quando tutto funziona:

```bash
cd /Users/cgavazenni/unipolstreamlit
./quick_deploy.sh
```

Ora ogni volta che salvi una nota, parte l'email automaticamente!

---

## 🔧 Troubleshooting Rapido

### "Error 401"
- API Key sbagliata
- Rigenerane una nuova in SendGrid

### "Error 403"  
- Sender email non verificato
- Verifica email in SendGrid Settings

### "Procedure not found"
- Setup SQL non eseguito
- Riesegui setup_email_sendgrid.sql

---

## 📞 Alternative Rapide

### Opzione Gmail (se hai Gmail)

1. Abilita 2FA su Google Account
2. Crea App Password: https://myaccount.google.com/apppasswords
3. Usa `SEND_NOTE_EMAIL_SMTP` invece
4. Configura con:
   ```
   SMTP_HOST = 'smtp.gmail.com'
   SMTP_PORT = 587
   SMTP_USER = 'tua_email@gmail.com'
   SMTP_PASSWORD = 'app_password_qui'
   ```

---

## 💡 Pro Tip

Per non hardcodare API key nel codice, usa Snowflake Secrets:

```sql
-- Crea secret
CREATE SECRET sendgrid_key
  TYPE = GENERIC_STRING
  SECRET_STRING = 'SG.your_key';

-- Usa nella procedure
SELECT SYSTEM$GET_SECRET('sendgrid_key');
```

---

**Setup completo in 5 minuti!** ⚡📧

