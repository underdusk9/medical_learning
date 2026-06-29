import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/import_service.dart';
import '../services/clear_data_service.dart';
import '../core/constants.dart';
import '../providers/settings_provider.dart';

/// 设置页面
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 导入 JSON
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_upload, color: AppColors.primary),
              title: const Text('导入题库'),
              subtitle: const Text('从 JSON 文件导入题目'),
              trailing: _isImporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isImporting ? null : _importJson,
            ),
          ),
          const SizedBox(height: 8),

          // 导入模式说明
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '导入模式：合并（保留已有数据）或替换（清除后导入）',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),

          // 笔记显示模式
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.note_outlined, color: AppColors.bookmark),
              title: const Text('笔记跟随答案显示'),
              subtitle: const Text('关闭时笔记一直显示，开启后答题才显示'),
              value: ref.watch(noteWithAnswerProvider),
              onChanged: (_) => toggleNoteWithAnswer(ref),
            ),
          ),
          const SizedBox(height: 16),

          // 清除数据
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.wrong),
              title: const Text('清除所有数据'),
              subtitle: const Text('删除所有题目、收藏和笔记'),
              onTap: _clearData,
            ),
          ),
          const SizedBox(height: 32),

          // 关于信息
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            '关于',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '小han刷题 v1.3.0',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => context.push(AppConstants.routeChangelog),
            child: Text(
              '更新日志',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '西医综合306考研刷题应用',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '数据存储于本地 SQLite 数据库',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // 作者
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            '作者',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/author_qr.jpg',
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '扫描二维码关注作者',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importJson() async {
    // 先选择导入模式
    final mode = await showDialog<ImportMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择导入模式'),
        content: const Text('合并模式：保留已有数据，重复ID的题目将被替换。\n替换模式：清除所有已有题目后导入。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ImportMode.merge),
            child: const Text('合并'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ImportMode.replace),
            child: const Text('替换'),
          ),
        ],
      ),
    );

    if (mode == null || !mounted) return;

    setState(() => _isImporting = true);

    try {
      final result = await ImportService.importFromPicker(mode: mode, ref: ref);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('导入结果'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('总数：${result.total}'),
                Text('成功：${result.success}'),
                if (result.failed > 0) Text('失败：${result.failed}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('此操作将删除所有题目、收藏和笔记数据，且不可恢复。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wrong,
            ),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ClearDataService.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已清除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除失败: $e')),
        );
      }
    }
  }
}
