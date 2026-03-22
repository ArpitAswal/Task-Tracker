package com.example.todo_task

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity()
{
    // One channel handles all device-settings actions triggered from Flutter.
    private val deviceSettingsChannel = "task_tracker/device_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            deviceSettingsChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }
                "openNotificationSettings" -> {
                    // Flutter uses this when the user needs to fix blocked
                    // notification permission from inside the app.
                    result.success(openNotificationSettings())
                }
                "openBatteryOptimizationSettings" -> {
                    val requestIgnore =
                        call.argument<Boolean>("requestIgnore") ?: false
                    result.success(openBatteryOptimizationSettings(requestIgnore))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true
        }

        // `true` means Android is not actively optimizing this app in the
        // background, which gives reminders a better chance to fire on time.
        val powerManager = getSystemService(PowerManager::class.java)
        return powerManager?.isIgnoringBatteryOptimizations(packageName) ?: false
    }

    private fun openBatteryOptimizationSettings(requestIgnore: Boolean): Boolean {
        return try {
            // `requestIgnore=true` opens the app-specific approval screen.
            // Otherwise we fall back to the general battery optimization list.
            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && requestIgnore) {
                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                }
            } else {
                Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
            }

            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openNotificationSettings(): Boolean {
        return try {
            // Android versions expose app notification settings differently, so
            // we choose the best screen available for the current API level.
            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                }
            } else {
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                }
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }
}
