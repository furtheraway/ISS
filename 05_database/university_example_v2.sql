-- ==============================================================================
-- UNIVERSITY EXAMPLE DATABASE v2 — Extended Dataset
-- Intro to Relational Databases and SQL
--
-- Dialect: PostgreSQL.
--
-- What's new vs. v1 (to make aggregation genuinely interesting):
--   departments(dept, building, budget)     -- new table: budgets to aggregate,
--                                              and the 3NF example from the slides
--   students   + age, home_city             -- numeric + categorical columns
--   courses    + level, capacity            -- fill-rate and per-level stats
--   enrollments + points numeric(2,1)       -- numeric grade points (A=4.0 ... C=2.0),
--                                              NULL while a course is in progress,
--                                              so AVG / SUM / GPA queries work
--   2-5 courses per student (~170 enrollment rows)
--
-- Slide characters preserved: Ada Lin (1), Ben Osei (2),
-- Chloe Park (3, enrolled in nothing), Diego Ruiz (4, one NULL grade).
--
-- Run section by section. "FAILS ON PURPOSE" statements: run one at a time.
-- ==============================================================================

-- ==============================================================================
-- SECTION 1 — SCHEMA (DDL)
-- Four tables now; departments is referenced by both students and courses.
-- ==============================================================================

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
  dept     text PRIMARY KEY,
  building text NOT NULL,
  budget   integer CHECK (budget >= 0)      -- yearly, in dollars
);

CREATE TABLE students (
  sid       integer      PRIMARY KEY,
  name      varchar(100) NOT NULL,
  major     text REFERENCES departments(dept),
  year      smallint CHECK (year BETWEEN 1 AND 6),
  age       smallint CHECK (age >= 16),
  home_city text
);

CREATE TABLE courses (
  cid      text PRIMARY KEY,
  title    text NOT NULL,
  credits  smallint CHECK (credits > 0),
  dept     text REFERENCES departments(dept),
  level    smallint,                        -- 100 / 200 / 300
  capacity smallint CHECK (capacity > 0)    -- max seats per offering
);

CREATE TABLE enrollments (
  sid      integer REFERENCES students(sid),
  cid      text    REFERENCES courses(cid),
  semester text,
  grade    text,                            -- letter grade, NULL = in progress
  points   numeric(2,1),                    -- 4.0-scale equivalent, NULL = in progress
  PRIMARY KEY (sid, cid, semester)
);

-- ==============================================================================
-- SECTION 2 — DATA
-- 50 students, 5 departments, 10 courses, ~170 enrollments.
-- ==============================================================================

INSERT INTO departments (dept, building, budget) VALUES
  ('CS', 'Gates Hall', 1200000),
  ('Math', 'Euler Center', 640000),
  ('Physics', 'Curie Labs', 890000),
  ('Biology', 'Darwin Wing', 760000),
  ('Econ', 'Keynes House', 510000);

