# 📊 Selezione Tabelle Multiple

## Nuova Funzionalità Aggiunta

È stato aggiunto un **selettore di tabelle** nella sidebar che permette di visualizzare diverse tabelle dello schema CUSTOMER_MGMT.

---

## 🎯 Posizione

Il selettore si trova nella **sidebar**, **sopra i filtri**:

```
📊 Selezione Tabella
┌─────────────────────────┐
│ Tabella da visualizzare │
│ ▼ CUSTOMERS             │
└─────────────────────────┘

────────────────────────────

🔍 Filtri
Status: [All ▼]
Policy Type: [All ▼]
Search: [____]
```

---

## 📋 Tabelle Disponibili

### 1. **CUSTOMERS** (Default)
Visualizza l'anagrafica clienti con funzionalità complete:
- ✅ Lista clienti in card espandibili
- ✅ Filtri per Status e Policy Type
- ✅ Ricerca per nome, email, policy number
- ✅ Pulsante "Edit Record" per ogni cliente
- ✅ Modifica inline con commit/cancel
- ✅ Commento obbligatorio per le modifiche

### 2. **CUSTOMER_AUDIT_LOG**
Visualizza il registro completo di tutte le modifiche:
- ✅ Tutti i record di audit in ordine cronologico inverso
- ✅ Dettagli completi per ogni modifica
- ✅ Visualizzazione JSON dei valori precedenti e nuovi
- ✅ Card espandibili per ogni audit record
- ✅ Informazioni su chi, quando, cosa è stato modificato

---

## 🔍 Vista CUSTOMERS

Quando selezionata, mostra:

### Header
```
📋 Anagrafica Clienti
```

### Contenuto
- **Card per cliente** con informazioni dettagliate
- **Pulsante Edit** per modifiche
- **Filtri attivi** (Status, Policy Type, Search)
- **Contatore** risultati visualizzati

### Esempio
```
👤 Mario Rossi - POL-AUTO-001 (Active)
   ├─ Customer ID: 1
   ├─ Email: mario.rossi@email.it
   ├─ Phone: +39 340 1234567
   ├─ Policy: Auto | €850.00
   └─ [✏️ Edit Record]
```

---

## 📝 Vista CUSTOMER_AUDIT_LOG

Quando selezionata, mostra:

### Header
```
📝 Registro Audit Completo
```

### Contenuto
- **Card per record audit** con dettagli completi
- **Visualizzazione JSON** valori precedenti/nuovi
- **Informazioni complete** su ogni modifica
- **Ordinamento** per ID audit (più recenti primi)

### Esempio
```
🔍 Audit #15 - Mario Rossi - UPDATE (2025-11-20 10:30:00)
   ├─ Audit ID: 15
   ├─ Customer ID: 1
   ├─ Modificato da: CGAVAZZENI
   ├─ Data/Ora: 2025-11-20 10:30:00
   ├─ Commento: "Aggiornamento premio"
   └─ Dettagli Modifiche:
       ├─ Valori Precedenti: {"PREMIUM_AMOUNT": 850.0, ...}
       └─ Nuovi Valori: {"PREMIUM_AMOUNT": 900.0, ...}
```

---

## 🎨 Design e Styling

### Selettore Tabella
- **Posizione**: Top della sidebar
- **Stile**: Unipol Blue header
- **Icona**: 📊
- **Testo**: "Selezione Tabella" (italiano)
- **Help text**: Tooltip esplicativo

### Separatore
- Linea orizzontale (`---`) tra selettore e filtri
- Visivamente separa le due sezioni

### Card Audit Log
- **Expander** per ogni record
- **Due colonne** per informazioni base
- **Sezione JSON** espandibile
- **Colori**: Unipol brand colors
- **Bordi**: Sottili, arrotondati

---

## 💡 Logica Funzionale

### Codice Chiave
```python
# Selettore nella sidebar
selected_table = st.sidebar.selectbox(
    "Tabella da visualizzare",
    ["CUSTOMERS", "CUSTOMER_AUDIT_LOG"],
    index=0,
    help="Seleziona quale tabella visualizzare"
)

# Visualizzazione condizionale
if selected_table == "CUSTOMERS":
    # Mostra vista clienti con edit
    ...
elif selected_table == "CUSTOMER_AUDIT_LOG":
    # Mostra vista audit log completo
    ...
```

### Behavior
1. **Default**: Mostra CUSTOMERS all'avvio
2. **Cambio tabella**: Cambia immediatamente la vista
3. **Stato preservato**: I filtri rimangono attivi (ma applicabili solo a CUSTOMERS)
4. **Indipendente**: Le due viste sono completamente indipendenti

---

