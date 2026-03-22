import 'device_settings_service.dart';

class BatteryOptimizationService {
  static Future<bool?> isIgnoringBatteryOptimizations() async {
    // `true` means the app is exempt from battery optimization on Android.
    return DeviceSettingsService.isIgnoringBatteryOptimizations();
  }

  static Future<bool> openSettings({required bool requestIgnore}) async {
    // Reuse the shared device-settings bridge so Settings UI and reminder flows
    // behave the same way everywhere in the app.
    return DeviceSettingsService.openBatteryOptimizationSettings(
      requestIgnore: requestIgnore,
    );
  }
}
