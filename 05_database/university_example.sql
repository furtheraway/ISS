-- ==============================================================================
-- UNIVERSITY EXAMPLE DATABASE — Companion Script
-- Intro to Relational Databases and SQL
--
-- Dialect: PostgreSQL.
-- Run section by section (most SQL tools let you select lines and execute
-- just the selection). Sections marked "FAILS ON PURPOSE" demonstrate
-- constraint errors — run those statements one at a time.
--
-- Slide characters: Ada Lin (sid 1), Ben Osei (2),
-- Chloe Park (3, enrolled in nothing — for the LEFT JOIN demos),
-- Diego Ruiz (4, one in-progress course with a NULL grade).
-- ==============================================================================

-- ==============================================================================
-- PART 9 — DEFINING TABLES (DDL)
-- Constraints declared once, enforced forever: primary keys, foreign keys, `NOT NULL`, `CHECK`.
-- ==============================================================================

-- Clean slate (order matters: enrollments references the other two)
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;

CREATE TABLE students (
  sid    integer      PRIMARY KEY,
  name   varchar(100) NOT NULL,
  major  text,
  year   smallint CHECK (year BETWEEN 1 AND 6)
);

CREATE TABLE courses (
  cid     text PRIMARY KEY,
  title   text NOT NULL,
  credits smallint CHECK (credits > 0),
  dept    text
);

CREATE TABLE enrollments (
  sid      integer REFERENCES students(sid),
  cid      text    REFERENCES courses(cid),
  semester text,
  grade    text,
  PRIMARY KEY (sid, cid, semester)
);

-- ==============================================================================
-- POPULATE THE DATABASE
-- 50 students, 7 courses, ~90 enrollments. Grades are `NULL` for some in-progress S26 courses.
-- ==============================================================================

INSERT INTO students (sid, name, major, year) VALUES
  (1, 'Ada Lin', 'CS', 2),
  (2, 'Ben Osei', 'CS', 3),
  (3, 'Chloe Park', 'Math', 1),
  (4, 'Diego Ruiz', 'CS', 4),
  (5, 'Emi Sato', 'CS', 4),
  (6, 'Farid Khan', 'Math', 3),
  (7, 'Grace Hopper', 'Physics', 3),
  (8, 'Hugo Marchetti', 'CS', 1),
  (9, 'Ines Silva', 'Biology', 1),
  (10, 'Jonas Weber', 'Econ', 1),
  (11, 'Kira Novak', 'Math', 2),
  (12, 'Liam Byrne', 'CS', 4),
  (13, 'Mara Costa', 'Physics', 3),
  (14, 'Noah Fischer', 'CS', 3),
  (15, 'Olga Petrov', 'Econ', 2),
  (16, 'Pavel Dvorak', 'Math', 2),
  (17, 'Quinn Adeyemi', 'CS', 1),
  (18, 'Rosa Moreno', 'Biology', 4),
  (19, 'Sam Whitfield', 'CS', 4),
  (20, 'Tara Nguyen', 'Math', 4),
  (21, 'Umar Haddad', 'Econ', 2),
  (22, 'Vera Ivanova', 'CS', 2),
  (23, 'Wes Calloway', 'Physics', 4),
  (24, 'Xena Papadopoulos', 'Math', 1),
  (25, 'Yara Haile', 'CS', 4),
  (26, 'Zane Mercer', 'Biology', 4),
  (27, 'Alma Lindqvist', 'CS', 4),
  (28, 'Boris Volkov', 'Math', 1),
  (29, 'Cleo Abara', 'Econ', 2),
  (30, 'Dana Kovacs', 'CS', 3),
  (31, 'Eli Stern', 'Physics', 1),
  (32, 'Fern Gallagher', 'CS', 2),
  (33, 'Gita Rao', 'Math', 3),
  (34, 'Hana Kimura', 'CS', 4),
  (35, 'Ivan Sokolov', 'Econ', 2),
  (36, 'June Barnett', 'Biology', 3),
  (37, 'Kofi Mensah', 'CS', 1),
  (38, 'Lena Vogel', 'Math', 3),
  (39, 'Milo Antonelli', 'Physics', 3),
  (40, 'Nina Rossi', 'CS', 3),
  (41, 'Omar Farouk', 'Econ', 3),
  (42, 'Pia Berg', 'CS', 4),
  (43, 'Ravi Iyer', 'Math', 4),
  (44, 'Sara Haddix', 'CS', 1),
  (45, 'Theo Klein', 'Biology', 4),
  (46, 'Uma Devi', 'Physics', 2),
  (47, 'Vik Sharma', 'CS', 4),
  (48, 'Wren Ashby', 'Math', 1),
  (49, 'Yuki Tanaka', 'CS', 4),
  (50, 'Zara Elmasri', 'Econ', 2);

