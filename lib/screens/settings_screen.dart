import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/import_service.dart';
import '../services/clear_data_service.dart';
import '../services/update_service.dart';
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
          const SizedBox(height: 16),

          // 检查更新
          Card(
            child: ListTile(
              leading: const Icon(Icons.system_update, color: AppColors.primary),
              title: const Text('检查更新'),
              subtitle: Text('当前版本 v${AppConstants.appVersion}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _checkUpdate,
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
            '小han刷题 v${AppConstants.appVersion}',
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
                  GestureDetector(
                    onTap: _showAuthorQrFullscreen,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/author_qr.jpg',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '点击二维码查看大图',
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

  Future<void> _checkUpdate() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在检查更新...')),
    );

    UpdateCheckResult result;
    try {
      result = await UpdateService.checkForUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('检查失败：${e.toString()}')),
        );
      }
      return;
    }

    if (!mounted) return;

    if (result.hasUpdate) {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('发现新版本'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('最新版本：v${result.latestVersion}'),
              if (result.releaseNotes != null) ...[
                const SizedBox(height: 12),
                Text(
                  result.releaseNotes!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('稍后'),
            ),
            if (result.apkDownloadUrl != null)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop('online'),
                child: const Text('在线下载'),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('lanzou'),
              child: const Text('蓝奏云下载(密码cogb)'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop('web'),
              child: const Text('GitHub下载'),
            ),
          ],
        ),
      );

      if (!mounted || choice == null) return;

      if (choice == 'web') {
        final url = result.releasePageUrl ?? AppConstants.githubReleaseUrl;
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else if (choice == 'online' && result.apkDownloadUrl != null) {
        _downloadAndInstall(result.apkDownloadUrl!);
      } else if (choice == 'lanzou') {
        await launchUrl(
          Uri.parse(AppConstants.lanzouUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已是最新版本 v${AppConstants.appVersion}')),
      );
    }
  }

  Future<void> _downloadAndInstall(String url) async {
    if (!mounted) return;

    // 进度弹窗
    final progressNotifier = ValueNotifier(0.0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('正在下载更新'),
        content: ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (context, value, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: value > 0 ? value : null),
              const SizedBox(height: 8),
              Text(
                value > 0
                    ? '${(value * 100).toStringAsFixed(1)}%'
                    : '准备下载...',
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final filePath = await UpdateService.downloadAPK(
        url,
        onProgress: (p) => progressNotifier.value = p,
      );
      if (mounted) Navigator.of(context).pop();
      await UpdateService.installAPK(filePath);
    } on DownloadException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        final messages = {
          DownloadErrorType.network: '网络连接失败，请检查网络后重试',
          DownloadErrorType.permission: '权限不足，请手动前往 GitHub 下载 APK',
          DownloadErrorType.diskSpace: '手机存储空间不足，请清理后重试',
          DownloadErrorType.hashMismatch: '下载文件损坏，请重新下载',
          DownloadErrorType.other: '操作失败: ${e.message}',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(messages[e.type] ?? e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败：${e.toString()}')),
        );
      }
    }
  }

  void _showAuthorQrFullscreen() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/author_qr.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
