-- Task Tracker System - Sample Data
-- Populates database with sample data for testing

USE task_tracker;

-- Insert sample users
INSERT INTO users (username, email, full_name) VALUES
('john_doe', 'john.doe@example.com', 'John Doe'),
('jane_smith', 'jane.smith@example.com', 'Jane Smith'),
('bob_wilson', 'bob.wilson@example.com', 'Bob Wilson'),
('sara_johnson', 'sara.johnson@example.com', 'Sara Johnson');

-- Insert sample projects
INSERT INTO projects (name, description) VALUES
('Website Redesign', 'Complete redesign of company website with modern UI/UX'),
('Mobile App Development', 'Development of a cross-platform mobile application'),
('Database Migration', 'Migration from legacy database system to modern solution');

-- Insert sample tasks
INSERT INTO tasks (title, description, status, priority, assignee_id, project_id) VALUES
('Create wireframes', 'Design initial wireframes for all main pages', 'in progress', 'high', 1, 1),
('Develop login API', 'Create backend API for user authentication', 'open', 'critical', 2, 2),
('Design database schema', 'Plan new database structure', 'done', 'medium', 3, 3),
('Implement responsive design', 'Ensure website works on all device sizes', 'open', 'high', 4, 1),
('Write unit tests', 'Create comprehensive test suite for mobile app', 'review', 'medium', 2, 2);

-- Insert sample comments
INSERT INTO comments (task_id, author_id, comment_text) VALUES
(1, 1, 'I think we should consider adding a dark mode option'),
(1, 2, 'Good point. Let''s discuss in the next meeting'),
(2, 3, 'We need to ensure OAuth2 support for social login'),
(3, 4, 'Schema has been reviewed and approved by the team'),
(5, 2, 'Tests are passing but we need to improve coverage');

-- Update some tasks to trigger the history tracking
UPDATE tasks SET status = 'done', assignee_id = 1 WHERE task_id = 3;
UPDATE tasks SET priority = 'critical', assignee_id = 2 WHERE task_id = 2;
UPDATE tasks SET status = 'in progress' WHERE task_id = 4;