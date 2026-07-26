package com.example.tor_stream

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat

class TorrentService : Service() {

    companion object {
        private const val TAG = "TorStreamService"
        private const val CHANNEL_ID = "tor_stream_channel"
        private const val NOTIFICATION_ID = 1001
        private const val WAKE_LOCK_TAG = "TorStream:WakeLock"
        private const val WIFI_LOCK_TAG = "TorStream:WifiLock"

        private var currentTitle: String = "TorStream"
        private var currentProgress: Double = 0.0
        private var currentSpeed: String = ""
        private var currentActiveCount: Int = 0

        fun start(context: Context) {
            val intent = Intent(context, TorrentService::class.java)
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, TorrentService::class.java)
            context.stopService(intent)
        }

        fun updateNotification(context: Context, title: String, progress: Double, speed: String, activeCount: Int) {
            currentTitle = title
            currentProgress = progress
            currentSpeed = speed
            currentActiveCount = activeCount

            val notification = buildNotification(context)
            val manager = context.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(NOTIFICATION_ID, notification)
        }

        private fun buildNotification(context: Context): Notification {
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val pauseAllIntent = PendingIntent.getBroadcast(
                context,
                1,
                Intent("com.example.tor_stream.PAUSE_ALL").apply {
                    `package` = context.packageName
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val progressMax = 1000
            val progressInt = (currentProgress * progressMax).toInt().coerceIn(0, progressMax)

            val text = if (currentActiveCount > 0) {
                "${currentActiveCount} active · ${currentSpeed} · ${(currentProgress * 100).toInt()}%"
            } else {
                "Downloading torrents in background"
            }

            return NotificationCompat.Builder(context, CHANNEL_ID)
                .setContentTitle(currentTitle)
                .setContentText(text)
                .setSubText(if (currentSpeed.isNotEmpty()) currentSpeed else null)
                .setSmallIcon(android.R.drawable.stat_sys_download)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .setSilent(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setProgress(progressMax, progressInt, false)
                .addAction(
                    android.R.drawable.ic_media_pause,
                    "Pause All",
                    pauseAllIntent
                )
                .build()
        }
    }

    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        acquireWakeLock()
        acquireWifiLock()
        Log.i(TAG, "TorrentService created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildNotification(this)
        startForeground(NOTIFICATION_ID, notification)
        Log.i(TAG, "TorrentService foreground started")
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        releaseWifiLock()
        releaseWakeLock()
        Log.i(TAG, "TorrentService destroyed")
        super.onDestroy()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        flushResumeData()
        stopSelf()
        super.onTaskRemoved(rootIntent)
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "TorStream Downloads",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Ongoing torrent download notifications"
            setSound(null, null)
        }
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    private fun acquireWakeLock() {
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            WAKE_LOCK_TAG
        ).apply {
            acquire()
        }
    }

    private fun releaseWakeLock() {
        wakeLock?.let {
            if (it.isHeld) it.release()
        }
        wakeLock = null
    }

    private fun acquireWifiLock() {
        val wifiManager = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
        wifiLock = wifiManager.createWifiLock(
            WifiManager.WIFI_MODE_FULL_LOW_LATENCY,
            WIFI_LOCK_TAG
        ).apply { acquire() }
    }

    private fun releaseWifiLock() {
        wifiLock?.let {
            if (it.isHeld) it.release()
        }
        wifiLock = null
    }

    private fun flushResumeData() {
        Log.i(TAG, "Flushing resume data before shutdown")
    }
}
