-- Task Tracker System - Analytical Queries
-- Example queries for data analysis and reporting

USE task_tracker;

-- 1. Tasks count by status in each project
SELECT 
    p.name as project_name,
    t.status,
    COUNT(t.task_id) as task_count
FROM tasks t
JOIN projects p ON t.project_id = p.project_id
GROUP BY p.name, t.status
ORDER BY p.name, t.status;

-- 2. Most active users (by number of changes made)
SELECT 
    u.user_id,
    u.full_name,
    u.username,
    COUNT(th.history_id) as change_count
FROM task_history th
JOIN users u ON th.changed_by = u.user_id
GROUP BY u.user_id, u.full_name, u.username
ORDER BY change_count DESC
LIMIT 10;

-- 3. Task completion time analysis
WITH task_completion AS (
    SELECT 
        t.task_id,
        t.title,
        t.created_at as task_created,
        MAX(th.changed_at) as last_status_change
    FROM tasks t
    LEFT JOIN task_history th ON t.task_id = th.task_id AND th.changed_field = 'status'
    WHERE t.status = 'done'
    GROUP BY t.task_id, t.title, t.created_at
)
SELECT 
    task_id,
    title,
    task_created,
    last_status_change,
    TIMESTAMPDIFF(HOUR, task_created, last_status_change) as hours_to_complete
FROM task_completion
ORDER BY hours_to_complete DESC;

-- 4. Most commented tasks
SELECT 
    t.task_id,
    t.title,
    COUNT(c.comment_id) as comment_count
FROM tasks t
LEFT JOIN comments c ON t.task_id = c.task_id
GROUP BY t.task_id, t.title
HAVING comment_count > 0
ORDER BY comment_count DESC;

-- 5. Full audit trail for a specific task
SELECT 
    th.changed_at,
    u.username as changed_by,
    th.changed_field,
    th.old_value,
    th.new_value
FROM task_history th
JOIN users u ON th.changed_by = u.user_id
WHERE th.task_id = 1  -- Replace with specific task ID
ORDER BY th.changed_at DESC;

-- 6. Priority distribution across projects
SELECT 
    p.name as project_name,
    t.priority,
    COUNT(t.task_id) as task_count
FROM tasks t
JOIN projects p ON t.project_id = p.project_id
GROUP BY p.name, t.priority
ORDER BY p.name, 
         CASE t.priority 
             WHEN 'critical' THEN 1
             WHEN 'high' THEN 2
             WHEN 'medium' THEN 3
             WHEN 'low' THEN 4
         END;

-- 7. User workload (number of tasks assigned)
SELECT 
    u.user_id,
    u.full_name,
    u.username,
    COUNT(t.task_id) as assigned_tasks
FROM users u
LEFT JOIN tasks t ON u.user_id = t.assignee_id
GROUP BY u.user_id, u.full_name, u.username
ORDER BY assigned_tasks DESC;

-- 8. Recent activity timeline
(SELECT 
    'TASK_CREATED' as activity_type,
    task_id as item_id,
    title as description,
    created_at as timestamp,
    assignee_id as user_id
FROM tasks)
UNION ALL
(SELECT 
    'STATUS_CHANGE' as activity_type,
    task_id as item_id,
    CONCAT('Status changed from ', old_value, ' to ', new_value) as description,
    changed_at as timestamp,
    changed_by as user_id
FROM task_history 
WHERE changed_field = 'status')
ORDER BY timestamp DESC
LIMIT 20;