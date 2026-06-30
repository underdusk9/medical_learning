import 'dart:math';

/// 版本比较：需要更新返回 true
/// 支持 "1.3.0" vs "1.4.0" / "v1.3.0" vs "v1.4.0"
bool needUpdate(String localVersion, String remoteVersion) {
  // 去掉可能的 v 前缀
  final cleanLocal = localVersion.startsWith('v')
      ? localVersion.substring(1)
      : localVersion;
  final cleanRemote = remoteVersion.startsWith('v')
      ? remoteVersion.substring(1)
      : remoteVersion;

  final local = cleanLocal.split('.');
  final remote = cleanRemote.split('.');
  final maxLen = max(local.length, remote.length);
  for (int i = 0; i < maxLen; i++) {
    final l = i < local.length ? int.tryParse(local[i]) ?? 0 : 0;
    final r = i < remote.length ? int.tryParse(remote[i]) ?? 0 : 0;
    if (r > l) return true;
    if (r < l) return false;
  }
  return false;
}
