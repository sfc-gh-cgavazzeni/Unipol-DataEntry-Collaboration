# 📝 Funzionalità Note a Livello Tabella

## Nuova Funzionalità Aggiunta

È stata aggiunta la possibilità di **inserire note a livello di tabella** per documentare informazioni importanti, cambiamenti, o annotazioni generali.

---

## 🗄️ Setup Database - IMPORTANTE!

Prima di usare l'applicazione, devi creare la tabella per le note:

### Esegui questo comando:

```bash
cd /Users/cgavazenni/unipolstreamlit
snow sql --database INSURANCE_DB --schema CUSTOMER_MGMT -f add_notes_table.sql
```

Oppure esegui manualmente in Snowflake:

```sql
CREATE TABLE IF NOT EXISTS TABLE_NOTES (
    NOTE_ID NUMBER AUTOINCREMENT PRIMARY KEY,
    TABLE_NAME VARCHAR(100),
    NOTE_TEXT TEXT,
    CREATED_BY VARCHAR(100),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```

---

## 🎯 Come Funziona

### 1. **Pulsante "Note"**

Posizionato accanto al titolo "Anagrafica Clienti":

```
📋 Anagrafica Clienti        [📝 Note]
```

### 2. **Form di Inserimento**

Cliccando su "Note" si apre un form espandibile:

```
✍️ Inserisci Nota
┌─────────────────────────────────────────┐
│ Testo della nota:                       │
│ ┌─────────────────────────────────────┐ │
│ │ Inserisci qui la nota...            │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [💾 Salva Nota]  [❌ Annulla]           │
└─────────────────────────────────────────┘
```

### 3. **Visualizzazione Ultima Nota**

In fondo alla pagina, prima del footer:

```
───────────────────────────────────────

📌 Ultima Nota

💬 Aggiornati i dati dei clienti con le nuove polizze 2025

👤 CGAVAZZENI
🕒 2025-11-20 15:30:45
```

---

## ✨ Caratteristiche

### Salvataggio Automatico
- ✅ **Nome utente** catturato automaticamente (Snowflake user)
- ✅ **Timestamp** generato automaticamente
- ✅ **Tabella di riferimento** salvata (CUSTOMERS, CUSTOMER_AUDIT_LOG, etc.)
- ✅ **Testo nota** inserito dall'utente

### Validazione
- ⚠️ Campo nota obbligatorio (non può essere vuoto)
- ⚠️ Conferma di successo/errore dopo salvataggio

### Visualizzazione
- 📌 Solo l'**ultima nota** mostrata in fondo pagina
- 👤 Mostra **chi** ha inserito la nota
- 🕒 Mostra **quando** è stata inserita
- 💬 Mostra il **testo completo** della nota

---

## 📊 Schema Tabella TABLE_NOTES

| Colonna | Tipo | Descrizione |
|---------|------|-------------|
| **NOTE_ID** | NUMBER | Primary Key, auto-increment |
| **TABLE_NAME** | VARCHAR(100) | Nome della tabella di riferimento |
| **NOTE_TEXT** | TEXT | Testo della nota |
| **CREATED_BY** | VARCHAR(100) | Utente Snowflake che ha creato la nota |
| **CREATED_AT** | TIMESTAMP_NTZ | Data/ora di creazione (auto) |

---

## 🎨 Design e Styling

### Pulsante "Note"
- **Posizione**: Destra dell'header, allineato con il titolo
- **Icona**: 📝
- **Colore**: Unipol Blue
- **Tooltip**: "Aggiungi nota alla tabella"

### Form Inserimento
- **Expander** espandibile
- **Text area** multi-linea (100px altezza)
- **Bottoni**:
  - Salva: Rosso Unipol (primary)
  - Annulla: Grigio (secondary)

### Box Ultima Nota
- **Header**: "📌 Ultima Nota" in Unipol Blue
- **Layout**: Due colonne
  - Sinistra: Testo nota (info box)
  - Destra: Utente e timestamp
- **Stile**: Info box con icona 💬

---

## 💡 Casi d'Uso

### 1. **Annotazioni Importanti**
```
💬 Attenzione: domani manutenzione programmata dalle 14:00 alle 16:00
```

### 2. **Modifiche di Massa**
```
💬 Aggiornati premi assicurativi per tutte le polizze Auto (+5%)
```

### 3. **Comunicazioni Team**
```
💬 Nuova procedura: verificare sempre il documento identità prima di modifiche
```

