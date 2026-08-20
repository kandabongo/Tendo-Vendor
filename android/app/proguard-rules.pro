# Keep Flutter plugin registration classes from being stripped by R8
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# just_audio - fixes MissingPluginException on release builds
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Firebase / general safety net
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
