-- Example migration that can be replayed during/after the Aurora cutover
ALTER TABLE students
ADD COLUMN last_login_at TIMESTAMP NULL;