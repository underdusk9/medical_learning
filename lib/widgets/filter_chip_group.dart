import 'package:flutter/material.dart';
import '../core/constants.dart';

/// 多选筛选 Chip 组
@Deprecated('Use SelectionCard instead')
class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool value) {
            if (value) {
              onChanged([...selected, option]);
            } else {
              onChanged(selected.where((e) => e != option).toList());
            }
          },
          selectedColor: AppColors.primaryLight,
          checkmarkColor: AppColors.primary,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