INSERT INTO students (sid, name, major, year, age, home_city) VALUES
  (1, 'Ada Lin', 'CS', 2, 21, 'Northbrook'),
  (2, 'Ben Osei', 'CS', 3, 22, 'Ashford'),
  (3, 'Chloe Park', 'Math', 1, 20, 'Springfield'),
  (4, 'Diego Ruiz', 'CS', 4, 18, 'Northbrook'),
  (5, 'Emi Sato', 'CS', 3, 22, 'Lakewood'),
  (6, 'Farid Khan', 'Math', 2, 19, 'Northbrook'),
  (7, 'Grace Hopper', 'Physics', 4, 23, 'Fairview'),
  (8, 'Hugo Marchetti', 'CS', 2, 21, 'Springfield'),
  (9, 'Ines Silva', 'Biology', 4, 23, 'Granville'),
  (10, 'Jonas Weber', 'Econ', 1, 19, 'Ashford'),
  (11, 'Kira Novak', 'Math', 1, 18, 'Milton'),
  (12, 'Liam Byrne', 'CS', 4, 21, 'Milton'),
  (13, 'Mara Costa', 'Physics', 1, 19, 'Milton'),
  (14, 'Noah Fischer', 'CS', 3, 22, 'Granville'),
  (15, 'Olga Petrov', 'Econ', 4, 21, 'Granville'),
  (16, 'Pavel Dvorak', 'Math', 2, 21, 'Riverton'),
  (17, 'Quinn Adeyemi', 'CS', 4, 21, 'Springfield'),
  (18, 'Rosa Moreno', 'Biology', 2, 19, 'Riverton'),
  (19, 'Sam Whitfield', 'CS', 4, 21, 'Lakewood'),
  (20, 'Tara Nguyen', 'Math', 3, 22, 'Milton'),
  (21, 'Umar Haddad', 'Econ', 4, 22, 'Milton'),
  (22, 'Vera Ivanova', 'CS', 1, 18, 'Springfield'),
  (23, 'Wes Calloway', 'Physics', 4, 23, 'Riverton'),
  (24, 'Xena Papadopoulos', 'Math', 4, 21, 'Fairview'),
  (25, 'Yara Haile', 'CS', 1, 18, 'Riverton'),
  (26, 'Zane Mercer', 'Biology', 2, 20, 'Northbrook'),
  (27, 'Alma Lindqvist', 'CS', 2, 20, 'Lakewood'),
  (28, 'Boris Volkov', 'Math', 3, 21, 'Springfield'),
  (29, 'Cleo Abara', 'Econ', 4, 22, 'Granville'),
  (30, 'Dana Kovacs', 'CS', 1, 20, 'Milton'),
  (31, 'Eli Stern', 'Physics', 4, 22, 'Fairview'),
  (32, 'Fern Gallagher', 'CS', 2, 19, 'Springfield'),
  (33, 'Gita Rao', 'Math', 2, 20, 'Lakewood'),
  (34, 'Hana Kimura', 'CS', 4, 23, 'Milton'),
  (35, 'Ivan Sokolov', 'Econ', 1, 20, 'Milton'),
  (36, 'June Barnett', 'Biology', 3, 20, 'Springfield'),
  (37, 'Kofi Mensah', 'CS', 4, 23, 'Fairview'),
  (38, 'Lena Vogel', 'Math', 4, 22, 'Granville'),
  (39, 'Milo Antonelli', 'Physics', 2, 19, 'Fairview'),
  (40, 'Nina Rossi', 'CS', 1, 20, 'Lakewood'),
  (41, 'Omar Farouk', 'Econ', 3, 21, 'Springfield'),
  (42, 'Pia Berg', 'CS', 1, 19, 'Fairview'),
  (43, 'Ravi Iyer', 'Math', 4, 21, 'Northbrook'),
  (44, 'Sara Haddix', 'CS', 4, 22, 'Milton'),
  (45, 'Theo Klein', 'Biology', 3, 21, 'Milton'),
  (46, 'Uma Devi', 'Physics', 1, 18, 'Springfield'),
  (47, 'Vik Sharma', 'CS', 2, 21, 'Ashford'),
  (48, 'Wren Ashby', 'Math', 1, 20, 'Lakewood'),
  (49, 'Yuki Tanaka', 'CS', 3, 22, 'Lakewood'),
  (50, 'Zara Elmasri', 'Econ', 1, 19, 'Granville');

INSERT INTO courses (cid, title, credits, dept, level, capacity) VALUES
  ('C101', 'Intro to Databases', 4, 'CS', 100, 40),
  ('C102', 'Data Structures', 4, 'CS', 100, 45),
  ('C201', 'Algorithms', 4, 'CS', 200, 35),
  ('C301', 'Machine Learning', 4, 'CS', 300, 30),
  ('M201', 'Linear Algebra', 3, 'Math', 200, 50),
  ('M301', 'Probability and Statistics', 3, 'Math', 300, 40),
  ('P101', 'Classical Mechanics', 4, 'Physics', 100, 35),
  ('B101', 'Cell Biology', 3, 'Biology', 100, 30),
  ('E101', 'Intro to Microeconomics', 3, 'Econ', 100, 60),
  ('E201', 'Econometrics', 4, 'Econ', 200, 25);

