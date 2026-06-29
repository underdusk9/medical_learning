import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

/// 数据库辅助类，单例模式
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE question (
        id INTEGER PRIMARY KEY,
        type TEXT NOT NULL,
        subject TEXT NOT NULL,
        section TEXT,
        chapter TEXT NOT NULL,
        topic TEXT,
        stem TEXT NOT NULL,
        options TEXT NOT NULL,
        answer TEXT NOT NULL,
        analysis TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE bookmark (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE note (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE quiz_session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        question_ids TEXT NOT NULL,
        current_index INTEGER NOT NULL DEFAULT 0,
        answers TEXT NOT NULL DEFAULT '{}',
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_question_filter ON question(subject, section, chapter, topic);',
    );
    await db.execute(
      'CREATE INDEX idx_bookmark_question ON bookmark(question_id);',
    );
    await db.execute(
      'CREATE INDEX idx_note_question ON note(question_id);',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE question ADD COLUMN section TEXT');
      // 已有数据无 section 值，seed_service 会检测到并重导
    }
    if (oldVersion < 3) {
      // v3：新增血液系统题库，重置 seed 标志让 seed_service 自动导入新文件
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefDbSeeded, false);
    }
    if (oldVersion < 4) {
      // v4：新增生理学题库（474 题），重置 seed 标志
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefDbSeeded, false);
    }
    if (oldVersion < 5) {
      // v5：新增内科学题库（内分泌+风湿+中毒+血液+泌尿，464 题）
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefDbSeeded, false);
    }
  }

  /// 重置数据库（删除后重新创建）
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);
    await deleteDatabase(path);
    _database = await _initDatabase();
  }
}
