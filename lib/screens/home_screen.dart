import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

/// 首页
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小han刷题'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部标语
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '西医综合306',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '考研刷题 · 高效备考',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 功能入口网格
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _EntryCard(
                    icon: Icons.menu_book,
                    title: '开始练习',
                    subtitle: '按科目章节筛选',
                    color: AppColors.primary,
                    onTap: () => context.push(AppConstants.routeFilter),
                  ),
                  _EntryCard(
                    icon: Icons.shuffle,
                    title: '随机组卷',
                    subtitle: '随机抽取题目',
                    color: Colors.teal,
                    onTap: () => context.push(AppConstants.routeRandomSetup),
                  ),
                  _EntryCard(
                    icon: Icons.star,
                    title: '收藏夹',
                    subtitle: '查看收藏题目',
                    color: AppColors.bookmark,
                    onTap: () => context.push(AppConstants.routeBookmarkList),
                  ),
                  _EntryCard(
                    icon: Icons.note,
                    title: '笔记本',
                    subtitle: '查看学习笔记',
                    color: Colors.orange,
                    onTap: () => context.push(AppConstants.routeNoteList),
                  ),
                  _EntryCard(
                    icon: Icons.settings,
                    title: '设置',
                    subtitle: '导入/清除数据',
                    color: Colors.grey,
                    onTap: () => context.push(AppConstants.routeSettings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 首页入口卡片
class _EntryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _EntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyles.radiusCard,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
