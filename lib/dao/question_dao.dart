import 'package:sqflite/sqflite.dart';
import '../models/question.dart';

/// 题目数据访问对象
class QuestionDao {
  final Database _db;

  QuestionDao(this._db);

  /// 查询所有题目
  Future<List<Question>> queryAll() async {
    final maps = await _db.query('question', orderBy: 'id ASC');
    return maps.map((m) => Question.fromMap(m)).toList();
  }

  /// 按筛选条件查询
  Future<List<Question>> queryByFilter({
    String? subject,
    List<String>? sections,
    List<String>? chapters,
    List<String>? topics,
  }) async {
    final whereParts = <String>[];
    final whereArgs = <dynamic>[];

    if (subject != null && subject.isNotEmpty) {
      whereParts.add('subject = ?');
      whereArgs.add(subject);
    }
    if (sections != null && sections.isNotEmpty) {
      final placeholders = sections.map((_) => '?').join(',');
      whereParts.add('section IN ($placeholders)');
      whereArgs.addAll(sections);
    }
    if (chapters != null && chapters.isNotEmpty) {
      final placeholders = chapters.map((_) => '?').join(',');
      whereParts.add('chapter IN ($placeholders)');
      whereArgs.addAll(chapters);
    }
    if (topics != null && topics.isNotEmpty) {
      final placeholders = topics.map((_) => '?').join(',');
      whereParts.add('topic IN ($placeholders)');
      whereArgs.addAll(topics);
    }

    final where = whereParts.isEmpty ? null : whereParts.join(' AND ');
    final maps = await _db.query(
      'question',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'id ASC',
    );
    return maps.map((m) => Question.fromMap(m)).toList();
  }

  /// 随机抽取题目
  Future<List<Question>> queryRandom({
    String? subject,
    List<String>? sections,
    List<String>? chapters,
    List<String>? topics,
    required int count,
  }) async {
    final whereParts = <String>[];
    final whereArgs = <dynamic>[];

    if (subject != null && subject.isNotEmpty) {
      whereParts.add('subject = ?');
      whereArgs.add(subject);
    }
    if (sections != null && sections.isNotEmpty) {
      final placeholders = sections.map((_) => '?').join(',');
      whereParts.add('section IN ($placeholders)');
      whereArgs.addAll(sections);
    }
    if (chapters != null && chapters.isNotEmpty) {
      final placeholders = chapters.map((_) => '?').join(',');
      whereParts.add('chapter IN ($placeholders)');
      whereArgs.addAll(chapters);
    }
    if (topics != null && topics.isNotEmpty) {
      final placeholders = topics.map((_) => '?').join(',');
      whereParts.add('topic IN ($placeholders)');
      whereArgs.addAll(topics);
    }

    final where = whereParts.isEmpty ? null : whereParts.join(' AND ');
    final maps = await _db.query(
      'question',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'RANDOM()',
      limit: count,
    );
    return maps.map((m) => Question.fromMap(m)).toList();
  }

  /// 按ID查询
  Future<Question?> queryById(int id) async {
    final maps = await _db.query(
      'question',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Question.fromMap(maps.first);
  }

  /// 批量插入（事务）
  Future<void> insertAll(List<Question> questions) async {
    await _db.transaction((txn) async {
      for (final q in questions) {
        await txn.insert(
          'question',
          q.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  /// 批量 upsert（INSERT OR REPLACE，事务）
  Future<void> upsertAll(List<Question> questions) async {
    await _db.transaction((txn) async {
      for (final q in questions) {
        await txn.insert(
          'question',
          q.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// 统计题目总数
  Future<int> count() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as cnt FROM question');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 删除所有题目
  Future<int> deleteAll() async {
    return await _db.delete('question');
  }

  /// 订正题目答案
  Future<void> updateAnswer(int id, String newAnswer) async {
    await _db.update(
      'question',
      {'answer': newAnswer},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 查询所有科目
  Future<List<String>> querySubjects() async {
    final result = await _db.rawQuery(
      'SELECT DISTINCT subject FROM question ORDER BY subject',
    );
    return result.map((m) => m['subject'] as String).toList();
  }

  /// 按科目查询系统（section）
  Future<List<String>> querySections(String subject) async {
    final result = await _db.rawQuery(
      'SELECT DISTINCT section FROM question WHERE subject = ? AND section IS NOT NULL ORDER BY section',
      [subject],
    );
    return result.map((m) => m['section'] as String).toList();
  }

  /// 按科目+可选sections查询章节
  Future<List<String>> queryChapters(String subject, {List<String>? sections}) async {
    final whereParts = <String>['subject = ?'];
    final whereArgs = <dynamic>[subject];
    if (sections != null && sections.isNotEmpty) {
      final placeholders = sections.map((_) => '?').join(',');
      whereParts.add('section IN ($placeholders)');
      whereArgs.addAll(sections);
    }
    final result = await _db.rawQuery(
      'SELECT DISTINCT chapter FROM question WHERE ${whereParts.join(' AND ')} AND chapter IS NOT NULL ORDER BY chapter',
      whereArgs,
    );
    return result.map((m) => m['chapter'] as String).toList();
  }

  /// 按科目+可选sections/chapters查询考点
  Future<List<String>> queryTopics(String subject, {List<String>? sections, List<String>? chapters}) async {
    final whereParts = <String>['subject = ?'];
    final whereArgs = <dynamic>[subject];
    if (sections != null && sections.isNotEmpty) {
      final placeholders = sections.map((_) => '?').join(',');
      whereParts.add('section IN ($placeholders)');
      whereArgs.addAll(sections);
    }
    if (chapters != null && chapters.isNotEmpty) {
      final placeholders = chapters.map((_) => '?').join(',');
      whereParts.add('chapter IN ($placeholders)');
      whereArgs.addAll(chapters);
    }
    final result = await _db.rawQuery(
      'SELECT DISTINCT topic FROM question WHERE ${whereParts.join(' AND ')} AND topic IS NOT NULL ORDER BY topic',
      whereArgs,
    );
    return result.map((m) => m['topic'] as String).toList();
  }
}
