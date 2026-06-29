import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../dao/question_dao.dart';

/// 选中的科目列表（多选）
final selectedSubjectProvider = StateProvider<List<String>>((ref) => []);

/// 选中的系统（section）列表
final selectedSectionsProvider = StateProvider<List<String>>((ref) => []);

/// 选中的章节列表
final selectedChaptersProvider = StateProvider<List<String>>((ref) => []);

/// 选中的考点列表
final selectedTopicsProvider = StateProvider<List<String>>((ref) => []);

/// 可选科目列表
final availableSubjectsProvider = FutureProvider<List<String>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  return dao.querySubjects();
});

/// 可选系统（section）列表（根据选中科目联动）
final availableSectionsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final subjects = ref.watch(selectedSubjectProvider);
  if (subjects.isEmpty) return [];

  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  // 查询所有选中科目的 section 并集
  final allSections = <String>{};
  for (final subject in subjects) {
    final sections = await dao.querySections(subject);
    allSections.addAll(sections);
  }
  return allSections.toList()..sort();
});

/// 可选章节列表（根据选中科目+系统联动）
final availableChaptersProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final subjects = ref.watch(selectedSubjectProvider);
  final sections = ref.watch(selectedSectionsProvider);
  if (subjects.isEmpty) return [];

  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  // 查询所有选中科目的章节并集
  final allChapters = <String>{};
  for (final subject in subjects) {
    final chapters = await dao.queryChapters(
      subject,
      sections: sections.isNotEmpty ? sections : null,
    );
    allChapters.addAll(chapters);
  }
  return allChapters.toList()..sort();
});

/// 可选考点列表（根据选中科目+系统+章节联动）
final availableTopicsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final subjects = ref.watch(selectedSubjectProvider);
  final sections = ref.watch(selectedSectionsProvider);
  final chapters = ref.watch(selectedChaptersProvider);
  if (subjects.isEmpty) return [];

  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  // 查询所有选中科目的考点并集
  final allTopics = <String>{};
  for (final subject in subjects) {
    final topics = await dao.queryTopics(
      subject,
      sections: sections.isNotEmpty ? sections : null,
      chapters: chapters.isNotEmpty ? chapters : null,
    );
    allTopics.addAll(topics);
  }
  return allTopics.toList()..sort();
});
