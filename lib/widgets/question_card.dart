import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/question.dart';
import 'option_item.dart';

/// 选项标签生成：支持 A-Z 和 a-z（超过26个选项时使用小写字母）
String _getOptionLabel(int index) {
  if (index < 26) return String.fromCharCode(65 + index); // A-Z
  return String.fromCharCode(71 + index); // a-z (index 26→97='a')
}

/// 题目卡片组件
class QuestionCard extends StatelessWidget {
  final Question question;
  final String? userAnswer;
  final bool isAnswered;
  final bool isCorrect;
  final ValueChanged<String> onOptionTap;
  final bool showAnalysis;
  final String? noteContent;
  /// true = 答题后才显示笔记；false = 一直显示（默认）
  final bool showNoteWithAnswer;

  const QuestionCard({
    super.key,
    required this.question,
    this.userAnswer,
    this.isAnswered = false,
    this.isCorrect = false,
    required this.onOptionTap,
    this.showAnalysis = true,
    this.noteContent,
    this.showNoteWithAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    final options = question.optionsList;
    final correctAnswer = question.answer;
    final typeLabel = question.isMultiple ? '[多选题]' : '[单选题]';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 题型标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: question.isMultiple
                  ? AppColors.primaryLight
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              typeLabel,
              style: TextStyle(
                color: question.isMultiple
                    ? AppColors.primaryDark
                    : const Color(0xFFE65100),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 题干
          Text(
            question.stem,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // 选项列表
          ...List.generate(options.length, (index) {
            final label = _getOptionLabel(index);
            final optionText = options[index];
            final isUserSelected = userAnswer != null && userAnswer!.contains(label);
            final isCorrectOption = correctAnswer.contains(label);

            return OptionItem(
              label: label,
              text: optionText,
              isSelected: isUserSelected,
              isCorrectOption: isCorrectOption,
              isAnswered: isAnswered,
              isUserWrong: isAnswered && isUserSelected && !isCorrectOption,
              isMultiple: question.isMultiple,
              onTap: () => onOptionTap(label),
            );
          }),

          // 解析区域：答题后始终显示正确答案，有解析内容时额外展示
          if (showAnalysis && isAnswered) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppStyles.radiusButton,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 18, color: AppColors.primaryDark),
                      const SizedBox(width: 6),
                      Text(
                        '解析',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isCorrect ? '✓ 正确' : '✗ 错误',
                        style: TextStyle(
                          color: isCorrect ? AppColors.correct : AppColors.wrong,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '正确答案：$correctAnswer',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // 有解析内容时才显示
                  if (question.analysis != null && question.analysis!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      question.analysis!,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // 笔记区域：一直显示 或 答题后显示
          if (noteContent != null && noteContent!.isNotEmpty &&
              (!showNoteWithAnswer || isAnswered)) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: AppStyles.radiusButton,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note_outlined,
                          size: 18, color: AppColors.bookmark),
                      const SizedBox(width: 6),
                      Text(
                        '笔记',
                        style: TextStyle(
                          color: AppColors.bookmark,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    noteContent!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
