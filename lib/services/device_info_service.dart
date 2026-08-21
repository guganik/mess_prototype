import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mess_prototype/models/device_info.dart';

class DeviceInfoService {
  static const String _deviceIdKey = 'device_id';

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<DeviceInfo> getDeviceInfo() async {
    final deviceId = await _getOrCreateDeviceId();

    final platformInfo = await _getPlatformInfo();

    return DeviceInfo(
      deviceId: deviceId,
      deviceName: platformInfo.deviceName,
      platform: platformInfo.platform,
    );
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    final savedId = prefs.getString(_deviceIdKey);

    if (savedId != null && savedId.isNotEmpty) {
      return savedId;
    }

    final newId = _generateDeviceId();

    await prefs.setString(_deviceIdKey, newId);

    return newId;
  }

  String _generateDeviceId() {
    final random = Random.secure();

    final parts = List.generate(
      4,
      (_) => random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0'),
    );

    return parts.join('-');
  }

  Future<_PlatformInfo> _getPlatformInfo() async {
    if (kIsWeb) {
      return const _PlatformInfo(
        deviceName: 'Web Browser',
        platform: 'web',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await _deviceInfoPlugin.androidInfo;

        final model = info.model.trim();
        final manufacturer = info.manufacturer.trim();

        final name = [
          manufacturer,
          model,
        ].where((value) => value.isNotEmpty).join(' ');

        return _PlatformInfo(
          deviceName: name.isNotEmpty ? name : 'Android device',
          platform: 'android',
        );

      case TargetPlatform.iOS:
        final info = await _deviceInfoPlugin.iosInfo;

        final name = info.name.trim();

        return _PlatformInfo(
          deviceName: name.isNotEmpty ? name : 'iPhone',
          platform: 'ios',
        );

      case TargetPlatform.windows:
        final info = await _deviceInfoPlugin.windowsInfo;

        final name = info.computerName.trim();

        return _PlatformInfo(
          deviceName: name.isNotEmpty ? name : 'Windows PC',
          platform: 'windows',
        );

      case TargetPlatform.macOS:
        final info = await _deviceInfoPlugin.macOsInfo;

        final name = info.computerName.trim();

        return _PlatformInfo(
          deviceName: name.isNotEmpty ? name : 'Mac',
          platform: 'macos',
        );

      case TargetPlatform.linux:
        final info = await _deviceInfoPlugin.linuxInfo;

        final name = info.prettyName.trim();

        return _PlatformInfo(
          deviceName: name.isNotEmpty ? name : 'Linux PC',
          platform: 'linux',
        );

      case TargetPlatform.fuchsia:
        return const _PlatformInfo(
          deviceName: 'Fuchsia device',
          platform: 'fuchsia',
        );
    }
  }
}

class _PlatformInfo {
  final String deviceName;
  final String platform;

  const _PlatformInfo({
    required this.deviceName,
    required this.platform,
  });
}