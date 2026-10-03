import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Данные телефона, которые прикладываются к обращению в поддержку.
typedef DeviceDetails = ({String platform, String osVersion, String deviceModel});

/// Читает платформу, версию ОС и модель телефона.
class DeviceInfoDataSource {
  const DeviceInfoDataSource({DeviceInfoPlugin? plugin}) : _plugin = plugin;

  final DeviceInfoPlugin? _plugin;

  Future<DeviceDetails> load() async {
    final plugin = _plugin ?? DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;

      return (
        platform: 'android',
        osVersion: 'Android ${info.version.release}',
        deviceModel: '${info.manufacturer} ${info.model}'.trim(),
      );
    }

    if (Platform.isIOS) {
      final info = await plugin.iosInfo;

      return (
        platform: 'ios',
        osVersion: '${info.systemName} ${info.systemVersion}',
        deviceModel: info.utsname.machine,
      );
    }

    return (
      platform: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      deviceModel: '',
    );
  }
}