INSERT INTO enrollments (sid, cid, semester, grade, points) VALUES
  (1, 'C101', 'F25', 'A', 4.0),
  (1, 'M201', 'F25', 'A-', 3.7),
  (2, 'C101', 'F25', 'B+', 3.3),
  (4, 'C102', 'S26', NULL, NULL),
  (4, 'C101', 'F25', 'A', 4.0),
  (1, 'C201', 'F25', 'C', 2.0),
  (1, 'P101', 'F25', 'C+', 2.3),
  (1, 'E201', 'F25', 'C', 2.0),
  (2, 'C301', 'F25', 'A', 4.0),
  (2, 'P101', 'S26', 'B-', 2.7),
  (4, 'P101', 'F25', 'A-', 3.7),
  (4, 'E101', 'F25', 'C+', 2.3),
  (5, 'C101', 'S26', 'C+', 2.3),
  (5, 'E101', 'S26', 'A', 4.0),
  (6, 'C102', 'S26', NULL, NULL),
  (6, 'C201', 'S26', NULL, NULL),
  (6, 'E101', 'F25', 'A-', 3.7),
  (7, 'M301', 'F25', 'A-', 3.7),
  (7, 'E101', 'S26', NULL, NULL),
  (7, 'B101', 'F25', 'B+', 3.3),
  (8, 'C201', 'F25', 'B', 3.0),
  (8, 'M301', 'F25', 'A-', 3.7),
  (8, 'M201', 'F25', 'B-', 2.7),
  (9, 'P101', 'S26', NULL, NULL),
  (9, 'M201', 'F25', 'B', 3.0),
  (9, 'P101', 'F25', 'A', 4.0),
  (11, 'B101', 'F25', 'B+', 3.3),
  (11, 'M301', 'F25', 'A-', 3.7),
  (11, 'E101', 'F25', 'B', 3.0),
  (11, 'C101', 'S26', 'B+', 3.3),
  (11, 'C102', 'S26', NULL, NULL),
  (12, 'M201', 'S26', NULL, NULL),
  (12, 'C101', 'F25', 'A', 4.0),
  (13, 'C201', 'F25', 'B', 3.0),
  (13, 'E101', 'S26', 'A-', 3.7),
  (13, 'B101', 'F25', 'C', 2.0),
  (14, 'M301', 'S26', NULL, NULL),
  (14, 'C301', 'S26', 'C+', 2.3),
  (14, 'C102', 'F25', 'B+', 3.3),
  (15, 'C102', 'S26', 'A-', 3.7),
  (15, 'M301', 'F25', 'A', 4.0),
  (16, 'P101', 'S26', 'A-', 3.7),
  (16, 'P101', 'F25', 'C+', 2.3),
  (16, 'C301', 'F25', 'B', 3.0),
  (16, 'C102', 'S26', NULL, NULL),
  (17, 'P101', 'F25', 'B', 3.0),
  (17, 'E201', 'F25', 'C', 2.0),
  (17, 'C101', 'F25', 'B', 3.0),
  (18, 'P101', 'S26', 'A', 4.0),
  (18, 'E101', 'F25', 'B+', 3.3),
  (19, 'B101', 'F25', 'C+', 2.3),
  (19, 'C301', 'F25', 'A-', 3.7),
  (19, 'C101', 'S26', 'B', 3.0),
  (19, 'C101', 'F25', 'C+', 2.3),
  (19, 'M201', 'F25', 'A-', 3.7),
  (20, 'M301', 'F25', 'B+', 3.3),
  (20, 'P101', 'F25', 'C+', 2.3),
  (21, 'E201', 'F25', 'A-', 3.7),
  (21, 'C101', 'S26', NULL, NULL),
  (22, 'C101', 'F25', 'A', 4.0),
  (22, 'C102', 'F25', 'A', 4.0),
  (22, 'E201', 'F25', 'A', 4.0),
  (22, 'C201', 'F25', 'B+', 3.3),
  (23, 'E201', 'S26', 'A', 4.0),
  (23, 'C201', 'S26', 'B+', 3.3),
  (23, 'C101', 'S26', 'A', 4.0),
  (23, 'C102', 'F25', 'A-', 3.7),
  (24, 'P101', 'F25', 'C+', 2.3),
  (24, 'M301', 'S26', NULL, NULL),
  (24, 'C102', 'S26', NULL, NULL),
  (25, 'B101', 'S26', 'B', 3.0),
  (25, 'E101', 'F25', 'C', 2.0),
  (25, 'M201', 'S26', 'C', 2.0),
  (26, 'C101', 'S26', NULL, NULL),
  (26, 'E201', 'F25', 'C+', 2.3),
  (26, 'E101', 'F25', 'B+', 3.3),
  (26, 'C102', 'F25', 'A', 4.0),
  (28, 'C201', 'F25', 'B-', 2.7),
  (28, 'B101', 'S26', NULL, NULL),
  (28, 'E101', 'F25', 'B', 3.0),
  (29, 'M301', 'F25', 'A', 4.0),
  (29, 'C201', 'F25', 'A', 4.0),
  (30, 'C301', 'F25', 'C', 2.0),
  (30, 'M301', 'F25', 'C', 2.0),
  (30, 'E201', 'S26', 'B-', 2.7),
  (31, 'C102', 'F25', 'C', 2.0),
  (31, 'P101', 'F25', 'A', 4.0),
  (32, 'B101', 'S26', 'B+', 3.3),
  (32, 'C101', 'F25', 'B', 3.0),
  (32, 'P101', 'F25', 'B', 3.0),
  (32, 'C201', 'F25', 'A', 4.0),
  (32, 'E101', 'S26', NULL, NULL),
  (33, 'C301', 'S26', 'A', 4.0),
  (33, 'C201', 'F25', 'B', 3.0),
  (33, 'C301', 'F25', 'C', 2.0),
  (34, 'P101', 'S26', 'B', 3.0),
  (34, 'P101', 'F25', 'C+', 2.3),
  (35, 'M301', 'S26', NULL, NULL),
  (35, 'C102', 'F25', 'C', 2.0),
  (35, 'E101', 'S26', 'A', 4.0),
  (35, 'P101', 'F25', 'C', 2.0),
  (36, 'C102', 'S26', NULL, NULL),
  (36, 'C101', 'F25', 'B', 3.0),
  (36, 'E101', 'F25', 'B', 3.0),
  (37, 'M301', 'F25', 'B+', 3.3),
  (37, 'C301', 'F25', 'B', 3.0),
  (37, 'C201', 'F25', 'A', 4.0),
  (37, 'E101', 'F25', 'C+', 2.3),
  (38, 'E201', 'F25', 'C', 2.0),
  (38, 'C102', 'F25', 'B+', 3.3),
  (38, 'M301', 'F25', 'A', 4.0),
  (38, 'M201', 'F25', 'C', 2.0),
  (38, 'P101', 'S26', NULL, NULL),
  (39, 'M201', 'F25', 'A', 4.0),
  (39, 'P101', 'F25', 'B', 3.0),
  (39, 'E101', 'S26', 'A', 4.0),
  (39, 'C201', 'F25', 'A', 4.0),
  (40, 'C101', 'F25', 'A', 4.0),
  (40, 'M201', 'F25', 'C', 2.0),
  (41, 'C301', 'F25', 'C', 2.0),
  (41, 'B101', 'F25', 'B+', 3.3),
  (42, 'C102', 'F25', 'C', 2.0),
  (42, 'E201', 'F25', 'B-', 2.7),
  (42, 'P101', 'S26', 'B', 3.0),
  (42, 'C301', 'S26', NULL, NULL),
  (43, 'C301', 'F25', 'B', 3.0),
  (43, 'C301', 'S26', 'B', 3.0),
  (45, 'P101', 'F25', 'A', 4.0),
  (45, 'E201', 'F25', 'B+', 3.3),
  (45, 'C102', 'F25', 'B-', 2.7),
  (45, 'B101', 'F25', 'C+', 2.3),
  (46, 'M201', 'F25', 'A-', 3.7),
  (46, 'M301', 'F25', 'B', 3.0),
  (46, 'E201', 'F25', 'A', 4.0),
  (46, 'C301', 'F25', 'A-', 3.7),
  (47, 'C102', 'S26', NULL, NULL),
  (47, 'C102', 'F25', 'A', 4.0),
  (48, 'E201', 'S26', 'B+', 3.3),
  (48, 'P101', 'S26', 'B', 3.0),
  (48, 'B101', 'F25', 'A', 4.0),
  (48, 'C101', 'F25', 'A-', 3.7),
  (49, 'C201', 'S26', 'B+', 3.3),
  (49, 'P101', 'F25', 'B+', 3.3),
  (49, 'E201', 'S26', 'B', 3.0),
  (49, 'M301', 'F25', 'A-', 3.7),
  (49, 'C301', 'S26', NULL, NULL),
  (50, 'B101', 'F25', 'C', 2.0),
  (50, 'B101', 'S26', NULL, NULL),
  (50, 'C101', 'S26', NULL, NULL);

