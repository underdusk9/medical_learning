import 'package:flutter/material.dart';
import '../core/constants.dart';

/// 收藏星标按钮
class BookmarkStar extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback onTap;

  const BookmarkStar({
    super.key,
    required this.isBookmarked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        isBookmarked ? Icons.star : Icons.star_border,
        color: isBookmarked ? AppColors.bookmark : Colors.grey,
        size: 28,
      ),
      tooltip: isBookmarked ? '取消收藏' : '添加收藏',
    );
  }
}
