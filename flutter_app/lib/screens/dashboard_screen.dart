import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(searchedTasksProvider);
    final stats = ref.watch(taskStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskSense'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(taskListProvider.notifier).refresh();
          ref.refresh(taskStatsProvider);
        },
        child: Column(
          children: [
            // Summary Cards
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: stats.when(
                data: (statsData) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryCard(
                      title: 'Pending',
                      count: statsData.byStatus['pending'] ?? 0,
                      color: Colors.orange,
                    ),
                    _SummaryCard(
                      title: 'In Progress',
                      count: statsData.byStatus['in_progress'] ?? 0,
                      color: Colors.blue,
                    ),
                    _SummaryCard(
                      title: 'Completed',
                      count: statsData.byStatus['completed'] ?? 0,
                      color: Colors.green,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),
            
            // Task List
            Expanded(
              child: tasks.when(
                data: (taskList) {
                  if (taskList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks found',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a new task to get started',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      final task = taskList[index];
                      return TaskCard(
                        task: task,
                        onTap: () => _navigateToTaskDetail(context, task),
                        onStatusChange: () => _changeTaskStatus(task),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading tasks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(taskListProvider.notifier).refresh();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTask(context),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _FilterSection(
              title: 'Status',
              options: const ['pending', 'in_progress', 'completed'],
              provider: statusFilterProvider,
            ),
            _FilterSection(
              title: 'Category',
              options: const ['scheduling', 'finance', 'technical', 'safety', 'general'],
              provider: categoryFilterProvider,
            ),
            _FilterSection(
              title: 'Priority',
              options: const ['high', 'medium', 'low'],
              provider: priorityFilterProvider,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(statusFilterProvider.notifier).state = null;
                  ref.read(categoryFilterProvider.notifier).state = null;
                  ref.read(priorityFilterProvider.notifier).state = null;
                  Navigator.pop(context);
                },
                child: const Text('Clear Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateTask(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const TaskFormScreen()),
    );
    if (result == true) {
      ref.read(taskListProvider.notifier).refresh();
      ref.refresh(taskStatsProvider);
    }
  }

  void _navigateToTaskDetail(BuildContext context, Task task) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );
    if (result == true) {
      ref.read(taskListProvider.notifier).refresh();
      ref.refresh(taskStatsProvider);
    }
  }

  void _changeTaskStatus(Task task) async {
    String newStatus;
    if (task.status == 'pending') {
      newStatus = 'in_progress';
    } else if (task.status == 'in_progress') {
      newStatus = 'completed';
    } else {
      newStatus = 'pending';
    }

    try {
      await ref.read(taskListProvider.notifier).updateTask(
            task.id,
            UpdateTaskRequest(status: newStatus),
          );
      ref.refresh(taskStatsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends ConsumerWidget {
  final String title;
  final List<String> options;
  final StateProvider<String?> provider;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                ref.read(provider.notifier).state = selected ? option : null;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
