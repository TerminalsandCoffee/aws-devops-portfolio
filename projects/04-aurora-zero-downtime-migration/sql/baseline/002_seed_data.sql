-- Seed data for RDS MySQL source instance
-- This data will be replicated to Aurora during migration
USE devops_raf_demo;

-- Insert sample student records
INSERT INTO students (name, grade_level) VALUES
    ('Alice Johnson', 9),
    ('Bob Smith', 10),
    ('Charlie Brown', 11),
    ('Diana Prince', 12),
    ('Ethan Hunt', 9),
    ('Fiona Chen', 10),
    ('George Washington', 11),
    ('Hannah Montana', 12),
    ('Isaac Newton', 9),
    ('Julia Roberts', 10),
    ('Kevin Hart', 11),
    ('Luna Lovegood', 12),
    ('Michael Jordan', 9),
    ('Nina Simone', 10),
    ('Oscar Wilde', 11);

-- Verify data insertion
SELECT COUNT(*) as total_students FROM students;
SELECT * FROM students ORDER BY id LIMIT 5;

