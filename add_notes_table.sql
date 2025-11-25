-- ============================================
-- Tabella per Note a livello di tabella
-- ============================================

CREATE TABLE IF NOT EXISTS TABLE_NOTES (
    NOTE_ID NUMBER AUTOINCREMENT PRIMARY KEY,
    TABLE_NAME VARCHAR(100),
    NOTE_TEXT TEXT,
    CREATED_BY VARCHAR(100),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Verifica
SELECT * FROM TABLE_NOTES ORDER BY CREATED_AT DESC LIMIT 5;

