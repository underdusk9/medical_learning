import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;

/// 计算文件的 SHA256 哈希
Future<String> calculateFileHash(File file) async {
  final bytes = await file.readAsBytes();
  final digest = crypto.sha256.convert(bytes);
  return digest.toString();
}
