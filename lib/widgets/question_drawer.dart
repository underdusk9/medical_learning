import 'package:flutter/material.dart';
import '../core/constants.dart';

/// 题号抽屉（BottomSheet）
class QuestionDrawer extends StatelessWidget {
  final int total;
  final int currentIndex;
  final Map<int, bool> isAnswered;
  final Map<int, bool> isCorrect;
  final Map<int, bool> isBookmarkedMap;
  final ValueChanged<int> onJump;

  const QuestionDrawer({
    super.key,
    required this.total,
    required this.currentIndex,
    required this.isAnswered,
    required this.isCorrect,
    required this.isBookmarkedMap,
    required this.onJump,
  });

  /// 显示题号抽屉
  static void show(
    BuildContext context, {
    required int total,
    required int currentIndex,
    required Map<int, bool> isAnswered,
    required Map<int, bool> isCorrect,
    required Map<int, bool> isBookmarkedMap,
    required ValueChanged<int> onJump,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => QuestionDrawer(
        total: total,
        currentIndex: currentIndex,
        isAnswered: isAnswered,
        isCorrect: isCorrect,
        isBookmarkedMap: isBookmarkedMap,
        onJump: onJump,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖拽条
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 统计信息
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('未答', AppColors.unanswered),
              const SizedBox(width: 16),
              _buildStat('正确', AppColors.correct),
              const SizedBox(width: 16),
              _buildStat('错误', AppColors.wrong),
              const SizedBox(width: 16),
              _buildStat('收藏', AppColors.bookmark),
            ],
          ),
          const SizedBox(height: 16),
          // 题号网格
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: total,
              itemBuilder: (context, index) {
                return _buildQuestionButton(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildQuestionButton(int index) {
    final isCurrent = index == currentIndex;
    final answered = isAnswered[index] ?? false;
    final correct = isCorrect[index] ?? false;
    final bookmarked = isBookmarkedMap[index] ?? false;

    Color bgColor;
    Color fgColor = Colors.white;
    BoxBorder? border;

    if (bookmarked && !answered) {
      bgColor = AppColors.bookmark;
      fgColor = Colors.black87;
    } else if (answered && correct) {
      bgColor = AppColors.correct;
    } else if (answered && !correct) {
      bgColor = AppColors.wrong;
    } else {
      bgColor = AppColors.unanswered;
    }

    if (isCurrent) {
      border = Border.all(color: AppColors.primary, width: 2.5);
    }

    return InkWell(
      onTap: () => onJump(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: fgColor,
            fontSize: 14,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
