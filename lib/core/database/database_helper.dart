import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "TaskFlow.db";
  static const _databaseVersion = 1;

  static const tableTasks = 'tasks';
  static const tableCategories = 'categories';

  // Task Table Columns
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnDueDate = 'dueDate';
  static const columnPriority = 'priority';
  static const columnIsCompleted = 'isCompleted';
  static const columnCategoryId = 'categoryId';

  // Category Table Columns
  static const categoryColumnId = 'id';
  static const categoryColumnName = 'name';
  static const categoryColumnColor = 'color';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategories (
        $categoryColumnId TEXT PRIMARY KEY,
        $categoryColumnName TEXT NOT NULL,
        $categoryColumnColor INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTasks (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnDueDate TEXT,
        $columnPriority INTEGER NOT NULL,
        $columnIsCompleted INTEGER NOT NULL,
        $columnCategoryId TEXT,
        FOREIGN KEY ($columnCategoryId) REFERENCES $tableCategories ($categoryColumnId) ON DELETE SET NULL
      )
    ''');
  }
}
