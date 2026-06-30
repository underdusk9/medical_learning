import 'package:flutter/material.dart';

/// 全局常量定义
class AppColors {
  AppColors._();

  // === 主色调 ===
  static const Color primary = Color(0xFF5C7B9A); // 蓝灰主色
  static const Color primaryLight = Color(0xFFE8EDF2); // 淡蓝灰背景
  static const Color primaryDark = Color(0xFF3D5A78); // 深蓝灰

  // === 语义色（低饱和） ===
  static const Color correct = Color(0xFF66BB6A); // 正确绿
  static const Color wrong = Color(0xFFEF5350); // 错误红
  static const Color bookmark = Color(0xFFFFB74D); // 收藏黄
  static const Color unanswered = Color(0xFF9E9E9E); // 中性灰

  // === 背景与卡片 ===
  static const Color background = Color(0xFFF5F7FA); // 全局背景
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE0E4E8);

  // === 文字 ===
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7B8A9B);

  // === AppBar ===
  static const Color appBarBackground = Color(0xFFFFFFFF);
  static const Color appBarForeground = Color(0xFF2C3E50);
}

class AppConstants {
  AppConstants._();

  /// 数据库
  static const String dbName = 'medical_quiz.db';
  static const int dbVersion = 6;
  static const String appVersion = '1.6.0';

  /// 路由名称
  static const String routeHome = '/';
  static const String routeFilter = '/filter';
  static const String routeQuiz = '/quiz';
  static const String routeBookmarkList = '/bookmarks';
  static const String routeNoteList = '/notes';
  static const String routeNoteEdit = '/notes/edit';
  static const String routeRandomSetup = '/random';
  static const String routeSettings = '/settings';
  static const String routeChangelog = '/changelog';

  /// 扩展题库文件路径（首次启动时自动导入）
  static const List<String> sourceJsonPaths = [
    'assets/questions/source/内科呼吸系统_part01_fixed.json',
    'assets/questions/source/内科呼吸系统_part02_fixed.json',
    'assets/questions/source/内科呼吸系统_part03_fixed.json',
    'assets/questions/source/学成选择题_消化系统(1)_part01_normalized_global_unique.json',
    'assets/questions/source/学成选择题_消化系统(1)_part02_normalized_global_unique.json',
    'assets/questions/source/学成选择题_泌尿系统(1)_part01_normalized_global_unique.json',
    'assets/questions/source/病理学_选择题_part01_规范化.json',
    'assets/questions/source/病理学_选择题_part02_规范化.json',
    'assets/questions/source/病理学_选择题_part03_规范化.json',
    'assets/questions/source/病理学_选择题_part04_规范化.json',
    'assets/questions/source/生理学_练习题_规范化_part01_Q4001-4100.json',
    'assets/questions/source/生理学_练习题_规范化_part02_Q4101-4200.json',
    'assets/questions/source/生理学_练习题_规范化_part03_Q4201-4300.json',
    'assets/questions/source/生理学_练习题_规范化_part04_Q4301-4400.json',
    'assets/questions/source/生理学_练习题_规范化_part05_Q4401-4500.json',
    'assets/questions/source/生理学_练习题_规范化_part06_Q4501-4600.json',
    'assets/questions/source/生理学_练习题_规范化_part07_Q4601-4700.json',
    'assets/questions/source/生理学_练习题_规范化_part08_Q4701-4800.json',
    'assets/questions/source/生理学_练习题_规范化_part09_Q4801-4900.json',
    'assets/questions/source/生理学_练习题_规范化_part10_Q4901-5000.json',
    'assets/questions/source/生理学_练习题_规范化_part11_Q5001-5100.json',
    'assets/questions/source/生理学_练习题_规范化_part12_Q5101-5200.json',
    'assets/questions/source/生理学_练习题_规范化_part13_Q5201-5300.json',
    'assets/questions/source/生理学_练习题_规范化_part14_Q5301-5400.json',
    'assets/questions/source/生理学_练习题_规范化_part15_Q5401-5474.json',
    'assets/questions/source/内科学_选择题_part01_5501-5600.json',
    'assets/questions/source/内科学_选择题_part02_5601-5700.json',
    'assets/questions/source/内科学_选择题_part03_5701-5800.json',
    'assets/questions/source/内科学_选择题_part04_5801-5900.json',
    'assets/questions/source/内科学_选择题_part05_5901-5964.json',
    'assets/questions/source/内科学_循环系统疾病_选择题_part01_6000-6099.json',
    'assets/questions/source/内科学_循环系统疾病_选择题_part02_6100-6199.json',
  ];