INSERT INTO courses (cid, title, credits, dept) VALUES
  ('C101', 'Intro to Databases', 4, 'CS'),
  ('C102', 'Data Structures', 4, 'CS'),
  ('C201', 'Algorithms', 4, 'CS'),
  ('M201', 'Linear Algebra', 3, 'Math'),
  ('M301', 'Probability and Statistics', 3, 'Math'),
  ('P101', 'Classical Mechanics', 4, 'Physics'),
  ('E101', 'Intro to Microeconomics', 3, 'Econ');

INSERT INTO enrollments (sid, cid, semester, grade) VALUES
  (1, 'C101', 'F25', 'A'),
  (1, 'M201', 'F25', 'A-'),
  (2, 'C101', 'F25', 'B+'),
  (4, 'C102', 'S26', NULL),
  (4, 'C101', 'F25', 'A'),
  (1, 'C201', 'F25', 'C'),
  (1, 'M301', 'F25', 'C+'),
  (2, 'C101', 'S26', NULL),
  (2, 'C102', 'S26', NULL),
  (2, 'C201', 'F25', 'A'),
  (4, 'E101', 'S26', 'A'),
  (4, 'M301', 'F25', 'A-'),
  (4, 'E101', 'F25', 'C+'),
  (5, 'C101', 'S26', 'C+'),
  (6, 'P101', 'S26', NULL),
  (6, 'C201', 'F25', 'B'),
  (7, 'E101', 'F25', 'A-'),
  (8, 'M301', 'F25', 'A-'),
  (8, 'P101', 'F25', 'B+'),
  (9, 'M301', 'F25', 'B'),
  (9, 'C102', 'F25', 'B'),
  (9, 'M201', 'F25', 'A-'),
  (11, 'C101', 'S26', NULL),
  (12, 'C102', 'F25', 'B+'),
  (12, 'M301', 'S26', NULL),
  (13, 'P101', 'S26', NULL),
  (14, 'M201', 'F25', 'A-'),
  (14, 'P101', 'F25', 'B'),
  (15, 'E101', 'S26', NULL),
  (16, 'P101', 'F25', 'A-'),
  (17, 'P101', 'F25', 'A'),
  (17, 'C201', 'F25', 'C'),
  (18, 'M301', 'F25', 'C+'),
  (19, 'E101', 'F25', 'A-'),
  (19, 'M201', 'F25', 'B-'),
  (19, 'M201', 'S26', 'B'),
  (20, 'C201', 'F25', 'C+'),
  (20, 'M201', 'F25', 'B-'),
  (20, 'E101', 'S26', NULL),
  (21, 'C201', 'F25', 'A'),
  (22, 'P101', 'F25', 'B'),
  (22, 'C102', 'F25', 'B'),
  (23, 'E101', 'S26', NULL),
  (23, 'M301', 'F25', 'C+'),
  (24, 'C201', 'S26', NULL),
  (24, 'P101', 'F25', 'A-'),
  (25, 'M201', 'F25', 'C'),
  (25, 'M201', 'S26', NULL),
  (26, 'M301', 'F25', 'B'),
  (26, 'P101', 'F25', 'A'),
  (28, 'M201', 'F25', 'C+'),
  (28, 'P101', 'F25', 'C+'),
  (28, 'C201', 'F25', 'A-'),
  (29, 'P101', 'S26', 'A'),
  (30, 'P101', 'F25', 'A'),
  (30, 'C102', 'F25', 'B'),
  (31, 'C201', 'S26', NULL),
  (31, 'P101', 'F25', 'C'),
  (32, 'C102', 'F25', 'B'),
  (33, 'M301', 'F25', 'A'),
  (33, 'C101', 'F25', 'B+'),
  (34, 'E101', 'F25', 'A'),
  (35, 'C201', 'F25', 'B'),
  (36, 'M301', 'F25', 'A'),
  (36, 'C102', 'S26', 'B+'),
  (36, 'C101', 'S26', 'A'),
  (37, 'C201', 'F25', 'A-'),
  (38, 'M201', 'S26', 'C+'),
  (38, 'M201', 'F25', 'B'),
  (39, 'M201', 'S26', 'B'),
  (39, 'M301', 'S26', NULL),
  (40, 'M201', 'S26', 'C'),
  (40, 'E101', 'F25', 'A'),
  (40, 'M301', 'F25', 'B'),
  (41, 'E101', 'F25', 'C+'),
  (42, 'C101', 'F25', 'A'),
  (42, 'M201', 'F25', 'B+'),
  (42, 'C102', 'F25', 'B-'),
  (43, 'E101', 'F25', 'C+'),
  (43, 'M201', 'F25', 'A'),
  (43, 'M301', 'F25', 'A'),
  (45, 'C101', 'F25', 'B+'),
  (46, 'M201', 'S26', 'B'),
  (47, 'E101', 'S26', 'B-'),
  (47, 'C101', 'F25', 'B+'),
  (48, 'P101', 'S26', 'B-'),
  (49, 'C101', 'F25', 'B'),
  (49, 'M301', 'F25', 'B'),
  (50, 'C201', 'F25', 'C+');

