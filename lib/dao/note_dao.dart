import 'package:sqflite/sqflite.dart';
import '../models/note.dart';

/// 笔记数据访问对象
class NoteDao {
  final Database _db;

  NoteDao(this._db);

  /// 查询所有笔记
  Future<List<Note>> queryAll() async {
    final maps = await _db.query('note', orderBy: 'updated_at DESC');
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  /// 按题目ID查询笔记
  Future<Note?> queryByQuestionId(int questionId) async {
    final maps = await _db.query(
      'note',
      where: 'question_id = ?',
      whereArgs: [questionId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  /// 插入笔记
  Future<int> insert(Note note) async {
    return await _db.insert('note', note.toMap());
  }

  /// 更新笔记
  Future<int> update(Note note) async {
    return await _db.update(
      'note',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// 删除笔记
  Future<int> delete(int id) async {
    return await _db.delete('note', where: 'id = ?', whereArgs: [id]);
  }

  /// 按科目/章节分组查询笔记（关联 question 表）
  Future<Map<String, Map<String, List<Note>>>> queryGrouped() async {
    final result = await _db.rawQuery('''
      SELECT n.*, q.subject, q.chapter
      FROM note n
      INNER JOIN question q ON n.question_id = q.id
      ORDER BY q.subject, q.chapter, n.updated_at DESC
    ''');

    final grouped = <String, Map<String, List<Note>>>{};
    for (final row in result) {
      final subject = row['subject'] as String;
      final chapter = row['chapter'] as String;
      final note = Note(
        id: row['id'] as int,
        questionId: row['question_id'] as int,
        content: row['content'] as String,
        updatedAt: row['updated_at'] as String,
      );

      grouped.putIfAbsent(subject, () => {});
      grouped[subject]!.putIfAbsent(chapter, () => []);
      grouped[subject]![chapter]!.add(note);
    }
    return grouped;
  }

  /// 删除所有笔记
  Future<int> deleteAll() async {
    return await _db.delete('note');
  }
}
