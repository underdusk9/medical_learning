import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../widgets/group_list_view.dart';

/// 笔记本页面
class NoteListScreen extends ConsumerStatefulWidget {
  const NoteListScreen({super.key});

  @override
  ConsumerState<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends ConsumerState<NoteListScreen> {
  @override
  Widget build(BuildContext context) {
    final groupedAsync = ref.watch(groupedNotesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('笔记本'),
      ),
      body: groupedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (grouped) {
          return GroupListView<Note>(
            groupedData: grouped,
            emptyMessage: '暂无学习笔记',
            titleBuilder: (note) => note.content.length > 40
                ? '${note.content.substring(0, 40)}...'
                : note.content,
            subtitleBuilder: (note) =>
                '题目 #${note.questionId} · ${_formatDate(note.updatedAt)}',
            onTap: (note) {
              context.push(AppConstants.routeNoteEdit, extra: {
                'questionId': note.questionId,
              });
            },
          );
        },
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}
