import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/model/todo.dart';

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final Function(bool) onToggle;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        todo.deadline.isBefore(DateTime.now()) && !todo.isCompleted;
    final isToday =
        DateFormat('yyyy-MM-dd').format(todo.deadline) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    Color statusColor;
    IconData statusIcon;

    if (todo.isCompleted) {
      statusColor = const Color(0xFF4CAF50);
      statusIcon = Icons.check_circle;
    } else if (isOverdue) {
      statusColor = const Color(0xFFE53E3E);
      statusIcon = Icons.cancel;
    } else {
      statusColor = const Color(0xFFFF9800);
      statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          /// Main Card
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header Row (status + title + reminder icon)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => onToggle(!todo.isCompleted),
                          child: Icon(statusIcon, color: statusColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: todo.isCompleted
                                  ? Colors.grey
                                  : Colors.black87,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.lightGreenAccent.withOpacity(
                            0.3,
                          ),
                          child: IconButton(
                            onPressed: () {
                              onToggle(!todo.isCompleted);
                            },
                            icon: Icon(
                              todo.isCompleted ? Icons.check : Icons.check,
                              size: 20,
                              color: todo.isCompleted
                                  ? Colors.green
                                  : Colors.black,
                            ),
                          ),
                        ),

                        SizedBox(width: 10),
                        if (todo.reminderEnabled)
                          Icon(
                            Icons.notifications_active,
                            color: Colors.grey.withOpacity(0.6),
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, y • h:mm a').format(todo.deadline),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFFF9800),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: todo.reminderEnabled
                            ? const Color(0xFFE8F5E8)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: todo.reminderEnabled
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reminder',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                todo.reminderEnabled
                                    ? '1 hour before'
                                    : 'Disabled',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (todo.isCompleted)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.verified,
                color: const Color(0xFF4CAF50),
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}
