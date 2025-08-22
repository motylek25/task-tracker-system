-- Task Tracker System - Schema Creation
-- Creates database, tables, indexes, and triggers

-- Create database
CREATE DATABASE IF NOT EXISTS task_tracker;
USE task_tracker;

-- Table: users
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: projects
CREATE TABLE projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: tasks
CREATE TABLE tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('open', 'in progress', 'review', 'done') DEFAULT 'open',
    priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    assignee_id INT,
    project_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assignee_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);

-- Table: comments
CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    author_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Table: task_history (for auditing changes)
CREATE TABLE task_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    changed_field VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_assignee_id ON tasks(assignee_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_comments_task_id ON comments(task_id);
CREATE INDEX idx_task_history_task_id ON task_history(task_id);
CREATE INDEX idx_task_history_changed_at ON task_history(changed_at);

-- Trigger for tracking task updates
DELIMITER //

CREATE TRIGGER track_task_changes
AFTER UPDATE ON tasks
FOR EACH ROW
BEGIN
    -- Track status changes
    IF OLD.status != NEW.status THEN
        INSERT INTO task_history (task_id, changed_field, old_value, new_value, changed_by)
        VALUES (NEW.task_id, 'status', OLD.status, NEW.status, NEW.assignee_id);
    END IF;
    
    -- Track priority changes
    IF OLD.priority != NEW.priority THEN
        INSERT INTO task_history (task_id, changed_field, old_value, new_value, changed_by)
        VALUES (NEW.task_id, 'priority', OLD.priority, NEW.priority, NEW.assignee_id);
    END IF;
    
    -- Track assignee changes
    IF OLD.assignee_id != NEW.assignee_id THEN
        INSERT INTO task_history (task_id, changed_field, old_value, new_value, changed_by)
        VALUES (NEW.task_id, 'assignee_id', OLD.assignee_id, NEW.assignee_id, NEW.assignee_id);
    END IF;
    
    -- Track title changes
    IF OLD.title != NEW.title THEN
        INSERT INTO task_history (task_id, changed_field, old_value, new_value, changed_by)
        VALUES (NEW.task_id, 'title', OLD.title, NEW.title, NEW.assignee_id);
    END IF;
END;
//

DELIMITER ;