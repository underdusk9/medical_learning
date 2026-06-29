import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../dao/note_dao.dart';
import '../models/note.dart';

/// 所有笔记列表
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = NoteDao(db);
  return dao.queryAll();
});

/// 按题目ID查询笔记
final noteByQuestionProvider = FutureProvider.family
    .autoDispose<Note?, int>((ref, questionId) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = NoteDao(db);
  return dao.queryByQuestionId(questionId);
});

/// 分组笔记数据
final groupedNotesProvider =
    FutureProvider<Map<String, Map<String, List<Note>>>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = NoteDao(db);
  return dao.queryGrouped();
});

/// 保存笔记（新增或更新）
Future<void> saveNote(WidgetRef ref, int questionId, String content) async {
  final db = await ref.read(databaseProvider.future);
  final dao = NoteDao(db);
  final existing = await dao.queryByQuestionId(questionId);
  final now = DateTime.now().toUtc().toIso8601String();

  if (existing != null) {
    await dao.update(existing.copyWith(content: content, updatedAt: now));
  } else {
    await dao.insert(Note(
      questionId: questionId,
      content: content,
      updatedAt: now,
    ));
  }

  // 刷新相关 Providers
  ref.invalidate(notesProvider);
  ref.invalidate(groupedNotesProvider);
  ref.invalidate(noteByQuestionProvider(questionId));
}

/// 删除笔记
Future<void> deleteNote(WidgetRef ref, int noteId, int questionId) async {
  final db = await ref.read(databaseProvider.future);
  final dao = NoteDao(db);
  await dao.delete(noteId);

  ref.invalidate(notesProvider);
  ref.invalidate(groupedNotesProvider);
  ref.invalidate(noteByQuestionProvider(questionId));
}
