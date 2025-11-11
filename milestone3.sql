-- CPSC 3300 Project Milestone 3 
-- To-Do list website
-- Target DBMS: MySQL server on cssql.seattleu.edu

use testdb;

DROP TABLE IF EXISTS Notes;
DROP TABLE IF EXISTS Tasks;
DROP TABLE IF EXISTS Todo_List;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Users;

-- USERS
CREATE TABLE Users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

-- CATEGORY
CREATE TABLE Category (
  category_id  INT AUTO_INCREMENT  PRIMARY KEY,
  name        VARCHAR(60) NOT NULL,
  type        VARCHAR(40)
);


-- LIST
CREATE TABLE Todo_List (
  todo_list_id   INT AUTO_INCREMENT  PRIMARY KEY,
  user_id      INT NOT NULL,
  list_name         VARCHAR(100) NOT NULL,
FOREIGN KEY (user_id) REFERENCES Users(user_id)
    ON DELETE CASCADE
);

-- TASK
CREATE TABLE Tasks (
    task_id      INT AUTO_INCREMENT PRIMARY KEY,
    category_id  INT NOT NULL,
    user_id      INT NOT NULL,
    todo_list_id INT NOT NULL,
    task_name         VARCHAR(200) NOT NULL,
    priority     ENUM('Low','Medium','High') NOT NULL DEFAULT 'Medium',
    due_date     DATE,
    complete     TINYINT(1) NOT NULL DEFAULT 0,

    FOREIGN KEY (category_id)  REFERENCES Category(category_id),
    FOREIGN KEY (user_id)      REFERENCES Users(user_id),
    FOREIGN KEY (todo_list_id) REFERENCES Todo_List(todo_list_id)
);