### 4. **Promemoria**
```
💬 Da completare: inserimento nuovi clienti dalla campagna marketing Q4
```

### 5. **Documentazione Modifiche**
```
💬 Corretti 5 record con policy number errato - vedi audit log per dettagli
```

---

## 🔧 Funzioni Aggiunte al Codice

### 1. `save_table_note(table_name, note_text, user)`
Salva una nota nel database.

**Parametri:**
- `table_name`: Nome della tabella
- `note_text`: Testo della nota
- `user`: Utente corrente

**Ritorna:** `(success: bool, message: str)`

### 2. `get_latest_note(table_name)`
Recupera l'ultima nota per una tabella.

**Parametri:**
- `table_name`: Nome della tabella

**Ritorna:** `dict` con NOTE_ID, NOTE_TEXT, CREATED_BY, CREATED_AT oppure `None`

---

## 🎯 Workflow Utente

```
1. Utente clicca "📝 Note"
   ↓
2. Si apre form con text area
   ↓
3. Utente scrive la nota
   ↓
4. Clicca "💾 Salva Nota"
   ↓
5. Nota salvata in TABLE_NOTES con:
   - TABLE_NAME = "CUSTOMERS"
   - NOTE_TEXT = testo inserito
   - CREATED_BY = utente Snowflake corrente
   - CREATED_AT = timestamp corrente
   ↓
6. Form si chiude
   ↓
7. Nota appare in fondo pagina
```

---

## 📝 Query SQL Utilizzate

### Inserimento Nota
```sql
INSERT INTO TABLE_NOTES (TABLE_NAME, NOTE_TEXT, CREATED_BY)
VALUES ('CUSTOMERS', 'Testo della nota', 'CGAVAZZENI')
```

### Recupero Ultima Nota
```sql
SELECT 
    NOTE_ID,
    NOTE_TEXT,
    CREATED_BY,
    CREATED_AT
FROM TABLE_NOTES
WHERE TABLE_NAME = 'CUSTOMERS'
ORDER BY CREATED_AT DESC
LIMIT 1
```

---

## 🔒 Sicurezza

- ✅ **SQL Injection Protection**: Valori escaped con `replace("'", "''")`
- ✅ **User Tracking**: Usa CURRENT_USER() di Snowflake
- ✅ **Timestamp Immutabile**: Generato da database
- ✅ **Audit Trail**: Tutte le note salvate permanentemente

---

## 🚀 Estensioni Future Possibili

### Storico Note Complete
Visualizzare non solo l'ultima ma tutte le note con paginazione

### Note per Singolo Cliente
Aggiungere note specifiche per customer_id

### Filtri Note
Filtrare note per utente o data

### Notifiche
Alert quando una nuova nota viene inserita

### Categorie Note
Tag o categorie (Urgente, Info, Manutenzione, etc.)

### Modifica/Cancellazione
Permettere di modificare o eliminare note proprie

---

## ✅ Status

- ✅ **Tabella TABLE_NOTES** da creare (vedi add_notes_table.sql)
- ✅ **Funzioni** aggiunte al codice
- ✅ **UI** implementata con pulsante e form
- ✅ **Visualizzazione** ultima nota in fondo pagina
- ✅ **Styling Unipol** applicato
- ⏸️ **Non deployato** ancora

---

## 🚀 Per Usare la Funzionalità

### Step 1: Crea la Tabella
```bash
cd /Users/cgavazenni/unipolstreamlit
snow sql --database INSURANCE_DB --schema CUSTOMER_MGMT -f add_notes_table.sql
```

### Step 2: Deploy l'App (quando pronto)
```bash
./quick_deploy.sh
```

### Step 3: Usa le Note
1. Apri l'app
2. Clicca "📝 Note"
3. Scrivi la nota
4. Salva
5. Vedi la nota in fondo pagina

---

## 📁 File Coinvolti

- ✅ `streamlit_app.py` - Codice modificato
- ✅ `add_notes_table.sql` - Script creazione tabella
- ✅ `NOTE_TABELLA.md` - Questa documentazione

---

## 🎉 Risultato

Gli utenti possono ora:
- 📝 **Aggiungere note** contestuali alla tabella
- 💬 **Comunicare** informazioni importanti al team
- 📌 **Visualizzare** l'ultima nota inserita
- 👥 **Tracciare** chi ha scritto cosa e quando
- 📚 **Documentare** modifiche e decisioni

**Funzionalità di comunicazione team pronta!** 🎯

