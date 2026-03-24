import 'package:fanbae/model/generalsettingmodel.dart' as general_setting;
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/sharedpre.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppGateType {
  none,
  optionalUpdate,
  forceUpdate,
  maintenance,
}

class AppGateDecision {
  const AppGateDecision({
    required this.type,
    this.title = '',
    this.message = '',
    this.currentVersion = '',
    this.targetVersion = '',
    this.updateUrl = '',
    this.updateButtonLabel = 'Update now',
    this.etaText = '',
    this.supportContact = '',
  });

  final AppGateType type;
  final String title;
  final String message;
  final String currentVersion;
  final String targetVersion;
  final String updateUrl;
  final String updateButtonLabel;
  final String etaText;
  final String supportContact;

  bool get isMaintenance => type == AppGateType.maintenance;
  bool get isForceUpdate => type == AppGateType.forceUpdate;
  bool get isOptionalUpdate => type == AppGateType.optionalUpdate;

  static const none = AppGateDecision(type: AppGateType.none);
}

class AppGateService {
  static const String _skippedUpdateVersionKey = 'skipped_app_update_version';

  static Future<AppGateDecision> evaluate(
    List<general_setting.Result> settings,
  ) async {
    final settingMap = _toNormalizedMap(settings);
    final platform = _platformKey;
    final currentVersion = await _getCurrentVersion();

    if (_readBool(settingMap, _maintenanceKeys(platform))) {
      return AppGateDecision(
        type: AppGateType.maintenance,
        title: _readValue(settingMap, _maintenanceTitleKeys(platform)) ??
            'Maintenance in progress',
        message: _readValue(settingMap, _maintenanceMessageKeys(platform)) ??
            'We are temporarily unavailable while we finish scheduled maintenance. Please check back shortly.',
        etaText: _readValue(settingMap, _maintenanceEtaKeys(platform)) ?? '',
        supportContact:
            _readValue(settingMap, _supportContactKeys(platform)) ?? '',
      );
    }

    if (currentVersion == null || currentVersion.isEmpty) {
      return AppGateDecision.none;
    }

    final minimumVersion =
        _readValue(settingMap, _minimumVersionKeys(platform));
    final latestVersion = _readValue(settingMap, _latestVersionKeys(platform));
    final forceUpdateFlag = _readBool(settingMap, _forceUpdateKeys(platform));
    final updateUrl = _readValue(settingMap, _updateUrlKeys(platform)) ??
        _defaultUpdateUrl(platform);

    final bool needsRecommendedUpdate = latestVersion != null &&
        _compareVersions(currentVersion, latestVersion) < 0;
    final bool needsForcedUpdate = (minimumVersion != null &&
            _compareVersions(currentVersion, minimumVersion) < 0) ||
        (forceUpdateFlag && needsRecommendedUpdate);

    if (needsForcedUpdate) {
      return AppGateDecision(
        type: AppGateType.forceUpdate,
        title: _readValue(settingMap, _forceUpdateTitleKeys(platform)) ??
            'Update required',
        message: _readValue(settingMap, _forceUpdateMessageKeys(platform)) ??
            'A newer version of ${Constant.appName} is required to continue. Please update the app and reopen it.',
        currentVersion: currentVersion,
        targetVersion: minimumVersion ?? latestVersion ?? '',
        updateUrl: updateUrl,
      );
    }

    if (!needsRecommendedUpdate) {
      await SharedPre().remove(_skippedUpdateVersionKey);
      return AppGateDecision.none;
    }

    final skippedVersion = await SharedPre().read(_skippedUpdateVersionKey);
    if (skippedVersion != null && skippedVersion == latestVersion) {
      return AppGateDecision.none;
    }

    return AppGateDecision(
      type: AppGateType.optionalUpdate,
      title: _readValue(settingMap, _optionalUpdateTitleKeys(platform)) ??
          'Update available',
      message: _readValue(settingMap, _optionalUpdateMessageKeys(platform)) ??
          'A newer version of ${Constant.appName} is available. Update now for the latest fixes and improvements.',
      currentVersion: currentVersion,
      targetVersion: latestVersion,
      updateUrl: updateUrl,
    );
  }