  /// SharedPreferences 键
  static const String prefDbSeeded = 'db_seeded';
  static const String prefNoteWithAnswer = 'note_with_answer';
  static const String prefLastVersion = 'last_app_version';

  /// GitHub
  static const String githubRepo = 'underdusk9/medical_learning';
  static const String githubReleaseUrl = 'https://github.com/underdusk9/medical_learning/releases/latest';

  /// 蓝奏云
  static const String lanzouUrl =
      'https://wwboz.lanzouw.com/ivwNd3sjb19c?pwd=cogb';
}

/// 应用样式常量
class AppStyles {
  AppStyles._();

  // ===== 圆角体系 =====
  static const BorderRadius radiusCard = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusButton = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusChip = BorderRadius.all(Radius.circular(6));
  static const BorderRadius radiusOption = BorderRadius.all(Radius.circular(10));

  // ===== 边框体系 =====
  static final BoxBorder cardBorder = Border.all(
    color: AppColors.cardBorder,
    width: 1.0,
  );
  static final BoxBorder unselectedOptionBorder = Border.all(
    color: Color(0xFFD5D9E0),
    width: 1.0,
  );

  // ===== 阴影体系 =====
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];
  static const List<BoxShadow> appBarShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 1,
      offset: Offset(0, 0.5),
    ),
  ];
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  // ===== 间距体系 =====
  static const EdgeInsets paddingPage = EdgeInsets.all(16);
  static const EdgeInsets paddingCard = EdgeInsets.all(16);
  static const EdgeInsets paddingOption = EdgeInsets.symmetric(horizontal: 12, vertical: 10);

  // ===== 文本样式 =====
  static const TextStyle textPageTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle textSectionTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.textPrimary,
  );
  static const TextStyle textBodySecondary = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

/// 选项状态枚举
enum OptionState {
  unselected,
  selectedBeforeAnswer,
  correctAfterAnswer,
  wrongAfterAnswer,
  unselectedAfterAnswer,
}

/// 选项样式数据类
class OptionStyle {
  final Color borderColor;
  final Color bgColor;
  final Color textColor;
  final Color labelBgColor;
  final Color labelFgColor;
  final IconData? trailingIcon;
  final double borderWidth;

  const OptionStyle({
    required this.borderColor,
    required this.bgColor,
    required this.textColor,
    required this.labelBgColor,
    required this.labelFgColor,
    this.trailingIcon,
    this.borderWidth = 1.0,
  });
}

/// 根据选项状态生成对应样式
OptionStyle optionStyleFor(OptionState state) {
  switch (state) {
    case OptionState.unselected:
      return OptionStyle(
        borderColor: const Color(0xFFD5D9E0),
        bgColor: AppColors.cardBackground,
        textColor: AppColors.textPrimary,
        labelBgColor: const Color(0xFFE8ECF0),
        labelFgColor: AppColors.textSecondary,
      );
    case OptionState.selectedBeforeAnswer:
      return OptionStyle(
        borderColor: AppColors.primary,
        bgColor: AppColors.primaryLight.withValues(alpha: 0.3),
        textColor: AppColors.primaryDark,
        labelBgColor: AppColors.primary,
        labelFgColor: Colors.white,
        borderWidth: 2.0,
      );
    case OptionState.correctAfterAnswer:
      return OptionStyle(
        borderColor: AppColors.correct,
        bgColor: AppColors.correct.withValues(alpha: 0.08),
        textColor: const Color(0xFF2E7D32),
        labelBgColor: AppColors.correct,
        labelFgColor: Colors.white,
        trailingIcon: Icons.check_circle,
        borderWidth: 2.0,
      );
    case OptionState.wrongAfterAnswer:
      return OptionStyle(
        borderColor: AppColors.wrong,
        bgColor: AppColors.wrong.withValues(alpha: 0.08),
        textColor: const Color(0xFFC62828),
        labelBgColor: AppColors.wrong,
        labelFgColor: Colors.white,
        trailingIcon: Icons.cancel,
        borderWidth: 2.0,
      );
    case OptionState.unselectedAfterAnswer:
      return OptionStyle(
        borderColor: const Color(0xFFE0E4E8),
        bgColor: AppColors.cardBackground,
        textColor: AppColors.textSecondary,
        labelBgColor: const Color(0xFFE8ECF0),
        labelFgColor: AppColors.textSecondary,
      );
  }
}
