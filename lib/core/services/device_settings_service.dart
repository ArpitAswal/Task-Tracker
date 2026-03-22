import 'dart:io';

import 'package:flutter/services.dart';

class DeviceSettingsService {
  // Shared platform channel for opening OS-level settings pages that Flutter
  // cannot fully control on its own.
  static const MethodChannel _channel = MethodChannel(
    'task_tracker/device_settings',
  );

  static Future<bool> openNotificationSettings() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return false;
    final result = await _channel.invokeMethod<bool>('openNotificationSettings');
    return result ?? false;
  }

  static Future<bool> openBatteryOptimizationSettings({
    required bool requestIgnore,
  }) async {
    if (!Platform.isAndroid) return false;
    // Android decides the final battery-optimization state, so we only route
    // the user to the correct system screen.
    final result = await _channel.invokeMethod<bool>(
      'openBatteryOptimizationSettings',
      {'requestIgnore': requestIgnore},
    );
    return result ?? false;
  }

  static Future<bool?> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return null;
    return await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
  }
}