  static Future<void> showOptionalUpdateDialog(
    BuildContext context,
    AppGateDecision decision,
  ) async {
    if (!decision.isOptionalUpdate) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff10131f),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            decision.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            _buildVersionMessage(decision),
            style: const TextStyle(
              color: Color(0xffcfd6ea),
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (decision.targetVersion.isNotEmpty) {
                  await SharedPre().save(
                    _skippedUpdateVersionKey,
                    decision.targetVersion,
                  );
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text(
                'Later',
                style: TextStyle(color: Color(0xffcfd6ea)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await SharedPre().remove(_skippedUpdateVersionKey);
                await openUpdate(decision.updateUrl);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EB1FC),
                foregroundColor: Colors.black,
              ),
              child: Text(decision.updateButtonLabel),
            ),
          ],
        );
      },
    );
  }

  static Future<void> openUpdate(String rawUrl) async {
    final Uri? uri = Uri.tryParse(rawUrl.trim());
    if (uri == null) return;

    const LaunchMode mode =
        kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication;
    await launchUrl(uri, mode: mode, webOnlyWindowName: '_blank');
  }

  static String buildScreenMessage(AppGateDecision decision) {
    return _buildVersionMessage(decision);
  }

  static Map<String, String> _toNormalizedMap(
    List<general_setting.Result> settings,
  ) {
    final Map<String, String> map = <String, String>{};
    for (final setting in settings) {
      final String key = (setting.key ?? '').trim().toLowerCase();
      if (key.isEmpty) continue;
      map[key] = (setting.value ?? '').trim();
    }
    return map;
  }

  static Future<String?> _getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version.trim();
    } catch (_) {
      return null;
    }
  }

  static bool _readBool(Map<String, String> map, List<String> keys) {
    final value = _readValue(map, keys)?.toLowerCase();
    return value == '1' ||
        value == 'true' ||
        value == 'yes' ||
        value == 'on' ||
        value == 'enabled';
  }

  static String? _readValue(Map<String, String> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key.toLowerCase()];
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static int _compareVersions(String left, String right) {
    final leftParts = _toVersionParts(left);
    final rightParts = _toVersionParts(right);
    final maxLength = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;

    for (int index = 0; index < maxLength; index++) {
      final int leftValue = index < leftParts.length ? leftParts[index] : 0;
      final int rightValue = index < rightParts.length ? rightParts[index] : 0;

      if (leftValue != rightValue) {
        return leftValue.compareTo(rightValue);
      }
    }

    return 0;
  }

  static List<int> _toVersionParts(String version) {
    return version
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }

  static String get _platformKey {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return 'app';
    }
  }

  static List<String> _maintenanceKeys(String platform) => [
        '${platform}_maintenance_mode',
        '${platform}_maintenance',
        'maintenance_mode_$platform',
        'maintenance_$platform',
        'maintenance_mode',
        'app_maintenance_mode',
        'app_maintenance',
        'is_maintenance',
      ];

  static List<String> _forceUpdateKeys(String platform) => [
        '${platform}_force_update',
        'force_update_$platform',
        '${platform}_force_upgrade',
        'force_update',
        'app_force_update',
      ];

  static List<String> _minimumVersionKeys(String platform) => [
        '${platform}_min_version',
        '${platform}_minimum_version',
        'min_version_$platform',
        'minimum_version_$platform',
        '${platform}_minimum_app_version',
        'minimum_app_version',
        'min_app_version',
        'minimum_version',
        'min_version',
      ];

  static List<String> _latestVersionKeys(String platform) => [
        '${platform}_latest_version',
        '${platform}_latest_app_version',
        'latest_version_$platform',
        'latest_app_version_$platform',
        '${platform}_app_version',
        'latest_app_version',
        'latest_version',
        'app_version',
      ];

  static List<String> _updateUrlKeys(String platform) => [
        '${platform}_update_url',
        '${platform}_app_url',
        'update_url_$platform',
        'app_url_$platform',
        'play_store_url',
        'app_store_url',
        'website_url',
        'update_url',
        'app_url',
      ];

  static List<String> _maintenanceTitleKeys(String platform) => [
        '${platform}_maintenance_title',
        'maintenance_title_$platform',
        'maintenance_title',
      ];

  static List<String> _maintenanceMessageKeys(String platform) => [
        '${platform}_maintenance_message',
        'maintenance_message_$platform',
        'maintenance_message',
      ];

  static List<String> _forceUpdateTitleKeys(String platform) => [
        '${platform}_force_update_title',
        'force_update_title_$platform',
        'force_update_title',
        'update_required_title',
      ];

  static List<String> _forceUpdateMessageKeys(String platform) => [
        '${platform}_force_update_message',
        'force_update_message_$platform',
        'force_update_message',
        'update_required_message',
      ];

  static List<String> _optionalUpdateTitleKeys(String platform) => [
        '${platform}_update_title',
        'update_title_$platform',
        'optional_update_title',
        'update_title',
      ];

  static List<String> _optionalUpdateMessageKeys(String platform) => [
        '${platform}_update_message',
        'update_message_$platform',
        'optional_update_message',
        'update_message',
      ];

  static List<String> _maintenanceEtaKeys(String platform) => [
        '${platform}_maintenance_eta',
        'maintenance_eta_$platform',
        '${platform}_back_at',
        'maintenance_eta',
        'maintenance_back_at',
        'maintenance_end_time',
        'back_online_at',
      ];

  static List<String> _supportContactKeys(String platform) => [
        '${platform}_support_contact',
        'support_contact_$platform',
        '${platform}_support_email',
        '${platform}_contact_url',
        'support_email',
        'support_url',
        'contact_email',
        'contact_url',
      ];

  static String _defaultUpdateUrl(String platform) {
    switch (platform) {
      case 'android':
        return Constant.androidAppUrl;
      case 'ios':
        return Constant.iosAppUrl;
      default:
        return Constant.androidAppUrl;
    }
  }

  static String _buildVersionMessage(AppGateDecision decision) {
    final buffer = StringBuffer(decision.message.trim());

    if (decision.currentVersion.isNotEmpty ||
        decision.targetVersion.isNotEmpty) {
      buffer.write('\n\n');
      if (decision.currentVersion.isNotEmpty) {
        buffer.write('Current version: ${decision.currentVersion}');
      }
      if (decision.currentVersion.isNotEmpty &&
          decision.targetVersion.isNotEmpty) {
        buffer.write('\n');
      }
      if (decision.targetVersion.isNotEmpty) {
        buffer.write('Required version: ${decision.targetVersion}');
      }
    }

    return buffer.toString().trim();
  }
}
