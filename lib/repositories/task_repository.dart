import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../core/database/database_helper.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertTask(Task task) async {
    Database db = await _dbHelper.database;
    return await db.insert(DatabaseHelper.tableTasks, task.toMap());
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
    return await db.update(
      DatabaseHelper.tableTasks,
      task.toMap(),
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    Database db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableTasks,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
  }
}
