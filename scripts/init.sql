/* Bootstrap script for MySQL permissions */

-- Make sure root has access from another container
GRANT ALL ON *.* TO root@'%';

-- Provide a 'db' database
CREATE DATABASE db COLLATE=utf8_general_ci;

-- Provide a passwordless 'db' user
GRANT ALL ON db.* to db@'localhost';
GRANT ALL ON db.* to db@'%';
