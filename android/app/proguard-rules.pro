# Keep Flutter plugin registration classes from being stripped by R8
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# just_audio - fixes MissingPluginException on release builds
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Firebase / general safety net
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# just_audio 0.10.x is built on androidx.media3 (not the old ExoPlayer v2 above).
# Without these, R8 strips/renames media3 classes, the just_audio plugin fails to
# register in release builds, and the new-order alert sound throws
# MissingPluginException (com.ryanheise.just_audio.methods).
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**
-keep class com.ryanheise.audioservice.** { *; }
-dontwarn com.ryanheise.**
-keep class com.ryanheise.audio_session.** { *; }