-- Sanity check
SELECT (SELECT COUNT(*) FROM departments) AS departments,
       (SELECT COUNT(*) FROM students)    AS students,
       (SELECT COUNT(*) FROM courses)     AS courses,
       (SELECT COUNT(*) FROM enrollments) AS enrollments;

-- ==============================================================================
-- SECTION 3 — SQL BASICS (Part 5)
-- SELECT, WHERE, LIKE, NULL, ORDER BY, LIMIT, DISTINCT, expressions.
-- ==============================================================================


select  * from students

-- Choosing columns
SELECT name, major, age, home_city FROM students LIMIT 3;

-- WHERE with several conditions
SELECT name, major, year, age
FROM   students
WHERE  age BETWEEN 20 AND 20
  AND  major IN ('Math')
ORDER BY age DESC, name;

-- LIKE: all 'Intro' courses; ILIKE is the PostgreSQL case-insensitive variant
SELECT title, dept, level FROM courses WHERE title LIKE 'Intro%';

-- NULL: in-progress enrollments (grade = NULL would match nothing!)
SELECT s.name, e.cid, e.semester
FROM   students s
JOIN   enrollments e ON s.sid = e.sid
WHERE  e.grade IS NULL
ORDER BY s.name
LIMIT  10;

-- DISTINCT: which home cities are represented?
SELECT DISTINCT home_city FROM students ORDER BY home_city;

