class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? deadline;
  final String status;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.deadline,
    this.status = 'todo',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'deadline': deadline?.toIso8601String(),
        'status': status,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      status: json['status'] ?? 'todo',
    );
  }
}