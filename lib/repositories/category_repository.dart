import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../core/database/database_helper.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertCategory(TaskCategory category) async {
    Database db = await _dbHelper.database;
    return await db.insert(DatabaseHelper.tableCategories, category.toMap());
  }

  Future<List<TaskCategory>> getAllCategories() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableCategories);
    return List.generate(maps.length, (i) {
      return TaskCategory.fromMap(maps[i]);
    });
  }

  Future<int> deleteCategory(String id) async {
    Database db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableCategories,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
  }
}
