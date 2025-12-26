/**
 * Task Controller
 * Handles HTTP requests for task-related operations
 */

const taskService = require('../services/taskService');
const { validationResult } = require('express-validator');

class TaskController {
  /**
   * Create a new task
   * POST /api/tasks
   */
  async createTask(req, res) {
    try {
      // Validate request
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          success: false,
          errors: errors.array() 
        });
      }

      const task = await taskService.createTask(req.body);

      res.status(201).json({
        success: true,
        message: 'Task created successfully',
        data: task,
      });
    } catch (error) {
      console.error('Create task error:', error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * Get all tasks with filters
   * GET /api/tasks
   */
  async getAllTasks(req, res) {
    try {
      const filters = {
        status: req.query.status,
        category: req.query.category,
        priority: req.query.priority,
        assigned_to: req.query.assigned_to,
      };

      const tasks = await taskService.getAllTasks(filters);

      res.status(200).json({
        success: true,
        count: tasks.length,
        data: tasks,
      });
    } catch (error) {
      console.error('Get tasks error:', error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * Get a single task by ID with history
   * GET /api/tasks/:id
   */
  async getTaskById(req, res) {
    try {
      const { id } = req.params;
      const task = await taskService.getTaskById(id);

      res.status(200).json({
        success: true,
        data: task,
      });
    } catch (error) {
      console.error('Get task error:', error);
      const statusCode = error.message.includes('not found') ? 404 : 500;
      res.status(statusCode).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * Update a task
   * PATCH /api/tasks/:id
   */
  async updateTask(req, res) {
    try {
      // Validate request
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          success: false,
          errors: errors.array() 
        });
      }

      const { id } = req.params;
      const task = await taskService.updateTask(id, req.body);

      res.status(200).json({
        success: true,
        message: 'Task updated successfully',
        data: task,
      });
    } catch (error) {
      console.error('Update task error:', error);
      const statusCode = error.message.includes('not found') ? 404 : 500;
      res.status(statusCode).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * Delete a task
   * DELETE /api/tasks/:id
   */
  async deleteTask(req, res) {
    try {
      const { id } = req.params;
      await taskService.deleteTask(id);

      res.status(200).json({
        success: true,
        message: 'Task deleted successfully',
      });
    } catch (error) {
      console.error('Delete task error:', error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * Get task statistics
   * GET /api/tasks/stats
   */
  async getTaskStats(req, res) {
    try {
      const stats = await taskService.getTaskStats();

      res.status(200).json({
        success: true,
        data: stats,
      });
    } catch (error) {
      console.error('Get stats error:', error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }
}

module.exports = new TaskController();
