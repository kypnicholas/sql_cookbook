-- TASK FORMAT
-- Task ID: E18
-- Title: Recursive CTE management chain
-- Goal: Traverse employee hierarchy using reports_to and build readable paths.
-- Deliverables: employee_id, reports_to, level, and name/title path output.
-- Verification: Recursive chain returns one employee and each manager upward.
-- -----------------------------------------------------------------------------
-- Recursive CTE definition.
-- A Recursive CTE is a self referencing query that reapeatedly references itself until a condition is met.
-- It consists of two parts: the anchor member, which is the initial query that runs once, and the recursive member, which references the CTE itself and runs repeatedly until a termination condition is met.
-- Recursive CTEs are often used to traverse hierarchical data, such as organizational charts, bill of materials, or any parent-child relationships.
-- -----------------------------------------------------------------------------

-- TASK: Write a query using WITH RECURSIVE to list the management chain for a given employee (start with an employee_id), using the reports_to column in the employee table.
-- 1. Output should include: employee_id, reports_to, level (distance from top), and a concatenated path of first and last names.
-- 2. Provide an example result for one employee.

-- NOTES: a. The anchor member will select the starting employee based on the provided employee_id.
-- B. The recursive member will join the CTE with the employee table to find the manager of the current employee, incrementing the level and building the path.


WITH RECURSIVE ManagementChain AS (
    -- Anchor member: Start with the given employee_id.
    SELECT
        employee_id,
        reports_to,
        0 AS level,
        CONCAT(first_name, ' ', last_name, ' [', title, ']') AS path
    FROM employee
    WHERE employee_id = 5 -- Replace with the desired employee_id

    UNION ALL

    -- Recursive member: Join the CTE with the employee table to find the manager.
    SELECT
        e.employee_id,
        e.reports_to,
        mc.level + 1 AS level,
        CONCAT(e.first_name, ' ', e.last_name, ' [', e.title, '] -> ', mc.path) AS path
    FROM employee e
    JOIN ManagementChain mc ON e.employee_id = mc.reports_to
)
SELECT *
FROM ManagementChain;

