-- Base schema for the RDS MySQL source instance
CREATE DATABASE IF NOT EXISTS devops_raf_demo;
USE devops_raf_demo;

CREATE TABLE students (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    grade_level INT NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
