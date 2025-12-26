import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedCategory = 'general';
  String _selectedPriority = 'medium';
  String _selectedStatus = 'pending';
  bool _isLoading = false;
  bool _manualOverride = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _assignedToController.text = widget.task!.assignedTo ?? '';
      _selectedDate = widget.task!.dueDate;
      _selectedCategory = widget.task!.category;
      _selectedPriority = widget.task!.priority;
      _selectedStatus = widget.task!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Create Task'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.length > 255) {
                  return 'Title must be less than 255 characters';
                }
                return null;
              },
              maxLength: 255,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Assigned To
            TextFormField(
              controller: _assignedToController,
              decoration: const InputDecoration(
                labelText: 'Assigned To',
                hintText: 'Enter person name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Due Date
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate != null
                      ? DateFormat('MMM dd, yyyy hh:mm a').format(_selectedDate!)
                      : 'Select date',
                  style: _selectedDate != null
                      ? null
                      : TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Manual Override Toggle
            SwitchListTile(
              title: const Text('Manual Override'),
              subtitle: const Text('Manually set category and priority'),
              value: _manualOverride,
              onChanged: (value) {
                setState(() {
                  _manualOverride = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Category (only if manual override)
            if (_manualOverride) ...[
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'scheduling', child: Text('Scheduling')),
                  DropdownMenuItem(value: 'finance', child: Text('Finance')),
                  DropdownMenuItem(value: 'technical', child: Text('Technical')),
                  DropdownMenuItem(value: 'safety', child: Text('Safety')),
                  DropdownMenuItem(value: 'general', child: Text('General')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Priority (only if manual override)
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: const [
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],

            // Status (only for editing)
            if (isEditing) ...[
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],

            // Auto-classification Preview
            if (!_manualOverride && !isEditing) ...[
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Auto-Classification Preview',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.blue[900],
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The system will automatically detect the category and priority based on keywords in your task.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveTask,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Update Task' : 'Create Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isEditing = widget.task != null;

      if (isEditing) {
        // Update task
        final request = UpdateTaskRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _selectedStatus,
          category: _manualOverride ? _selectedCategory : null,
          priority: _manualOverride ? _selectedPriority : null,
          assignedTo: _assignedToController.text.trim().isEmpty
              ? null
              : _assignedToController.text.trim(),
          dueDate: _selectedDate,
          manualOverride: _manualOverride,
        );

        await ref.read(taskListProvider.notifier).updateTask(
              widget.task!.id,
              request,
            );
      } else {
        // Create task
        final request = CreateTaskRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          assignedTo: _assignedToController.text.trim().isEmpty
              ? null
              : _assignedToController.text.trim(),
          dueDate: _selectedDate,
        );

        await ref.read(taskListProvider.notifier).createTask(request);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Task updated successfully' : 'Task created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(taskListProvider.notifier).deleteTask(widget.task!.id);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
