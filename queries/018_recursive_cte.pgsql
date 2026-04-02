
------------------------------------------------------------------------------------------------------
-- Recursive CTE definition
-- A Recursive CTE is a self referencing query that reapeatedly references itself until a condition is met. 
-- It consists of two parts: the anchor member, which is the initial query that runs once, and the recursive member, which references the CTE itself and runs repeatedly until a termination condition is met.
-- Recursive CTEs are often used to traverse hierarchical data, such as organizational charts, bill of materials, or any parent-child relationships.
------------------------------------------------------------------------------------------------------

-- TASK: Write a query using WITH RECURSIVE to list the management chain for a given employee (start with an employee_id).
-- 1. Output should include: employee_id, manager_id, level (distance from top), and a concatenated path of names.
-- 2. Provide an example result for one employee.

-- NOTES: a. The anchor member will select the starting employee based on the provided employee_id.
--        b. The recursive member will join the CTE with the employees table to find the manager of the current employee, incrementing the level and building the path.