-- Sanity check
SELECT (SELECT COUNT(*) FROM students)    AS students,
       (SELECT COUNT(*) FROM courses)     AS courses,
       (SELECT COUNT(*) FROM enrollments) AS enrollments;

-- ==============================================================================
-- PART 5 — SQL BASICS: SELECT, WHERE, ORDER BY
-- ==============================================================================

-- Everything: every column, every row
SELECT * FROM students;

-- Choosing columns (projection π)
SELECT name, major FROM students;

-- WHERE: filtering rows (selection σ)
SELECT name, year
FROM   students
WHERE  year >= 3;

-- Combining conditions: BETWEEN, IN, AND
SELECT name, major, year
FROM   students
WHERE  year BETWEEN 2 AND 3
  AND  major IN ('CS', 'Math');

-- Pattern matching with LIKE (% = any sequence, _ = one char)
SELECT title
FROM   courses
WHERE  title LIKE '%Intro%';

-- PostgreSQL-only: case-insensitive ILIKE
-- SELECT title FROM courses WHERE title ILIKE '%intro%';

-- NULL demo: Diego's in-progress course.
-- grade = NULL matches NOTHING — this returns zero rows:
SELECT * FROM enrollments WHERE grade = NULL;

-- The correct test: IS NULL
SELECT s.name, e.cid, e.semester
FROM   students s
JOIN   enrollments e ON s.sid = e.sid
WHERE  e.grade IS NULL;

-- ORDER BY: seniors first, ties broken alphabetically
SELECT   name, major, year
FROM     students
ORDER BY year DESC, name ASC;

-- LIMIT + ORDER BY = top-N. Which majors exist? DISTINCT.
SELECT   name, year
FROM     students
ORDER BY year DESC
LIMIT    5;

SELECT DISTINCT major FROM students;

-- Expressions and aliases
SELECT title,
       credits * 15 AS contact_hours
FROM   courses;

-- ==============================================================================
-- PART 6 — JOINS
-- ==============================================================================

-- INNER JOIN: students with their enrollments.
-- Ada appears twice (two courses); Chloe Park doesn't appear at all.
SELECT s.name, e.cid, e.grade
FROM   students s
JOIN   enrollments e ON s.sid = e.sid
ORDER BY s.sid
LIMIT  15;

-- Three-table join: "Who got an A in Intro to Databases?"
SELECT s.name, s.major
FROM   students    s
JOIN   enrollments e ON s.sid = e.sid
JOIN   courses     c ON e.cid = c.cid
WHERE  c.title = 'Intro to Databases'
  AND  e.grade = 'A';

-- LEFT JOIN: EVERY student, enrolled or not — Chloe returns, with NULLs
SELECT s.name, e.cid, e.grade
FROM   students s
LEFT JOIN enrollments e ON s.sid = e.sid
ORDER BY s.sid
LIMIT  15;

-- The classic trick: students enrolled in NOTHING
SELECT s.sid, s.name, s.major
FROM   students s
LEFT JOIN enrollments e ON s.sid = e.sid
WHERE  e.sid IS NULL;

-- Self join: pairs of same-major students (a.sid < b.sid kills duplicates)
SELECT a.name AS student_1, b.name AS student_2, a.major
FROM   students a
JOIN   students b
  ON   a.major = b.major
 AND   a.sid < b.sid
WHERE  a.major = 'Physics';

-- ==============================================================================
-- PART 7 — AGGREGATION
-- ==============================================================================

-- Aggregate functions: many rows in, one row out.
-- Note COUNT(grade) < COUNT(*): it skips NULL grades.
SELECT COUNT(*)     AS enrollment_rows,
       COUNT(grade) AS graded_rows,
       MIN(grade)   AS best_grade
FROM   enrollments;

-- GROUP BY: "per major" — one summary row per group
SELECT   major, COUNT(*) AS n_students, ROUND(AVG(year), 2) AS avg_year
FROM     students
GROUP BY major
ORDER BY n_students DESC;

-- HAVING: filter GROUPS after aggregation
SELECT   major, COUNT(*) AS n_students
FROM     students
GROUP BY major
HAVING   COUNT(*) >= 5
ORDER BY n_students DESC;

