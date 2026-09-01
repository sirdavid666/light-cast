package com.sirdavid.lightcast

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "lightcast/rtmp"
    private val projectionRequestCode = 4201
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingResultCode: Int = -1
    private var pendingProjectionData: Intent? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestScreenCapture" -> {
                        pendingPermissionResult = result
                        val mgr = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
                        startActivityForResult(mgr.createScreenCaptureIntent(), projectionRequestCode)
                    }
                    "startStream" -> {
                        val args = call.arguments as Map<*, *>
                        val data = pendingProjectionData
                        if (data == null) {
                            result.error("NO_PERMISSION", "Screen capture was not granted", null)
                            return@setMethodCallHandler
                        }
                        val intent = Intent(this, StreamForegroundService::class.java).apply {
                            action = StreamForegroundService.ACTION_START
                            putExtra(StreamForegroundService.EXTRA_URL, args["url"] as String)
                            putExtra(StreamForegroundService.EXTRA_WIDTH, args["width"] as Int)
                            putExtra(StreamForegroundService.EXTRA_HEIGHT, args["height"] as Int)
                            putExtra(StreamForegroundService.EXTRA_BITRATE, args["bitrate"] as Int)
                            putExtra(StreamForegroundService.EXTRA_FPS, args["fps"] as Int)
                            putExtra(StreamForegroundService.EXTRA_RESULT_CODE, pendingResultCode)
                            putExtra(StreamForegroundService.EXTRA_PROJECTION_DATA, data)
                        }
                        ContextCompat.startForegroundService(this, intent)
                        result.success(null)
                    }
                    "stopStream" -> {
                        val intent = Intent(this, StreamForegroundService::class.java).apply {
                            action = StreamForegroundService.ACTION_STOP
                        }
                        startService(intent)
                        result.success(null)
                    }
                    "isStreaming" -> result.success(false)
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == projectionRequestCode) {
            val granted = resultCode == Activity.RESULT_OK && data != null
            if (granted) {
                pendingResultCode = resultCode
                pendingProjectionData = data
            }
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }
}
