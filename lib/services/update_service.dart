import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String releaseUrl;
  final bool hasUpdate;

  const UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.releaseUrl,
    required this.hasUpdate,
  });
}

class UpdateService {
  static const _cacheKey = 'update_last_checked';
  static const _cachedVersionKey = 'update_cached_latest_version';
  static const _cacheHours = 24;
  static const _repoOwner = 'jayshivram';
  static const _repoName = 'Precision';

  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;
  UpdateService._();

  /// Returns [UpdateInfo] if an update check was performed or cached result
  /// exists. Respects 24-hour cache to avoid spamming GitHub API.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version; // e.g. "1.0.3"

      final lastCheckedMs = prefs.getInt(_cacheKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = Duration(milliseconds: now - lastCheckedMs);

      String? latestVersion;

      if (cacheAge.inHours < _cacheHours) {
        // Use cached version if within 24 hours
        latestVersion = prefs.getString(_cachedVersionKey);
      }

      if (latestVersion == null) {
        // Fetch from GitHub
        final response = await http
            .get(
              Uri.parse(
                  'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest'),
              headers: {'Accept': 'application/vnd.github.v3+json'},
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final tag = (data['tag_name'] as String?) ?? '';
          // Strip leading 'v' if present: "v1.0.4" → "1.0.4"
          latestVersion = tag.startsWith('v') ? tag.substring(1) : tag;
          // Persist cache
          await prefs.setInt(_cacheKey, now);
          await prefs.setString(_cachedVersionKey, latestVersion);
        } else {
          return null;
        }
      }

      if (latestVersion.isEmpty) return null;

      final hasUpdate = _isNewer(latestVersion, currentVersion);
      return UpdateInfo(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        releaseUrl:
            'https://github.com/$_repoOwner/$_repoName/releases/latest',
        hasUpdate: hasUpdate,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns true if [remote] version is strictly newer than [local].
  /// Compares semver numerically: "1.0.4" > "1.0.3".
  static bool _isNewer(String remote, String local) {
    final r = _parts(remote);
    final l = _parts(local);
    for (int i = 0; i < 3; i++) {
      final ri = i < r.length ? r[i] : 0;
      final li = i < l.length ? l[i] : 0;
      if (ri > li) return true;
      if (ri < li) return false;
    }
    return false;
  }

  static List<int> _parts(String v) =>
      v.split('.').map((s) => int.tryParse(s) ?? 0).toList();
}
