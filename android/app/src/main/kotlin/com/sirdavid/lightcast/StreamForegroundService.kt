package com.sirdavid.lightcast

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log

class StreamForegroundService : Service() {

    private val rtmpBridge by lazy { RtmpBridge(this) }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundWithNotification()

        when (intent?.action) {
            ACTION_START -> {
                val url = intent.getStringExtra(EXTRA_URL)
                val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, -1)
                val projectionData = intent.getParcelableExtra<Intent>(EXTRA_PROJECTION_DATA)

                if (url == null || projectionData == null) {
                    Log.e(TAG, "Missing URL or projection data — cannot start stream")
                    stopSelf()
                    return START_NOT_STICKY
                }

                rtmpBridge.attachProjection(resultCode, projectionData)
                rtmpBridge.start(
                    url = url,
                    width = intent.getIntExtra(EXTRA_WIDTH, 1280),
                    height = intent.getIntExtra(EXTRA_HEIGHT, 720),
                    bitrate = intent.getIntExtra(EXTRA_BITRATE, 2500000),
                    fps = intent.getIntExtra(EXTRA_FPS, 30),
                )
            }
            ACTION_STOP -> {
                rtmpBridge.stop()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        rtmpBridge.stop()
        super.onDestroy()
    }

    private fun startForegroundWithNotification() {
        val channelId = "lightcast_stream_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, "LightCast Streaming", NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }

        val notification: Notification = Notification.Builder(this, channelId)
            .setContentTitle("LightCast is live")
            .setContentText("Streaming to Facebook Live")
            .setSmallIcon(android.R.drawable.ic_media_play)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    companion object {
        private const val TAG = "StreamForegroundService"
        private const val NOTIFICATION_ID = 4202
        const val ACTION_START = "com.sirdavid.lightcast.action.START_STREAM"
        const val ACTION_STOP = "com.sirdavid.lightcast.action.STOP_STREAM"
        const val EXTRA_URL = "extra_url"
        const val EXTRA_WIDTH = "extra_width"
        const val EXTRA_HEIGHT = "extra_height"
        const val EXTRA_BITRATE = "extra_bitrate"
        const val EXTRA_FPS = "extra_fps"
        const val EXTRA_RESULT_CODE = "extra_result_code"
        const val EXTRA_PROJECTION_DATA = "extra_projection_data"
    }
}
