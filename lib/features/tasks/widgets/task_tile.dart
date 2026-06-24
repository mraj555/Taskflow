import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/task.dart';
import '../../../providers/task_provider.dart';

class TaskTile extends ConsumerWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskTile({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    Color priorityColor;
    switch (task.priority) {
      case 2:
        priorityColor = Colors.red;
        break;
      case 1:
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) {
            ref.read(taskProvider.notifier).toggleTaskCompletion(task);
          },
          shape: const CircleBorder(),
          activeColor: theme.colorScheme.primary,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: task.isCompleted ? Colors.grey : null),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (task.dueDate != null) ...[
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isOverdue ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, y').format(task.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey,
                      fontWeight: isOverdue
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.priority == 2
                        ? 'High'
                        : task.priority == 1
                        ? 'Medium'
                        : 'Low',
                    style: TextStyle(
                      fontSize: 10,
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            ref.read(taskProvider.notifier).deleteTask(task.id);
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
