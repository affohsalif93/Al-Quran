-- Initialize userDataDb for storing user-generated content
-- This file creates the database structure for ayah notes

-- Create the database (SQLite will create it when first accessed)
-- Database name: user_data.db

-- Create ayah_notes table
CREATE TABLE IF NOT EXISTS ayah_notes (
    id TEXT PRIMARY KEY,
    content TEXT NOT NULL,
    surah INTEGER NOT NULL,
    ayah INTEGER NOT NULL,
    created_at TEXT NOT NULL, -- ISO 8601 datetime string
    updated_at TEXT NOT NULL, -- ISO 8601 datetime string
    is_deleted INTEGER NOT NULL DEFAULT 0 CHECK (is_deleted IN (0, 1)), -- Soft delete flag
    deleted_at TEXT -- ISO 8601 datetime string, NULL if not deleted
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_ayah_notes_surah_ayah ON ayah_notes(surah, ayah);
CREATE INDEX IF NOT EXISTS idx_ayah_notes_is_deleted ON ayah_notes(is_deleted);
CREATE INDEX IF NOT EXISTS idx_ayah_notes_created_at ON ayah_notes(created_at);
CREATE INDEX IF NOT EXISTS idx_ayah_notes_updated_at ON ayah_notes(updated_at);

-- Create a composite index for common queries (active notes by ayah)
CREATE INDEX IF NOT EXISTS idx_ayah_notes_active ON ayah_notes(is_deleted, surah, ayah);

-- Example data (commented out - these would be inserted via the app)
/*
-- Example note for Surah Al-Fatiha, Ayah 1
INSERT INTO ayah_notes (
    id, 
    content, 
    surah,
    ayah,
    created_at, 
    updated_at, 
    is_deleted
) VALUES (
    '1_1_001', 
    'This is the opening of the Quran, a beautiful beginning.',
    1,
    1,
    datetime('now'),
    datetime('now'),
    0
);
*/

-- View to get all active (non-deleted) notes
CREATE VIEW IF NOT EXISTS active_notes AS
SELECT * FROM ayah_notes 
WHERE is_deleted = 0;