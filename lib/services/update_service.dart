import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../core/constants.dart';

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

/// 检查 GitHub Release 更新
class UpdateService {
  /// 从 GitHub API 获取最新版本信息
  static Future<UpdateCheckResult> checkForUpdate() async {
    try {
      final uri = Uri.parse(
          'https://api.github.com/repos/${AppConstants.githubRepo}/releases/latest');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) {
        return const UpdateCheckResult(
          hasUpdate: false,
          latestVersion: AppConstants.appVersion,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final latestVersion = tagName.startsWith('v')
          ? tagName.substring(1)
          : tagName;

      final currentVersion = AppConstants.appVersion;
      final hasUpdate = _compareVersions(latestVersion, currentVersion) > 0;

      // 从 assets 中找到 APK 文件下载链接
      String? apkUrl;
      final assets = data['assets'] as List<dynamic>?;
      if (assets != null) {
        for (final asset in assets) {
          final name = (asset['name'] as String?)?.toLowerCase() ?? '';
          if (name.endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
      }

      return UpdateCheckResult(
        hasUpdate: hasUpdate,
        latestVersion: latestVersion,
        releasePageUrl: data['html_url'] as String? ?? AppConstants.githubReleaseUrl,
        apkDownloadUrl: apkUrl,
        releaseNotes: data['body'] as String?,
      );
    } catch (e) {
      return const UpdateCheckResult(
        hasUpdate: false,
        latestVersion: AppConstants.appVersion,
      );
    }
  }

  /// 下载 APK 并触发安装
  static Future<String> downloadAndInstall(String url) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/medical_learning.apk');

    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);

    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception('安装失败：${result.message}');
    }
    return file.path;
  }

  /// 版本号比较
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.tryParse).whereNotNull().toList();
    final parts2 = v2.split('.').map(int.tryParse).whereNotNull().toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 != p2) return p1 - p2;
    }
    return 0;
  }
}

extension _WhereNotNull<T> on Iterable<T?> {
  Iterable<T> whereNotNull() => where((e) => e != null).cast<T>();
}
