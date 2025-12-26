// Task Model
class Task {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final String? assignedTo;
  final DateTime? dueDate;
  final Map<String, dynamic> extractedEntities;
  final List<String> suggestedActions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TaskHistory>? history;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.dueDate,
    required this.extractedEntities,
    required this.suggestedActions,
    required this.createdAt,
    required this.updatedAt,
    this.history,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      assignedTo: json['assigned_to'] as String?,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String)
          : null,
      extractedEntities: json['extracted_entities'] as Map<String, dynamic>? ?? {},
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => TaskHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
      'extracted_entities': extractedEntities,
      'suggested_actions': suggestedActions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? dueDate,
    Map<String, dynamic>? extractedEntities,
    List<String>? suggestedActions,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TaskHistory>? history,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      extractedEntities: extractedEntities ?? this.extractedEntities,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      history: history ?? this.history,
    );
  }
}

// Task History Model
class TaskHistory {
  final String id;
  final String taskId;
  final String action;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final String? changedBy;
  final DateTime changedAt;

  TaskHistory({
    required this.id,
    required this.taskId,
    required this.action,
    this.oldValue,
    this.newValue,
    this.changedBy,
    required this.changedAt,
  });

  factory TaskHistory.fromJson(Map<String, dynamic> json) {
    return TaskHistory(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      action: json['action'] as String,
      oldValue: json['old_value'] as Map<String, dynamic>?,
      newValue: json['new_value'] as Map<String, dynamic>?,
      changedBy: json['changed_by'] as String?,
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }
}

// Create Task Request Model
class CreateTaskRequest {
  final String title;
  final String? description;
  final String? assignedTo;
  final DateTime? dueDate;
  final String? status;

  CreateTaskRequest({
    required this.title,
    this.description,
    this.assignedTo,
    this.dueDate,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      if (status != null) 'status': status,
    };
  }
}

// Update Task Request Model
class UpdateTaskRequest {
  final String? title;
  final String? description;
  final String? status;
  final String? category;
  final String? priority;
  final String? assignedTo;
  final DateTime? dueDate;
  final bool? manualOverride;

  UpdateTaskRequest({
    this.title,
    this.description,
    this.status,
    this.category,
    this.priority,
    this.assignedTo,
    this.dueDate,
    this.manualOverride,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (status != null) map['status'] = status;
    if (category != null) map['category'] = category;
    if (priority != null) map['priority'] = priority;
    if (assignedTo != null) map['assigned_to'] = assignedTo;
    if (dueDate != null) map['due_date'] = dueDate!.toIso8601String();
    if (manualOverride != null) map['manualOverride'] = manualOverride;
    return map;
  }
}

// Task Statistics Model
class TaskStats {
  final Map<String, int> byStatus;
  final Map<String, int> byCategory;
  final Map<String, int> byPriority;
  final int total;

  TaskStats({
    required this.byStatus,
    required this.byCategory,
    required this.byPriority,
    required this.total,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) {
    return TaskStats(
      byStatus: Map<String, int>.from(json['byStatus'] as Map),
      byCategory: Map<String, int>.from(json['byCategory'] as Map),
      byPriority: Map<String, int>.from(json['byPriority'] as Map),
      total: json['total'] as int,
    );
  }
}
