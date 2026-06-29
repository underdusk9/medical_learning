import 'package:flutter/material.dart';
import '../core/constants.dart';

/// 更新日志页面
class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更新日志'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildVersionCard(
            'v1.3.0',
            '2026-06-29',
            [
              _LogItem('新增', '内分泌与代谢疾病题库：123 题（甲状腺/糖尿病/肾上腺/痛风）'),
              _LogItem('新增', '风湿免疫性疾病题库：34 题（类风湿/SLE/血管炎等）'),
              _LogItem('新增', '中毒与急危重症题库：58 题（有机磷/CO中毒等）'),
              _LogItem('新增', '血液系统题库替换为更规范的分章版（231 题）'),
              _LogItem('新增', '设置页作者区：扫码关注作者小红书'),
              _LogItem('改进', '移除旧血液系统题库（重复数据）'),
              _LogItem('改进', '移除自定义启动图功能'),
              _LogItem('改进', '题库总量突破 2,700 题'),
            ],
          ),
          const SizedBox(height: 12),
          _buildVersionCard(
            'v1.2.0',
            '2026-06-21',
            [
              _LogItem('新增', '生理学题库：474 道题目（绪论→生殖 12 大章节）'),
              _LogItem('新增', '全新 App 图标（冰蓝渐变风格）'),
              _LogItem('改进', '项目改名"小han刷题"'),
              _LogItem('改进', '启动页优化：原生白底+图标，无缝过渡到 App'),
              _LogItem('改进', '清理冗余文件，安装包大小优化'),
            ],
          ),
          const SizedBox(height: 12),
          _buildVersionCard(
            'v1.1.0',
            '2026-06-18',
            [
              _LogItem('新增', '血液系统题库：231 道题目（缺铁性贫血、再障、溶血性贫'
                  '血、出血性疾病、MDS、白血病、MM、淋巴瘤）'),
              _LogItem('新增', '笔记显示框：答题页题目下方显示笔记内容'),
              _LogItem('新增', '自定义启动图：密码保护彩蛋功能'),
              _LogItem('改进', '随机组卷改为 Chip 点击式筛选（与筛选页一致）'),
              _LogItem('改进', '首次密码验证后后续可直接切换启动图开关'),
              _LogItem('修复', '自定义启动图因缓存导致不显示的时序问题'),
            ],
          ),
          const SizedBox(height: 12),
          _buildVersionCard(
            'v1.0.0',
            '2026-06-16',
            [
              _LogItem('新增', '初始版本发布'),
              _LogItem('功能', '4级分层筛选（学科→系统→章节→考点）'),
              _LogItem('功能', '答题练习、收藏、笔记功能'),
              _LogItem('功能', '随机组卷、JSON 导入题库'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(String version, String date, List<_LogItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppStyles.radiusCard,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                version,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _tagColor(item.tag),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.tag,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case '新增':
        return AppColors.primary;
      case '改进':
        return AppColors.bookmark;
      case '修复':
        return AppColors.correct;
      case '功能':
        return AppColors.primaryDark;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _LogItem {
  final String tag;
  final String text;
  const _LogItem(this.tag, this.text);
}
