import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/question.dart';
import '../dao/question_dao.dart';
import '../providers/database_provider.dart';

/// 导入模式枚举
enum ImportMode { merge, replace }

/// 导入结果
class ImportResult {
  final int total;
  final int success;
  final int failed;

  const ImportResult({
    required this.total,
    required this.success,
    required this.failed,
  });
}

/// 导入服务：从外部 JSON 文件导入题库
class ImportService {
  ImportService._();

  /// 从文件选择器选择文件并导入
  static Future<ImportResult> importFromPicker({
    required ImportMode mode,
    required WidgetRef ref,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('未选择文件');
    }

    final filePath = result.files.single.path;
    if (filePath == null) {
      throw Exception('无法获取文件路径');
    }

    return importFromPath(filePath, mode: mode, ref: ref);
  }

  /// 从指定路径导入
  static Future<ImportResult> importFromPath(
    String path, {
    required ImportMode mode,
    required WidgetRef ref,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('文件不存在: $path');
    }

    final jsonString = await file.readAsString();
    final List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(jsonString) as List<dynamic>;
    } catch (e) {
      throw Exception('JSON 解析失败: $e');
    }

    final questions = <Question>[];
    var failedCount = 0;

    for (final item in jsonList) {
      try {
        final q = Question.fromJson(item as Map<String, dynamic>);
        questions.add(q);
      } catch (_) {
        failedCount++;
      }
    }

    final db = await ref.read(databaseProvider.future);
    final dao = QuestionDao(db);

    if (mode == ImportMode.replace) {
      await dao.deleteAll();
    }

    if (mode == ImportMode.merge) {
      await dao.upsertAll(questions);
    } else {
      await dao.insertAll(questions);
    }

    return ImportResult(
      total: jsonList.length,
      success: questions.length,
      failed: failedCount,
    );
  }
}
