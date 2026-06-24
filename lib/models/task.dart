class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority; // 0 = Low, 1 = Medium, 2 = High
  final bool isCompleted;
  final String? categoryId;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 0,
    this.isCompleted = false,
    this.categoryId,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    bool? isCompleted,
    String? categoryId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'categoryId': categoryId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1,
      categoryId: map['categoryId'],
    );
  }
}
