## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Firebase
-keep class com.google.firebase.** { *; }

## Flutter Play Core / Deferred Components
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.internal.play_billing.**
-keep class com.google.android.play.core.** { *; }
