import 'package:flutter/material.dart';
import '../core/constants.dart';

/// 分组列表视图
/// 按 科目 → 章节 → 项目 三级展示
class GroupListView<T> extends StatelessWidget {
  /// 分组数据: {科目: {章节: [项目列表]}}
  final Map<String, Map<String, List<T>>> groupedData;
  /// 项目标题构建器
  final String Function(T item) titleBuilder;
  /// 项目副标题构建器
  final String? Function(T item)? subtitleBuilder;
  /// 项目点击回调
  final void Function(T item)? onTap;
  /// 空状态提示
  final String emptyMessage;

  const GroupListView({
    super.key,
    required this.groupedData,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.onTap,
    this.emptyMessage = '暂无数据',
  });

  @override
  Widget build(BuildContext context) {
    if (groupedData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: groupedData.entries.map((subjectEntry) {
        return ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            subjectEntry.key,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          children: subjectEntry.value.entries.map((chapterEntry) {
            return ExpansionTile(
              initiallyExpanded: false,
              tilePadding: const EdgeInsets.only(left: 24, right: 8),
              title: Text(
                chapterEntry.key,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              children: chapterEntry.value.map((item) {
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 48, right: 8),
                  title: Text(
                    titleBuilder(item),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: subtitleBuilder != null
                      ? Text(
                          subtitleBuilder!(item) ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  onTap: onTap != null ? () => onTap!(item) : null,
                );
              }).toList(),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