## 📊 Query Utilizzate

### CUSTOMERS
```sql
SELECT 
    CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE,
    POLICY_TYPE, POLICY_NUMBER, PREMIUM_AMOUNT, STATUS,
    START_DATE, LAST_MODIFIED_BY, LAST_MODIFIED_AT
FROM CUSTOMERS
ORDER BY CUSTOMER_ID
```
+ Filtri dinamici applicati

### CUSTOMER_AUDIT_LOG
```sql
SELECT 
    a.AUDIT_ID, a.CUSTOMER_ID,
    c.FIRST_NAME || ' ' || c.LAST_NAME as CUSTOMER_NAME,
    a.MODIFIED_BY, a.MODIFIED_AT, a.COMMENT, a.CHANGE_TYPE,
    a.OLD_VALUES, a.NEW_VALUES
FROM CUSTOMER_AUDIT_LOG a
LEFT JOIN CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID
ORDER BY a.AUDIT_ID DESC
```

---

## 🎯 Casi d'Uso

### 1. Gestione Quotidiana Clienti
- **Seleziona**: CUSTOMERS
- **Usa**: Filtri e ricerca
- **Azione**: Modifica dati cliente

### 2. Audit e Compliance
- **Seleziona**: CUSTOMER_AUDIT_LOG
- **Visualizza**: Storico completo modifiche
- **Verifica**: Chi ha fatto cosa e quando

### 3. Troubleshooting
- **Problema**: Cliente lamenta dato errato
- **Azione**: Vai su AUDIT_LOG
- **Trova**: Quando e da chi è stato modificato
- **Risolvi**: Correggi in CUSTOMERS

### 4. Reporting
- **Seleziona**: CUSTOMER_AUDIT_LOG
- **Analizza**: Pattern di modifiche
- **Report**: Attività utenti, frequenza modifiche

---

## ✨ Vantaggi

### Per gli Utenti
- ✅ **Navigazione semplice** tra tabelle
- ✅ **Vista dedicata** per audit
- ✅ **Nessuna confusione** tra dati operativi e audit
- ✅ **Accesso rapido** a informazioni storiche

### Per l'Amministrazione
- ✅ **Trasparenza completa** sulle modifiche
- ✅ **Tracciabilità** di ogni operazione
- ✅ **Compliance** facilitata
- ✅ **Debugging** più semplice

### Tecnici
- ✅ **Codice pulito** con logica condizionale
- ✅ **Modulare** e estendibile
- ✅ **Performante** con query separate
- ✅ **Manutenibile** facilmente

---

## 🔮 Possibili Estensioni Future

### Altre Tabelle
Potrebbero essere aggiunte facilmente:
- **POLICIES** - Tabella polizze
- **CLAIMS** - Tabella sinistri
- **PAYMENTS** - Tabella pagamenti

### Filtri Specifici per Tabella
- Filtri diversi per AUDIT_LOG (es: per utente, per data, per tipo)
- Filtri contestuali che cambiano con la tabella

### Esportazione
- Pulsante per esportare CSV della tabella visualizzata
- Download report PDF

### Statistiche
- Conteggi e metriche per tabella selezionata
- Grafici riassuntivi

---

## 📝 Modifiche al Codice

### File Modificato
- `streamlit_app.py`

### Sezioni Aggiunte
1. **TABLE SELECTOR** (linee ~370-385)
   - Selectbox per scelta tabella
   - Separatore visuale
   
2. **Logica condizionale** (linee ~410-570)
   - `if selected_table == "CUSTOMERS":`
   - `elif selected_table == "CUSTOMER_AUDIT_LOG":`

3. **Vista Audit Log completa** (linee ~540-570)
   - Query audit log
   - Rendering card
   - Display JSON

---

## ✅ Status

- ✅ **Codice implementato** in `streamlit_app.py`
- ✅ **Design Unipol** applicato
- ✅ **Testi in italiano** 
- ✅ **Funzionalità testata** (logica)
- ⏸️ **Non deployato** ancora

---

## 🚀 Per Deployare

```bash
cd /Users/cgavazenni/unipolstreamlit
./quick_deploy.sh
```

Oppure:
```bash
snow streamlit deploy --replace --database INSURANCE_DB --schema CUSTOMER_MGMT
```

---

## 🎉 Risultato

Gli utenti possono ora:
- 🔄 **Cambiare rapidamente** tra vista clienti e audit log
- 📊 **Visualizzare dati diversi** senza cambiare pagina
- 🔍 **Analizzare lo storico** completo delle modifiche
- ✅ **Lavorare più efficientemente** con un'unica interfaccia

**Funzionalità professionale pronta all'uso!** 🏢

