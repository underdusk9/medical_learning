import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/bookmark_provider.dart';
import '../providers/database_provider.dart';
import '../dao/question_dao.dart';
import '../widgets/group_list_view.dart';

/// 收藏夹页面
class BookmarkListScreen extends ConsumerStatefulWidget {
  const BookmarkListScreen({super.key});

  @override
  ConsumerState<BookmarkListScreen> createState() => _BookmarkListScreenState();
}

class _BookmarkListScreenState extends ConsumerState<BookmarkListScreen> {
  @override
  Widget build(BuildContext context) {
    final groupedAsync = ref.watch(groupedBookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏夹'),
      ),
      body: groupedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (grouped) {
          return GroupListView<Map<String, dynamic>>(
            groupedData: grouped,
            emptyMessage: '暂无收藏题目',
            titleBuilder: (data) => data['stem'] as String? ?? '题目 #${data['question_id']}',
            subtitleBuilder: (data) => '收藏于 ${_formatDate(data['created_at'] as String)}',
            onTap: (data) async {
              final qid = data['question_id'] as int;
              if (mounted) {
                context.push(AppConstants.routeQuiz, extra: {
                  'questionIds': [qid],
                  'sessionType': 'bookmark',
                });
              }
            },
          );
        },
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}
