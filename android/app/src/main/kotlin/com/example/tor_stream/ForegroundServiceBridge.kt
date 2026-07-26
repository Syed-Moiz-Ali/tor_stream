package com.example.tor_stream

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger

class ForegroundServiceBridge(private val context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "FgServiceBridge"
        private const val CHANNEL = "tor_stream/foreground_service"
    }

    private val channel: MethodChannel = MethodChannel(messenger, CHANNEL).apply {
        setMethodCallHandler(this@ForegroundServiceBridge)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                TorrentService.start(context)
                result.success(true)
            }
            "stop" -> {
                TorrentService.stop(context)
                result.success(true)
            }
            "updateNotification" -> {
                val title = call.argument<String>("title") ?: "TorStream"
                val progress = call.argument<Double>("progress") ?: 0.0
                val speed = call.argument<String>("speed") ?: ""
                val activeCount = call.argument<Int>("activeCount") ?: 0
                TorrentService.updateNotification(context, title, progress, speed, activeCount)
                result.success(true)
            }
            "requestBatteryOptimizationExemption" -> {
                requestBatteryOptimizationExemption()
                result.success(true)
            }
            "isIgnoringBatteryOptimizations" -> {
                result.success(isIgnoringBatteryOptimizations())
            }
            else -> result.notImplemented()
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pm = context.getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
        return pm.isIgnoringBatteryOptimizations(context.packageName)
    }

    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        if (isIgnoringBatteryOptimizations()) return
        val intent = Intent(
            Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
            android.net.Uri.parse("package:${context.packageName}")
        ).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }

    fun release() {
        channel.setMethodCallHandler(null)
    }
}
