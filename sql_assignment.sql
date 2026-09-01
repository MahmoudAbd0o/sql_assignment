-- SQL Assignment
-- Author: Mahmoud Hossam
-- Repository: SQL-Assignment

-- ============================================================
-- 1. Basic SQL Queries
-- ============================================================

-- Retrieve all columns from employees
SELECT *
FROM employees;

-- Retrieve emp_id, emp_name, and dept_id
-- for employees located in Cairo
SELECT emp_id, emp_name, dept_id
FROM employees
WHERE location = 'Cairo';


-- ============================================================
-- 2. DISTINCT Keyword
-- ============================================================

-- Display distinct department IDs
SELECT DISTINCT dept_id
FROM employees;


-- ============================================================
-- 3. Data Definition Language (DDL)
-- ============================================================

-- Create students table
CREATE TABLE students (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) DEFAULT 'Unknown',
    Address VARCHAR(100) DEFAULT 'N/A',
    City VARCHAR(50) DEFAULT 'N/A',
    Birth_Date DATE
);

-- Drop students table
-- Run this only when you want to delete the table.
DROP TABLE students;


-- ============================================================
-- 4. Data Manipulation Language (DML)
-- ============================================================

-- Insert a student
-- ID is generated automatically because it is AUTO_INCREMENT.
INSERT INTO students
    (First_Name, Last_Name, Address, City, Birth_Date)
VALUES
    ('Ahmed', 'Ali', 'Downtown', 'Cairo', '1995-01-01');

-- Update the address of the student whose Last_Name is Ahmed
UPDATE students
SET Address = 'Garden City'
WHERE Last_Name = 'Ahmed';


-- ============================================================
-- 5. Transaction Control
-- ============================================================

-- Start a transaction
START TRANSACTION;

-- Delete students whose city is Cairo
DELETE FROM students
WHERE City = 'Cairo';

-- Undo the DELETE operation
ROLLBACK;
