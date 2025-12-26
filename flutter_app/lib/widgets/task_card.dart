import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onStatusChange;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChange,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'scheduling':
        return Colors.blue;
      case 'finance':
        return Colors.green;
      case 'technical':
        return Colors.orange;
      case 'safety':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.pending;
      case 'pending':
        return Icons.radio_button_unchecked;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: task.status == 'completed'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _getStatusIcon(task.status),
                      color: task.status == 'completed'
                          ? Colors.green
                          : Colors.grey,
                    ),
                    onPressed: onStatusChange,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              // Description
              if (task.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Category and Priority Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      task.category.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: _getCategoryColor(task.category).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _getCategoryColor(task.category),
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(
                      task.priority.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: _getPriorityColor(task.priority).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _getPriorityColor(task.priority),
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Due Date and Assigned To
              Row(
                children: [
                  if (task.dueDate != null) ...[
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(task.dueDate!),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (task.dueDate != null && task.assignedTo != null)
                    const SizedBox(width: 16),
                  if (task.assignedTo != null) ...[
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.assignedTo!,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
