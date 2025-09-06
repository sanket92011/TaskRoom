class Todo {
  final int? id;
  String title;
  DateTime deadline;
  bool isCompleted;
  bool reminderEnabled;
  String? notes;

  Todo({
    this.id,
    required this.title,
    required this.deadline,
    required this.isCompleted,
    this.reminderEnabled = false,
    this.notes,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      deadline: DateTime.parse(
        json['deadline'],
      ).toLocal(), // ✅ convert to local time
      isCompleted: json['is_completed'] ?? false,
      reminderEnabled: json['reminder_enabled'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'deadline': deadline.toUtc().toIso8601String(), // ✅ always UTC with Z
      'is_completed': isCompleted,
      'reminder_enabled': reminderEnabled,
      if (notes != null) 'notes': notes,
    };
  }

  Todo copyWith({
    int? id,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
    bool? reminderEnabled,
    String? notes,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notes: notes ?? this.notes,
    );
  }
}
