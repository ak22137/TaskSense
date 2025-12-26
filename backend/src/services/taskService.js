/**
 * Task Service
 * Handles all business logic related to tasks
 */

const supabase = require('../config/database');
const classificationService = require('./classificationService');

class TaskService {
  /**
   * Create a new task with auto-classification
   * @param {Object} taskData - Task data
   * @returns {Object} Created task
   */
  async createTask(taskData) {
    try {
      // Auto-classify the task
      const classification = classificationService.classifyTask(
        taskData.title,
        taskData.description
      );

      // Prepare task object
      const task = {
        title: taskData.title,
        description: taskData.description || null,
        category: classification.category,
        priority: classification.priority,
        status: taskData.status || 'pending',
        assigned_to: taskData.assigned_to || null,
        due_date: taskData.due_date || null,
        extracted_entities: classification.extracted_entities,
        suggested_actions: classification.suggested_actions,
      };

      // Insert into database
      const { data, error } = await supabase
        .from('tasks')
        .insert([task])
        .select()
        .single();

      if (error) throw error;

      return data;
    } catch (error) {
      throw new Error(`Failed to create task: ${error.message}`);
    }
  }

  /**
   * Get all tasks with optional filtering
   * @param {Object} filters - Filter options
   * @returns {Array} List of tasks
   */
  async getAllTasks(filters = {}) {
    try {
      let query = supabase.from('tasks').select('*');

      // Apply filters
      if (filters.status) {
        query = query.eq('status', filters.status);
      }
      if (filters.category) {
        query = query.eq('category', filters.category);
      }
      if (filters.priority) {
        query = query.eq('priority', filters.priority);
      }
      if (filters.assigned_to) {
        query = query.eq('assigned_to', filters.assigned_to);
      }

      // Order by created_at descending
      query = query.order('created_at', { ascending: false });

      const { data, error } = await query;

      if (error) throw error;

      return data;
    } catch (error) {
      throw new Error(`Failed to fetch tasks: ${error.message}`);
    }
  }

  /**
   * Get a single task by ID with history
   * @param {string} taskId - Task ID
   * @returns {Object} Task with history
   */
  async getTaskById(taskId) {
    try {
      // Get task
      const { data: task, error: taskError } = await supabase
        .from('tasks')
        .select('*')
        .eq('id', taskId)
        .single();

      if (taskError) throw taskError;
      if (!task) throw new Error('Task not found');

      // Get task history
      const { data: history, error: historyError } = await supabase
        .from('task_history')
        .select('*')
        .eq('task_id', taskId)
        .order('changed_at', { ascending: false });

      if (historyError) throw historyError;

      return {
        ...task,
        history: history || [],
      };
    } catch (error) {
      throw new Error(`Failed to fetch task: ${error.message}`);
    }
  }

  /**
   * Update a task
   * @param {string} taskId - Task ID
   * @param {Object} updates - Fields to update
   * @returns {Object} Updated task
   */
  async updateTask(taskId, updates) {
    try {
      // Remove fields that shouldn't be updated directly
      const allowedFields = [
        'title',
        'description',
        'status',
        'assigned_to',
        'due_date',
        'category',
        'priority',
      ];

      const updateData = {};
      for (const field of allowedFields) {
        if (updates[field] !== undefined) {
          updateData[field] = updates[field];
        }
      }

      // If title or description changed, re-classify (unless manually overridden)
      if ((updates.title || updates.description) && !updates.manualOverride) {
        const { data: currentTask } = await supabase
          .from('tasks')
          .select('title, description')
          .eq('id', taskId)
          .single();

        const newTitle = updates.title || currentTask.title;
        const newDescription = updates.description || currentTask.description;

        const classification = classificationService.classifyTask(newTitle, newDescription);
        
        // Only update category/priority if not manually specified
        if (!updates.category) updateData.category = classification.category;
        if (!updates.priority) updateData.priority = classification.priority;
        updateData.extracted_entities = classification.extracted_entities;
        updateData.suggested_actions = classification.suggested_actions;
      }

      // Update task
      const { data, error } = await supabase
        .from('tasks')
        .update(updateData)
        .eq('id', taskId)
        .select()
        .single();

      if (error) throw error;
      if (!data) throw new Error('Task not found');

      return data;
    } catch (error) {
      throw new Error(`Failed to update task: ${error.message}`);
    }
  }

  /**
   * Delete a task
   * @param {string} taskId - Task ID
   * @returns {boolean} Success status
   */
  async deleteTask(taskId) {
    try {
      const { error } = await supabase
        .from('tasks')
        .delete()
        .eq('id', taskId);

      if (error) throw error;

      return true;
    } catch (error) {
      throw new Error(`Failed to delete task: ${error.message}`);
    }
  }

  /**
   * Get task statistics
   * @returns {Object} Task statistics
   */
  async getTaskStats() {
    try {
      const { data, error } = await supabase
        .from('tasks')
        .select('status, category, priority');

      if (error) throw error;

      const stats = {
        byStatus: { pending: 0, in_progress: 0, completed: 0 },
        byCategory: { scheduling: 0, finance: 0, technical: 0, safety: 0, general: 0 },
        byPriority: { high: 0, medium: 0, low: 0 },
        total: data.length,
      };

      data.forEach((task) => {
        if (task.status) stats.byStatus[task.status]++;
        if (task.category) stats.byCategory[task.category]++;
        if (task.priority) stats.byPriority[task.priority]++;
      });

      return stats;
    } catch (error) {
      throw new Error(`Failed to fetch task stats: ${error.message}`);
    }
  }
}

module.exports = new TaskService();
