import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../dao/question_dao.dart';
import '../models/question.dart';

/// 按筛选条件查询题目
final questionsByFilterProvider = FutureProvider.family
    .autoDispose<List<Question>, QuestionFilter>((ref, filter) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  return dao.queryByFilter(
    subject: filter.subject,
    sections: filter.sections,
    chapters: filter.chapters,
    topics: filter.topics,
  );
});

/// 随机抽取题目
final randomQuestionsProvider = FutureProvider.family
    .autoDispose<List<Question>, RandomFilter>((ref, filter) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  return dao.queryRandom(
    subject: filter.subject,
    sections: filter.sections,
    chapters: filter.chapters,
    topics: filter.topics,
    count: filter.count,
  );
});

/// 按ID查询单题详情
final questionDetailProvider = FutureProvider.family
    .autoDispose<Question?, int>((ref, id) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  return dao.queryById(id);
});

/// 所有科目列表
final subjectsProvider = FutureProvider<List<String>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  return dao.querySubjects();
});

/// 按科目查询章节（向后兼容）
final chaptersProvider = FutureProvider.family
    .autoDispose<List<String>, String>((ref, subject) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  return dao.queryChapters(subject);
});

/// 按科目+章节查询考点（向后兼容）
final topicsProvider = FutureProvider.family
    .autoDispose<List<String>, ChapterKey>((ref, key) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  return dao.queryTopics(key.subject, chapters: [key.chapter]);
});

/// 筛选条件数据类
class QuestionFilter {
  final String? subject;
  final String? chapter; // 保留旧字段（兼容旧调用方）
  final List<String>? sections;
  final List<String>? chapters;
  final List<String>? topics;

  const QuestionFilter({
    this.subject,
    this.chapter,
    this.sections,
    this.chapters,
    this.topics,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionFilter &&
          subject == other.subject &&
          chapter == other.chapter &&
          _listEquals(sections, other.sections) &&
          _listEquals(chapters, other.chapters) &&
          _listEquals(topics, other.topics);

  @override
  int get hashCode => Object.hash(
    subject,
    chapter,
    Object.hashAll(sections ?? []),
    Object.hashAll(chapters ?? []),
    Object.hashAll(topics ?? []),
  );

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 随机组卷筛选条件
class RandomFilter {
  final String? subject;
  final String? chapter; // 保留旧字段（兼容旧调用方）
  final List<String>? sections;
  final List<String>? chapters;
  final List<String>? topics;
  final int count;

  const RandomFilter({
    this.subject,
    this.chapter,
    this.sections,
    this.chapters,
    this.topics,
    required this.count,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RandomFilter &&
          subject == other.subject &&
          chapter == other.chapter &&
          _listEquals(sections, other.sections) &&
          _listEquals(chapters, other.chapters) &&
          _listEquals(topics, other.topics) &&
          count == other.count;

  @override
  int get hashCode => Object.hash(
    subject,
    chapter,
    Object.hashAll(sections ?? []),
    Object.hashAll(chapters ?? []),
    Object.hashAll(topics ?? []),
    count,
  );

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 订正题目答案（立即持久化到数据库）
Future<void> correctAnswer(WidgetRef ref, int questionId, String newAnswer) async {
  final db = await ref.read(databaseProvider.future);
  final dao = QuestionDao(db);
  await dao.updateAnswer(questionId, newAnswer);
}

/// 科目+章节组合键（向后兼容）
class ChapterKey {
  final String subject;
  final String chapter;

  const ChapterKey({required this.subject, required this.chapter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterKey &&
          subject == other.subject &&
          chapter == other.chapter;

  @override
  int get hashCode => Object.hash(subject, chapter);
}
