import 'package:sqflite/sqflite.dart';
import '../models/bookmark.dart';

/// 收藏数据访问对象
class BookmarkDao {
  final Database _db;

  BookmarkDao(this._db);

  /// 查询所有收藏
  Future<List<Bookmark>> queryAll() async {
    final maps = await _db.query('bookmark', orderBy: 'created_at DESC');
    return maps.map((m) => Bookmark.fromMap(m)).toList();
  }

  /// 按题目ID查询收藏
  Future<Bookmark?> queryByQuestionId(int questionId) async {
    final maps = await _db.query(
      'bookmark',
      where: 'question_id = ?',
      whereArgs: [questionId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Bookmark.fromMap(maps.first);
  }

  /// 插入收藏
  Future<int> insert(Bookmark bookmark) async {
    return await _db.insert('bookmark', bookmark.toMap());
  }

  /// 删除收藏
  Future<int> delete(int questionId) async {
    return await _db.delete(
      'bookmark',
      where: 'question_id = ?',
      whereArgs: [questionId],
    );
  }

  /// 判断是否已收藏
  Future<bool> isBookmarked(int questionId) async {
    final result = await _db.query(
      'bookmark',
      where: 'question_id = ?',
      whereArgs: [questionId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// 按科目/章节分组查询收藏（关联 question 表）
  /// 返回 Map: {subject: {chapter: [{bookmark, stem}]}}
  Future<Map<String, Map<String, List<Map<String, dynamic>>>>> queryGrouped() async {
    final result = await _db.rawQuery('''
      SELECT b.*, q.subject, q.chapter, q.stem
      FROM bookmark b
      INNER JOIN question q ON b.question_id = q.id
      ORDER BY q.subject, q.chapter, b.created_at DESC
    ''');

    final grouped = <String, Map<String, List<Map<String, dynamic>>>>{};
    for (final row in result) {
      final subject = row['subject'] as String;
      final chapter = row['chapter'] as String;

      final data = <String, dynamic>{
        'id': row['id'] as int,
        'question_id': row['question_id'] as int,
        'created_at': row['created_at'] as String,
        'stem': row['stem'] as String,
      };

      grouped.putIfAbsent(subject, () => {});
      grouped[subject]!.putIfAbsent(chapter, () => []);
      grouped[subject]![chapter]!.add(data);
    }
    return grouped;
  }

  /// 删除所有收藏
  Future<int> deleteAll() async {
    return await _db.delete('bookmark');
  }
}