-- WHERE vs HAVING in one query:
-- rows filtered first (upperclass only), groups filtered after (2+ students)
SELECT   major, ROUND(AVG(year), 2) AS avg_year, COUNT(*) AS n
FROM     students
WHERE    year >= 2          -- rows first...
GROUP BY major
HAVING   COUNT(*) >= 2      -- ...groups after
ORDER BY avg_year DESC;

-- Enrollment count per course — join + group by together
SELECT   c.title, COUNT(e.sid) AS enrolled
FROM     courses c
LEFT JOIN enrollments e ON c.cid = e.cid
GROUP BY c.cid, c.title
ORDER BY enrolled DESC;

-- ==============================================================================
-- PART 8 — SUBQUERIES
-- ==============================================================================

-- Scalar subquery: students above the average year
SELECT name, year
FROM   students
WHERE  year > (SELECT AVG(year) FROM students)
ORDER BY year DESC, name;

-- IN subquery: students enrolled in C101
SELECT name
FROM   students
WHERE  sid IN (SELECT sid
               FROM   enrollments
               WHERE  cid = 'C101')
ORDER BY name;

-- Correlated subquery: the most senior student(s) in each major
SELECT name, major, year
FROM   students s
WHERE  year = (SELECT MAX(year)
               FROM   students
               WHERE  major = s.major)
ORDER BY major, name;

-- NOT EXISTS: enrolled in nothing (same answer as the LEFT JOIN trick)
SELECT name
FROM   students s
WHERE  NOT EXISTS (SELECT 1
                   FROM   enrollments e
                   WHERE  e.sid = s.sid);

-- Subquery in FROM: average number of courses per enrolled student
SELECT ROUND(AVG(n), 2) AS avg_courses_per_student
FROM (SELECT sid, COUNT(*) AS n
      FROM   enrollments
      GROUP BY sid) AS per_student;

-- ==============================================================================
-- PART 4 (REVISITED) — SET OPERATIONS
-- ==============================================================================

-- Union / intersection / difference of two course rosters
-- A = students in C101, B = students in M201
SELECT sid FROM enrollments WHERE cid = 'C101'
INTERSECT
SELECT sid FROM enrollments WHERE cid = 'M201';

-- In Databases but NOT in Linear Algebra
SELECT sid FROM enrollments WHERE cid = 'C101'
EXCEPT
SELECT sid FROM enrollments WHERE cid = 'M201';

-- ==============================================================================
-- PART 9 (CONTINUED) — CONSTRAINTS IN ACTION
-- Each of these fails on purpose — run them one at a time and read the errors.
-- ==============================================================================

-- Foreign key violation: student 999 does not exist
INSERT INTO enrollments VALUES (999, 'C101', 'F25', 'A');

-- Primary key violation: sid 1 is taken
INSERT INTO students VALUES (1, 'Impostor Ada', 'CS', 2);

-- CHECK violation: year 9 is out of range
INSERT INTO students VALUES (51, 'Time Traveler', 'CS', 9);

-- ==============================================================================
-- PART 9 (CONTINUED) — INSERT, UPDATE, DELETE
-- ==============================================================================

-- A new student arrives...
INSERT INTO students (sid, name, major, year)
VALUES (51, 'Nia Okafor', 'CS', 1);

-- ...changes major...
UPDATE students SET major = 'Math' WHERE sid = 51;

-- ...and (rehearse the WHERE as a SELECT first!) leaves
SELECT * FROM students WHERE sid = 51;

DELETE FROM students WHERE sid = 51;

-- ==============================================================================
-- PART 11 — TRANSACTIONS
-- Ada swaps Linear Algebra for Data Structures — atomically. Then a ROLLBACK demo.
-- ==============================================================================

BEGIN;
  DELETE FROM enrollments WHERE sid = 1 AND cid = 'M201' AND semester = 'F25';
  INSERT INTO enrollments VALUES (1, 'C102', 'S26', NULL);
COMMIT;

SELECT * FROM enrollments WHERE sid = 1;

-- ROLLBACK: the undo button
BEGIN;
  DELETE FROM enrollments;      -- oops — no WHERE!
  SELECT COUNT(*) AS rows_left FROM enrollments;   -- 0 inside the transaction
ROLLBACK;

SELECT COUNT(*) AS rows_after_rollback FROM enrollments;  -- everything is back

-- ==============================================================================
-- *END OF NOTEBOOK — THE SCHEMA AND DATA STAY IN YOUR DATABASE FOR FURTHER EXPERIMENTATION. RE-RUN THE FIRST TWO CELLS FOR A CLEAN RESET.*
-- ==============================================================================