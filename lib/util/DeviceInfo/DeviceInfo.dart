import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  static final _deviceInfo = DeviceInfoPlugin();
  static Future<String> getPhone() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return '${info.manufacturer}-${info.model}';
    } else if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return '${info.name}-${info.model}';
    } else {
      throw UnimplementedError();
    }
  }
}
