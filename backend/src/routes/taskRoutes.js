/**
 * Task Routes
 * Defines all routes for task operations
 */

const express = require('express');
const { body } = require('express-validator');
const taskController = require('../controllers/taskController');

const router = express.Router();

// Validation rules
const createTaskValidation = [
  body('title')
    .trim()
    .notEmpty()
    .withMessage('Title is required')
    .isLength({ max: 255 })
    .withMessage('Title must be less than 255 characters'),
  body('description')
    .optional()
    .trim(),
  body('assigned_to')
    .optional()
    .trim(),
  body('due_date')
    .optional()
    .isISO8601()
    .withMessage('Due date must be a valid ISO 8601 date'),
  body('status')
    .optional()
    .isIn(['pending', 'in_progress', 'completed'])
    .withMessage('Status must be pending, in_progress, or completed'),
];

const updateTaskValidation = [
  body('title')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Title cannot be empty')
    .isLength({ max: 255 })
    .withMessage('Title must be less than 255 characters'),
  body('description')
    .optional()
    .trim(),
  body('status')
    .optional()
    .isIn(['pending', 'in_progress', 'completed'])
    .withMessage('Status must be pending, in_progress, or completed'),
  body('category')
    .optional()
    .isIn(['scheduling', 'finance', 'technical', 'safety', 'general'])
    .withMessage('Invalid category'),
  body('priority')
    .optional()
    .isIn(['high', 'medium', 'low'])
    .withMessage('Invalid priority'),
  body('assigned_to')
    .optional()
    .trim(),
  body('due_date')
    .optional()
    .isISO8601()
    .withMessage('Due date must be a valid ISO 8601 date'),
];

// Routes
// Note: Stats route must be before :id route to avoid treating 'stats' as an id
router.get('/stats', taskController.getTaskStats.bind(taskController));

router.post('/', createTaskValidation, taskController.createTask.bind(taskController));
router.get('/', taskController.getAllTasks.bind(taskController));
router.get('/:id', taskController.getTaskById.bind(taskController));
router.patch('/:id', updateTaskValidation, taskController.updateTask.bind(taskController));
router.delete('/:id', taskController.deleteTask.bind(taskController));

module.exports = router;
