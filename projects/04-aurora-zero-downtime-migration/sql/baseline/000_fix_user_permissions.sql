-- Fix user permissions to allow connections from any host
-- Run this FIRST if you get "Access denied" errors
-- This grants the admin user permission to connect from any host (%)

-- For RDS, the master user should work, but if not, run these:

-- Option 1: Create a new user with full permissions
CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'YOUR_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Option 2: If admin@localhost exists, grant from % as well
-- GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'YOUR_PASSWORD_HERE';
-- FLUSH PRIVILEGES;

-- Note: Replace YOUR_PASSWORD_HERE with the actual password from Secrets Manager

