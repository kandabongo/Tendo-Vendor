package com.tendo.vendor


import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper

import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val NOTIFICATIONS_CHANNEL = "notifications.manage"
    private val LIFECYCLE_CHANNEL = "app.lifecycle/events"

    private var lifecycleMethodChannel: MethodChannel? = null

    // Native looping alert for new jobs. Plays res/raw/alert_new with Android's own
    // MediaPlayer so it does not depend on any Flutter audio plugin being registered.
    private var alertPlayer: MediaPlayer? = null
    private val alertHandler = Handler(Looper.getMainLooper())
    private val alertAutoStop = Runnable { stopAlert() }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Existing notifications channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATIONS_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getChannels") {
                val notificationChannels = getNotificationChannels()
                if (notificationChannels != null) {
                    result.success(notificationChannels)
                } else {
                    result.error("UNAVAILABLE", "No notification channels", null)
                }
            } else if (call.method == "playAlert") {
                result.success(playAlert())
            } else if (call.method == "stopAlert") {
                stopAlert()
                result.success(true)
            } else if (call.method == "deleteChannel") {
                deleteNotificationChannel(call.argument("id")!!)
                result.success("Notification channel deleted")
            } else {
                result.notImplemented()
            }
        }

        // New lifecycle events channel
        lifecycleMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LIFECYCLE_CHANNEL)
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // Notify Flutter that user is leaving app (before background)
        lifecycleMethodChannel?.invokeMethod("onUserLeaveHint", null)
    }

    private fun playAlert(): Boolean {
        stopAlert()
        return try {
            val afd = resources.openRawResourceFd(R.raw.alert_new)
            val player = MediaPlayer()
            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()
            player.isLooping = true
            player.prepare()
            player.start()
            alertPlayer = player
            // safety: never ring forever
            alertHandler.postDelayed(alertAutoStop, 60000)
            true
        } catch (e: Exception) {
            android.util.Log.e("TendoAlert", "playAlert failed", e)
            false
        }
    }

    private fun stopAlert() {
        alertHandler.removeCallbacks(alertAutoStop)
        try {
            alertPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (e: Exception) {
            android.util.Log.e("TendoAlert", "stopAlert failed", e)
        }
        alertPlayer = null
    }

    override fun onDestroy() {
        stopAlert()
        super.onDestroy()
    }

    private fun getNotificationChannels(): List<String>? {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.notificationChannels.map { it -> "${it.id} -- ${it.name}" }.toList()
        } else {
            null
        }
    }

    private fun deleteNotificationChannel(channelId: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.deleteNotificationChannel(channelId)
        }
    }
}
