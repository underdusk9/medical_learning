import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../core/database_helper.dart';

/// 数据库 Provider
final databaseProvider = FutureProvider<Database>((ref) async {
  return DatabaseHelper.instance.database;
});