-- Expression + alias: seats per credit
SELECT title, capacity, credits,
       ROUND(capacity::numeric / credits, 1) AS seats_per_credit
FROM   courses
ORDER BY seats_per_credit DESC;

-- ==============================================================================
-- SECTION 4 — JOINS (Part 6)
-- Now with four tables to walk through.
-- ==============================================================================

select * from students limit 3;
select * from enrollments limit 3;
select * from courses limit 3;

-- Three-table join: who got an A in Intro to Databases?
SELECT s.name, s.major, c.title, e.grade
FROM   students    s
JOIN   enrollments e ON s.sid = e.sid
JOIN   courses     c ON e.cid = c.cid
WHERE  c.title = 'Intro to Databases' AND e.grade = 'A';

-- Four tables: student -> enrollment -> course -> department
SELECT s.name, c.title, d.building
FROM   students    s
JOIN   enrollments e ON s.sid  = e.sid
JOIN   courses     c ON e.cid  = c.cid
JOIN   departments d ON c.dept = d.dept
WHERE  s.sid = 1;

-- LEFT JOIN trick: students enrolled in nothing (Chloe & friends)
SELECT s.sid, s.name, s.major, e.cid, e.grade
FROM   students s
LEFT JOIN enrollments e ON s.sid = e.sid
WHERE  e.sid IS NULL;

