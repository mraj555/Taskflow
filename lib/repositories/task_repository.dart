import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../core/database/database_helper.dart';
import '../core/services/sync_service.dart';
import '../core/services/notification_service.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertTask(Task task) async {
    Database db = await _dbHelper.database;
    final id = await db.insert(DatabaseHelper.tableTasks, task.toMap());
    
    // Sync to cloud
    await SyncService().pushTask(task);

    // Schedule notification if due date exists and is in the future
    if (task.dueDate != null && !task.isCompleted) {
      await NotificationService().scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder: ${task.title}',
        body: task.description ?? 'You have a task due soon!',
        scheduledDate: task.dueDate!,
      );
    }

    return id;
  }

  Future<List<Task>> getAllTasks() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableTasks);
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> updateTask(Task task) async {
    Database db = await _dbHelper.database;
    final result = await db.update(
      DatabaseHelper.tableTasks,
      task.toMap(),
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [task.id],
    );

    // Sync to cloud
    await SyncService().pushTask(task);

    // Update notification
    await NotificationService().cancelNotification(task.id.hashCode);
    if (task.dueDate != null && !task.isCompleted) {
      await NotificationService().scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder: ${task.title}',
        body: task.description ?? 'You have a task due soon!',
        scheduledDate: task.dueDate!,
      );
    }

    return result;
  }

  Future<int> deleteTask(String id) async {
    Database db = await _dbHelper.database;
    final result = await db.delete(
      DatabaseHelper.tableTasks,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );

    // Sync to cloud
    await SyncService().deleteTask(id);

    // Cancel notification
    await NotificationService().cancelNotification(id.hashCode);

    return result;
  }
}
