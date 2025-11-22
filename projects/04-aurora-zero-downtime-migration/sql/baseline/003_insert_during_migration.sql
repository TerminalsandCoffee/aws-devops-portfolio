-- Insert data during migration to demonstrate CDC replication
-- Run this AFTER DMS replication has started to show real-time sync
USE devops_raf_demo;

-- Insert additional records while replication is active
-- These should appear in Aurora within seconds (CDC replication)
INSERT INTO students (name, grade_level) VALUES
    ('Penelope Cruz', 9),
    ('Quentin Tarantino', 10),
    ('Rachel Green', 11),
    ('Steve Jobs', 12),
    ('Taylor Swift', 9);

-- Update existing records to test UPDATE replication
UPDATE students 
SET grade_level = grade_level + 1 
WHERE id IN (1, 2, 3);

-- Delete a record to test DELETE replication
DELETE FROM students WHERE id = 5;

-- Verify changes
SELECT 
    COUNT(*) as total_students,
    COUNT(CASE WHEN grade_level = 9 THEN 1 END) as grade_9,
    COUNT(CASE WHEN grade_level = 10 THEN 1 END) as grade_10,
    COUNT(CASE WHEN grade_level = 11 THEN 1 END) as grade_11,
    COUNT(CASE WHEN grade_level = 12 THEN 1 END) as grade_12
FROM students;

