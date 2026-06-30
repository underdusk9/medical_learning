import 'dart:convert';
import 'dart:io';
import '../utils/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../utils/version.dart';

/// 更新检查结果
class UpdateCheckResult {
  final bool hasUpdate;
  final String latestVersion;
  final String? releasePageUrl;
  final String? apkDownloadUrl;
  final String? releaseNotes;

  const UpdateCheckResult({
    required this.hasUpdate,
    required this.latestVersion,
    this.releasePageUrl,
    this.apkDownloadUrl,
    this.releaseNotes,
  });
}

/// 下载错误类型
enum DownloadErrorType { network, permission, diskSpace, hashMismatch, other }

/// 下载错误
class DownloadException implements Exception {
  final DownloadErrorType type;
  final String message;
  const DownloadException(this.type, this.message);

  @override
  String toString() => message;
}

/// GitHub API 镜像列表（镜像优先，避免直连限速）
const List<String> _apiMirrors = [
  'https://ghfast.top/https://api.github.com',
  'https://ghp.ci/https://api.github.com',
  'https://api.github.com',
];

/// GitHub 文件下载镜像
const String _downloadMirror = 'https://ghfast.top';

/// 更新服务
class UpdateService {
  /// 检查更新
  static Future<UpdateCheckResult> checkForUpdate() async {
    Map<String, dynamic>? data;
    String? errorMsg;

    for (final mirror in _apiMirrors) {
      try {
        final uri = Uri.parse(
            '$mirror/repos/${AppConstants.githubRepo}/releases/latest');
        final response = await http
            .get(uri, headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'xiaohan-health/1.0',
        }).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          data = jsonDecode(response.body) as Map<String, dynamic>;
          break;
        } else if (response.statusCode == 404) {
          errorMsg = '没有找到 Release 信息';
        } else if (response.statusCode == 403) {
          errorMsg = 'API 访问受限，尝试镜像...';
        } else {
          errorMsg = '服务器返回 ${response.statusCode}';
        }
      } on SocketException {
        errorMsg = '网络连接失败，请检查网络设置';
      } on http.ClientException {
        errorMsg = '网络请求超时，请稍后重试';
      } catch (e) {
        errorMsg = '连接失败: ${e.toString()}';
      }
    }

    if (data == null) {
      throw DownloadException(DownloadErrorType.network, errorMsg ?? '检查更新失败');
    }

    final tagName = data['tag_name'] as String? ?? '';
    final latestVersion =
        tagName.startsWith('v') ? tagName.substring(1) : tagName;
    final currentVersion = AppConstants.appVersion;
    final hasUpdate = needUpdate(currentVersion, latestVersion);

    // 找 APK 下载链接及哈希
    String? apkUrl;
    String? expectedHash;
    final assets = data['assets'] as List<dynamic>?;
    if (assets != null) {
      for (final asset in assets) {
        final name = (asset['name'] as String?)?.toLowerCase() ?? '';
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          // 尝试读取自定义字段 digest（如果 Release 中有带 sha256 信息）
          final digest = asset['digest'] as String? ?? '';
          if (digest.startsWith('sha256:')) {
            expectedHash = digest.substring(7);
          }
          break;
        }
      }
    }

    return UpdateCheckResult(
      hasUpdate: hasUpdate,
      latestVersion: latestVersion,
      releasePageUrl:
          data['html_url'] as String? ?? AppConstants.githubReleaseUrl,
      apkDownloadUrl: apkUrl,
      releaseNotes: data['body'] as String?,
    );
  }

  /// 带进度 & 哈希校验 & 断点续传的下载
  static Future<String> downloadAPK(
    String url, {
    void Function(double progress)? onProgress,
    String? expectedHash,
  }) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/medical_learning.apk';
    final file = File(filePath);

    // 构造镜像 URL
    final downloadUrl = url.startsWith('https://github.com')
        ? '$_downloadMirror/$url'
        : url;

    // 断点续传：检查本地已有文件
    int existingBytes = 0;
    if (await file.exists()) {
      existingBytes = await file.length();
    }

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));

      // 设置 Range 头实现断点续传
      if (existingBytes > 0) {
        request.headers['Range'] = 'bytes=$existingBytes-';
      }

      final response = await client.send(request);
      final total = response.contentLength ?? 0;
      final expectedTotal =
          existingBytes + (total > 0 ? total : 0);

      // 如果是续传，以追加模式写入
      final raf = await file.open(mode: existingBytes > 0 ? FileMode.append : FileMode.write);
      int received = existingBytes;

      try {
        await for (final chunk in response.stream) {
          await raf.writeFrom(chunk);
          received += chunk.length;
          if (expectedTotal > 0 && onProgress != null) {
            onProgress(received / expectedTotal);
          }
        }
      } finally {
        await raf.close();
      }

      // 哈希校验
      if (expectedHash != null && expectedHash.isNotEmpty) {
        final actualHash = await calculateFileHash(file);
        if (actualHash != expectedHash) {
          await file.delete();
          throw const DownloadException(
              DownloadErrorType.hashMismatch, '文件完整性验证失败，请重新下载');
        }
      }

      return filePath;
    } on SocketException {
      throw const DownloadException(
          DownloadErrorType.network, '网络连接失败，请检查网络');
    } catch (e) {
      if (e is DownloadException) rethrow;
      throw DownloadException(
          DownloadErrorType.other, '下载失败: ${e.toString()}');
    } finally {
      client.close();
    }
  }

  /// 安装 APK
  static Future<void> installAPK(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        String msg = result.message;
        if (msg.contains('Permission')) {
          throw const DownloadException(
              DownloadErrorType.permission, '权限不足，请手动安装 APK');
        }
        throw DownloadException(DownloadErrorType.other, '安装失败: $msg');
      }
    } on DownloadException {
      rethrow;
    } catch (e) {
      throw DownloadException(
          DownloadErrorType.permission, '启动安装程序失败: ${e.toString()}');
    }
  }

  /// 清理下载文件
  static Future<void> cleanDownload() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/medical_learning.apk');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