-- Self join: same-city pairs of students (a.sid < b.sid removes duplicates)
SELECT a.name AS student_1, b.name AS student_2, a.home_city
FROM   students a
JOIN   students b ON a.home_city = b.home_city AND a.sid < b.sid
WHERE  a.home_city = 'Milton';

-- ==============================================================================
-- SECTION 5 — AGGREGATION (Part 7)
-- The payoff of the new columns: GPAs, fill rates, budgets per head.
-- ==============================================================================

-- COUNT(*) vs COUNT(column): COUNT(points) skips in-progress NULLs
SELECT COUNT(*)      AS all_enrollments,
       COUNT(points) AS graded_enrollments,
       ROUND(AVG(points), 2) AS overall_gpa,
       MIN(points)   AS worst,
       MAX(points)   AS best
FROM   enrollments;

-- GPA per student (only students with at least one graded course)
SELECT   s.name, s.major,
         ROUND(AVG(e.points), 2) AS gpa,
         COUNT(e.points)         AS graded_courses
FROM     students s
JOIN     enrollments e ON s.sid = e.sid
GROUP BY s.sid, s.name, s.major
HAVING   COUNT(e.points) > 0
ORDER BY gpa DESC
LIMIT    10;

-- Average GPA and headcount per major: GROUP BY + several aggregates
SELECT   s.major,
         COUNT(DISTINCT s.sid)   AS students,
         ROUND(AVG(e.points), 2) AS avg_gpa
FROM     students s
LEFT JOIN enrollments e ON s.sid = e.sid
GROUP BY s.major
ORDER BY avg_gpa DESC NULLS LAST;

-- Course fill rate: enrolled seats vs capacity (F25 offerings)
SELECT   c.title, c.capacity,
         COUNT(e.sid) AS enrolled,
         ROUND(100.0 * COUNT(e.sid) / c.capacity, 0) AS fill_pct
FROM     courses c
LEFT JOIN enrollments e ON c.cid = e.cid AND e.semester = 'F25'
GROUP BY c.cid, c.title, c.capacity
ORDER BY fill_pct DESC;

-- Credit load per student per semester: SUM
SELECT   s.name, e.semester, SUM(c.credits) AS credit_load
FROM     students s
JOIN     enrollments e ON s.sid = e.sid
JOIN     courses     c ON e.cid = c.cid
GROUP BY s.sid, s.name, e.semester
ORDER BY credit_load DESC
LIMIT    10;

-- WHERE vs HAVING together: among 200+-level courses only,
-- departments averaging a fill of 10+ students per course
SELECT   c.dept,
         COUNT(DISTINCT c.cid)                          AS courses,
         ROUND(COUNT(e.sid)::numeric
               / COUNT(DISTINCT c.cid), 1)              AS avg_enrolled
FROM     courses c
LEFT JOIN enrollments e ON c.cid = e.cid
WHERE    c.level >= 200                 -- rows filtered first...
GROUP BY c.dept
HAVING   COUNT(e.sid) >= 10             -- ...groups filtered after
ORDER BY avg_enrolled DESC;

-- Budget per enrolled student, by department (dividing two aggregates)
SELECT   d.dept, d.budget,
         COUNT(DISTINCT e.sid)                    AS students_taught,
         ROUND(d.budget::numeric
               / NULLIF(COUNT(DISTINCT e.sid),0)) AS dollars_per_student
FROM     departments d
JOIN     courses     c ON d.dept = c.dept
LEFT JOIN enrollments e ON c.cid = e.cid
GROUP BY d.dept, d.budget
ORDER BY dollars_per_student DESC;

-- ==============================================================================
-- SECTION 6 — SUBQUERIES (Part 8)
-- Scalar, IN, correlated, EXISTS, and in FROM — with the richer data.
-- ==============================================================================

-- Scalar: students older than the average age
SELECT name, age
FROM   students
WHERE  age > (SELECT AVG(age) FROM students)
ORDER BY age DESC
LIMIT  10;