-- NOTES
CREATE TABLE Notes (
  note_id   INT AUTO_INCREMENT PRIMARY KEY,
  task_id   INT NOT NULL,
  user_id   INT NOT NULL,
  note_text TEXT NOT NULL,

  FOREIGN KEY (task_id) REFERENCES Tasks(task_id),
  FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ---------------------------
-- Users sample data (10)
-- ---------------------------
INSERT INTO Users (username, email, password_hash) VALUES
('alice',   'alice@example.com',   'hash_alice'),
('bob',     'bob@example.com',     'hash_bob'),
('carol',   'carol@example.com',   'hash_carol'),
('david',   'david@example.com',   'hash_david'),
('eric',    'eric@example.com',    'hash_eric'),
('fatima',  'fatima@example.com',  'hash_fatima'),
('grace',   'grace@example.com',   'hash_grace'),
('helen',   'helen@example.com',   'hash_helen'),
('ivan',    'ivan@example.com',    'hash_ivan'),
('judy',    'judy@example.com',    'hash_judy');

-- ---------------------------
-- Category sample data (10)
-- ---------------------------
INSERT INTO Category (name, type) VALUES
('Personal','General'),
('School','Academic'),
('Work','Professional'),
('Fitness','Health'),
('Errands','Personal'),
('Finance','Personal'),
('Health','Medical'),
('Study','Academic'),
('Project','Professional'),
('Travel','Leisure');

-- ---------------------------
-- TodoLists sample data (10)
-- ---------------------------
INSERT INTO Todo_List (user_id, list_name) VALUES
(1,'Alice - Personal'),
(1,'Alice - School'),
(2,'Bob - Work'),
(2,'Bob - Grocery'),
(3,'Carol - Personal'),
(4,'David - Personal'),
(5,'Eric - Startup'),
(6,'Fatima - School'),
(7,'Grace - Personal'),
(8,'Helen - Fitness');


-- ---------------------------
-- Tasks sample data (10)
-- ---------------------------
INSERT INTO Tasks (category_id, user_id, todo_list_id, task_name, priority, due_date, complete) VALUES
(6, 1, 1,  'Pay rent', 'High', '2025-11-01', 1),
(1, 1, 1, 'Call mom', 'Low', '2025-11-03', 0),
(2, 1, 2, 'Finish DB homework', 'High', '2025-11-10', 0),
(3, 2, 3, 'Prepare report', 'High', '2025-11-15', 0),
(5, 2, 4, 'Buy milk', 'Medium', '2025-11-02', 1),
(7, 3, 5, 'Book dentist', 'Medium', '2025-11-25' ,0),
(4, 4, 6, 'Gym session', 'Low', '2025-11-05', 1),
(9, 5, 7, 'Deploy MVP', 'High', '2025-11-20', 0),
(8, 6, 8, 'Study for midterm', 'High', '2025-11-08', 1),
(10, 7, 9, 'Plan weekend trip', 'Low', '2025-11-12', 0),
(2, 1, 2, 'Read textbook', 'Medium', '2025-11-07', 1),
(3 , 2, 3, 'Client follow-up', 'Medium', '2025-11-04', 1),
(4, 8, 10, 'Morning run', 'Medium', '2025-11-03', 1),
(8, 6, 8, 'Group project sync', 'High', '2025-11-06', 0),
(9, 5, 7, 'Investor pitch deck', 'High', '2025-11-18', 0),
(3,  5, 7, 'Code review', 'High', '2025-11-12', 0);

-- ---------------------------
-- Notes sample data (10)
-- ---------------------------
INSERT INTO Notes (task_id, user_id, note_text) VALUES
(1,1,'Paid via bank transfer'),
(2,1,'Call after 7pm'),
(3,1,'Add ERD screenshot'),
(4,2,'Need numbers from finance'),
(5,2,'Also get eggs and bread'),
(6,3,'Insurance card in wallet'),
(7,4,'Stretch before workout'),
(8,5,'Deploy behind feature flag'),
(9,6,'Study chapters 1-5'),
(10,7,'Check weather before trip');


-- 3.1 
-- (Alice’s tasks with list name, completion, due date, priority)
SELECT
  u.username,
  tl.list_name        AS list_name,
  t.task_id,
  t.task_name         AS task_title,
  t.complete,
  t.due_date,
  t.priority
FROM Users u
JOIN Todo_List tl ON u.user_id = tl.user_id
JOIN Tasks t      ON tl.todo_list_id = t.todo_list_id
WHERE u.username = 'alice'
ORDER BY t.due_date;


-- 3.2
-- This SQL statement counts how many total tasks each user has in the system.
SELECT 
    u.username,
    COUNT(t.task_id) AS total_tasks
FROM Users u
JOIN Tasks t ON u.user_id = t.user_id
GROUP BY u.username;

-- 3.3
-- This query lists all users who have at least one High-priority task.
SELECT username
FROM Users
WHERE user_id IN (
    SELECT user_id
    FROM Tasks
    WHERE priority = 'High'
    );
    
    
-- ----------------------------------------------
-- Q3.4 GROUP BY + HAVING
-- Feature: Flag overloaded lists:
-- lists with at least 3 HIGH-priority tasks.
-- ----------------------------------------------
SELECT
    tl.todo_list_id,
    tl.list_name,
    u.username,
    COUNT(t.task_id) AS high_priority_tasks
FROM Todo_List tl
JOIN Users u ON tl.user_id = u.user_id
JOIN Tasks t ON tl.todo_list_id = t.todo_list_id
WHERE t.priority = 'High'
GROUP BY tl.todo_list_id, tl.list_name, u.username
HAVING COUNT(t.task_id) >= 3;

-- ----------------------------------------------
-- Q3.5 LEFT OUTER JOIN
-- Feature: Admin view:
-- show all users (even if they never created a list)
-- and how many tasks they have in total.
-- 4----------------------------------------------
SELECT
    u.username,
    COUNT(t.task_id) AS total_tasks
FROM Users u
LEFT JOIN Todo_List tl ON u.user_id = tl.user_id
LEFT JOIN Tasks t ON tl.todo_list_id = t.todo_list_id
GROUP BY u.username
ORDER BY total_tasks DESC;

