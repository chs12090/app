import 'package:profocus/models/task.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final DateTime? deadline;
  final String priority;
  final List<Task> tasks;
  double progress; // Made mutable to allow updates

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.deadline,
    required this.priority,
    required this.tasks,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'deadline': deadline?.toIso8601String(),
        'priority': priority,
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'progress': progress,
      };

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      priority: json['priority'] ?? 'Medium',
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((task) => Task.fromJson(Map<String, dynamic>.from(task)))
              .toList() ??
          [],
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}