-- IN: students who took any 300-level course
SELECT name, major
FROM   students
WHERE  sid IN (SELECT e.sid
               FROM   enrollments e
               JOIN   courses c ON e.cid = c.cid
               WHERE  c.level = 300)
ORDER BY name;

-- Correlated: each student's BEST graded course (their personal max points)
SELECT s.name, e.cid, e.grade, e.points
FROM   students s
JOIN   enrollments e ON s.sid = e.sid
WHERE  e.points = (SELECT MAX(points)
                   FROM   enrollments
                   WHERE  sid = s.sid)
ORDER BY s.name
LIMIT  12;

-- NOT EXISTS: departments where no student is enrolled in any course
SELECT d.dept, d.building
FROM   departments d
WHERE  NOT EXISTS (SELECT 1
                   FROM   courses c
                   JOIN   enrollments e ON c.cid = e.cid
                   WHERE  c.dept = d.dept);

-- Subquery in FROM: distribution of course loads
-- (how many students take 1 course, 2 courses, ...)
SELECT n_courses, COUNT(*) AS n_students
FROM (SELECT sid, COUNT(*) AS n_courses
      FROM   enrollments
      GROUP BY sid) AS per_student
GROUP BY n_courses
ORDER BY n_courses;

-- ==============================================================================
-- SECTION 7 — SET OPERATIONS (Part 4)
-- Rosters of two courses, combined three ways.
-- ==============================================================================

-- Both Databases AND Linear Algebra
SELECT sid FROM enrollments WHERE cid = 'C101'
INTERSECT
SELECT sid FROM enrollments WHERE cid = 'M201';

-- Databases but NOT Linear Algebra
SELECT sid FROM enrollments WHERE cid = 'C101'
EXCEPT
SELECT sid FROM enrollments WHERE cid = 'M201';

-- ==============================================================================
-- SECTION 8 — CONSTRAINTS IN ACTION (Part 9) — FAILS ON PURPOSE
-- Run these one at a time and read each error message.
-- ==============================================================================

-- Foreign key: student 999 does not exist
INSERT INTO enrollments VALUES (999, 'C101', 'F25', 'A', 4.0);

-- Foreign key: major must be a real department
INSERT INTO students VALUES (51, 'Nia Okafor', 'Astrology', 1, 18, 'Milton');

-- Primary key: sid 1 is taken
INSERT INTO students VALUES (1, 'Impostor Ada', 'CS', 2, 19, 'Riverton');

-- CHECK: capacity must be positive
INSERT INTO courses VALUES ('X999', 'Ghost Course', 3, 'CS', 100, 0);

-- ==============================================================================
-- SECTION 9 — INSERT, UPDATE, DELETE (Part 9)
-- Rehearse every UPDATE/DELETE WHERE as a SELECT first.
-- ==============================================================================

INSERT INTO students (sid, name, major, year, age, home_city)
VALUES (51, 'Nia Okafor', 'CS', 1, 18, 'Milton');

UPDATE students SET major = 'Math' WHERE sid = 51;

SELECT * FROM students WHERE sid = 51;   -- rehearse...
DELETE FROM students WHERE sid = 51;     -- ...then delete

-- ==============================================================================
-- SECTION 10 — TRANSACTIONS (Part 11)
-- Atomic course swap, then the ROLLBACK safety net.
-- ==============================================================================

BEGIN;
  DELETE FROM enrollments WHERE sid = 1 AND cid = 'M201' AND semester = 'F25';
  INSERT INTO enrollments VALUES (1, 'C102', 'S26', NULL, NULL);
COMMIT;

SELECT * FROM enrollments WHERE sid = 1;

-- ROLLBACK: the undo button
BEGIN;
  DELETE FROM enrollments;                            -- oops, no WHERE!
  SELECT COUNT(*) AS rows_left FROM enrollments;      -- 0 inside the transaction
ROLLBACK;

SELECT COUNT(*) AS rows_after_rollback FROM enrollments;  -- all back

-- ==============================================================================
-- End of script. Re-run Sections 1-2 for a clean reset.
-- ==============================================================================
