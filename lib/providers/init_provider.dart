import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import 'settings_provider.dart';
import '../services/seed_service.dart';

/// 初始化 Provider：等待数据库就绪 + 种子数据导入 + 设置加载
final initProvider = FutureProvider<void>((ref) async {
  await ref.watch(databaseProvider.future);
  await SeedService.seedIfFirstLaunch();
  await initSettings(ref);
});
