-- TaskSense Database Schema
-- PostgreSQL / Supabase

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT CHECK (category IN ('scheduling', 'finance', 'technical', 'safety', 'general')),
    priority TEXT CHECK (priority IN ('high', 'medium', 'low')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    assigned_to TEXT,
    due_date TIMESTAMP WITH TIME ZONE,
    extracted_entities JSONB DEFAULT '{}',
    suggested_actions JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create task_history table
CREATE TABLE IF NOT EXISTS task_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    action TEXT NOT NULL CHECK (action IN ('created', 'updated', 'status_changed', 'completed', 'deleted')),
    old_value JSONB DEFAULT '{}',
    new_value JSONB DEFAULT '{}',
    changed_by TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_category ON tasks(category);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at);
CREATE INDEX IF NOT EXISTS idx_task_history_task_id ON task_history(task_id);
CREATE INDEX IF NOT EXISTS idx_task_history_changed_at ON task_history(changed_at);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists and create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_tasks_updated_at ON tasks;
CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create function to log task changes to history
CREATE OR REPLACE FUNCTION log_task_history()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO task_history (task_id, action, new_value, changed_by)
        VALUES (NEW.id, 'created', row_to_json(NEW)::jsonb, NEW.assigned_to);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Check if status changed
        IF (OLD.status IS DISTINCT FROM NEW.status) THEN
            IF (NEW.status = 'completed') THEN
                INSERT INTO task_history (task_id, action, old_value, new_value, changed_by)
                VALUES (NEW.id, 'completed', row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, NEW.assigned_to);
            ELSE
                INSERT INTO task_history (task_id, action, old_value, new_value, changed_by)
                VALUES (NEW.id, 'status_changed', row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, NEW.assigned_to);
            END IF;
        ELSE
            INSERT INTO task_history (task_id, action, old_value, new_value, changed_by)
            VALUES (NEW.id, 'updated', row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb, NEW.assigned_to);
        END IF;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO task_history (task_id, action, old_value, changed_by)
        VALUES (OLD.id, 'deleted', row_to_json(OLD)::jsonb, OLD.assigned_to);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists and create trigger to automatically log task changes
DROP TRIGGER IF EXISTS log_task_changes ON tasks;
CREATE TRIGGER log_task_changes
    AFTER INSERT OR UPDATE OR DELETE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION log_task_history();

-- Insert sample data for testing
INSERT INTO tasks (title, description, category, priority, status, assigned_to, due_date, extracted_entities, suggested_actions)
VALUES 
    (
        'Schedule urgent meeting with team today',
        'Discuss Q4 budget allocation with engineering team',
        'scheduling',
        'high',
        'pending',
        'John Doe',
        CURRENT_TIMESTAMP + INTERVAL '4 hours',
        '{"people": ["team"], "keywords": ["meeting", "budget"], "urgency_indicators": ["urgent", "today"]}',
        '["Block calendar", "Send invite", "Prepare agenda", "Set reminder"]'
    ),
    (
        'Fix critical bug in payment system',
        'Users unable to process transactions',
        'technical',
        'high',
        'in_progress',
        'Jane Smith',
        CURRENT_TIMESTAMP + INTERVAL '2 hours',
        '{"keywords": ["bug", "payment", "transactions"], "urgency_indicators": ["critical"]}',
        '["Diagnose issue", "Check resources", "Assign technician", "Document fix"]'
    ),
    (
        'Review budget for next quarter',
        'Analyze spending and prepare financial report',
        'finance',
        'medium',
        'pending',
        'Mike Johnson',
        CURRENT_TIMESTAMP + INTERVAL '1 week',
        '{"keywords": ["budget", "financial"], "time_indicators": ["next quarter"]}',
        '["Check budget", "Get approval", "Generate invoice", "Update records"]'
    ),
    (
        'Safety inspection of construction site',
        'Conduct monthly safety compliance check',
        'safety',
        'high',
        'pending',
        'Sarah Wilson',
        CURRENT_TIMESTAMP + INTERVAL '2 days',
        '{"keywords": ["safety", "inspection", "compliance"], "location": ["construction site"]}',
        '["Conduct inspection", "File report", "Notify supervisor", "Update checklist"]'
    );

-- Create a view for task summary
CREATE OR REPLACE VIEW task_summary AS
SELECT 
    status,
    category,
    priority,
    COUNT(*) as count
FROM tasks
GROUP BY status, category, priority;
