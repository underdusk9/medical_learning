import 'package:flutter/material.dart';
import '../core/constants.dart';

/// 选项条目组件
class OptionItem extends StatelessWidget {
  final String label; // A, B, C, D, E...
  final String text; // 选项文本
  final bool isSelected; // 用户是否选中
  final bool isCorrectOption; // 是否为正确选项
  final bool isAnswered; // 是否已答题
  final bool isUserWrong; // 用户选错
  final VoidCallback? onTap;
  final bool isMultiple; // 多选模式

  const OptionItem({
    super.key,
    required this.label,
    required this.text,
    this.isSelected = false,
    this.isCorrectOption = false,
    this.isAnswered = false,
    this.isUserWrong = false,
    this.onTap,
    this.isMultiple = false,
  });

  /// 将条件映射为 OptionState 枚举值
  OptionState _resolveState() {
    if (!isAnswered) {
      return isSelected ? OptionState.selectedBeforeAnswer : OptionState.unselected;
    }
    if (isCorrectOption) return OptionState.correctAfterAnswer;
    if (isUserWrong) return OptionState.wrongAfterAnswer;
    return OptionState.unselectedAfterAnswer;
  }

  @override
  Widget build(BuildContext context) {
    final state = _resolveState();
    final style = optionStyleFor(state);

    return InkWell(
      onTap: onTap,
      borderRadius: AppStyles.radiusOption,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: AppStyles.paddingOption,
        decoration: BoxDecoration(
          border: Border.all(color: style.borderColor, width: style.borderWidth),
          borderRadius: AppStyles.radiusOption,
          color: style.bgColor,
        ),
        child: Row(
          children: [
            // 选项标签 (A/B/C/D)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: style.labelBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: style.labelFgColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 选项文本
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            if (style.trailingIcon != null)
              Icon(style.trailingIcon, color: style.borderColor, size: 22),
          ],
        ),
      ),
    );
  }
}
