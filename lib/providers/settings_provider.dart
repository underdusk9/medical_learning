import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

/// 笔记显示模式：true = 答题后显示，false = 一直显示（默认）
final noteWithAnswerProvider = StateProvider<bool>((ref) {
  return false;
});

/// 初始化所有设置（app 启动时调用）
Future<void> initSettings(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();

  // 笔记显示模式
  final noteVal = prefs.getBool(AppConstants.prefNoteWithAnswer) ?? false;
  ref.read(noteWithAnswerProvider.notifier).state = noteVal;
}

/// 切换笔记显示模式并持久化
Future<void> toggleNoteWithAnswer(WidgetRef ref) async {
  final current = ref.read(noteWithAnswerProvider);
  final newValue = !current;
  ref.read(noteWithAnswerProvider.notifier).state = newValue;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(AppConstants.prefNoteWithAnswer, newValue);
}
