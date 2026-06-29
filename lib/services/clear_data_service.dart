import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/database_helper.dart';

/// 清除数据服务
class ClearDataService {
  ClearDataService._();

  /// 清除所有数据：删除数据库文件 → 重置种子标记 → 重新建表
  static Future<void> clearAll() async {
    // 重置数据库
    await DatabaseHelper.instance.resetDatabase();

    // 重置种子标记
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefDbSeeded, false);
  }
}
