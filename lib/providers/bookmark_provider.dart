import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../dao/bookmark_dao.dart';
import '../models/bookmark.dart';

/// 收藏版本号，每次收藏/取消时递增，用于触发 currentIsBookmarkedProvider 刷新
final bookmarkVersionProvider = StateProvider<int>((ref) => 0);

/// 所有收藏列表
final bookmarksProvider = FutureProvider<List<Bookmark>>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = BookmarkDao(db);
  return dao.queryAll();
});

/// 判断某题是否已收藏
final isBookmarkedProvider = FutureProvider.family
    .autoDispose<bool, int>((ref, questionId) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = BookmarkDao(db);
  return dao.isBookmarked(questionId);
});

/// 分组收藏数据（含题干）
final groupedBookmarksProvider =
    FutureProvider<Map<String, Map<String, List<Map<String, dynamic>>>>>((
  ref,
) async {
  final db = await ref.watch(databaseProvider.future);
  final dao = BookmarkDao(db);
  return dao.queryGrouped();
});

/// 切换收藏状态
Future<void> toggleBookmark(Ref ref, int questionId) async {
  final db = await ref.read(databaseProvider.future);
  final dao = BookmarkDao(db);
  final isMarked = await dao.isBookmarked(questionId);

  if (isMarked) {
    await dao.delete(questionId);
  } else {
    final now = DateTime.now().toUtc().toIso8601String();
    await dao.insert(Bookmark(
      questionId: questionId,
      createdAt: now,
    ));
  }

  // 刷新相关 Provider
  ref.invalidate(bookmarksProvider);
  ref.invalidate(groupedBookmarksProvider);
  ref.invalidate(isBookmarkedProvider(questionId));
  // 递增版本号，触发 currentIsBookmarkedProvider 重新计算
  ref.read(bookmarkVersionProvider.notifier).update((v) => v + 1);
}
