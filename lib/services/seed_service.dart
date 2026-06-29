import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants.dart';
import '../core/database_helper.dart';
import '../models/question.dart';
import '../dao/question_dao.dart';

/// 种子数据服务：首次启动时导入 source/ 目录下的扩展题库
class SeedService {
  SeedService._();

  /// 如果是首次启动或 DB 升级后，从 source/ 导入所有题库
  static Future<void> seedIfFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final seeded = prefs.getBool(AppConstants.prefDbSeeded) ?? false;

    final db = await DatabaseHelper.instance.database;
    final dao = QuestionDao(db);

    // 检查是否需要重导：已有数据但缺少 section 字段（DB v1 升级到 v2）
    if (seeded) {
      final needsReimport = await _needsReimportDueToUpgrade(db);
      if (!needsReimport) return;
      // 清空旧数据，重新导入
      await dao.deleteAll();
    }

    // 导入 source/ 目录下的所有题库
    for (final path in AppConstants.sourceJsonPaths) {
      try {
        await _importAsset(dao, path);
      } catch (e) {
        // 单个文件导入失败不影响主流程，仅跳过
        continue;
      }
    }

    await prefs.setBool(AppConstants.prefDbSeeded, true);
  }

  /// 检查是否因为 DB 升级（v1→v2 缺少 section 字段）需要重导数据
  /// 只检查 source 题库（id >= 1000），默认的50题不需要 section
  static Future<bool> _needsReimportDueToUpgrade(Database db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM question WHERE id >= 1000 AND section IS NULL',
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// 从 assets 导入单个 JSON 文件
  static Future<void> _importAsset(QuestionDao dao, String assetPath) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final questions = jsonList
        .map((j) => Question.fromJson(j as Map<String, dynamic>))
        .toList();
    await dao.insertAll(questions);
  }
}
