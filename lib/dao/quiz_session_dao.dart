import 'package:sqflite/sqflite.dart';
import '../models/quiz_session.dart';

/// 答题会话数据访问对象
class QuizSessionDao {
  final Database _db;

  QuizSessionDao(this._db);

  /// 插入会话
  Future<int> insert(QuizSession session) async {
    return await _db.insert('quiz_session', session.toMap());
  }

  /// 更新会话
  Future<int> update(QuizSession session) async {
    return await _db.update(
      'quiz_session',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  /// 按ID查询
  Future<QuizSession?> queryById(int id) async {
    final maps = await _db.query(
      'quiz_session',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return QuizSession.fromMap(maps.first);
  }

  /// 删除会话
  Future<int> delete(int id) async {
    return await _db.delete('quiz_session', where: 'id = ?', whereArgs: [id]);
  }
}
