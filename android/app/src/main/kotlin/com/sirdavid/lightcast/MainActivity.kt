package com.sirdavid.lightcast

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "lightcast/rtmp"
    private val projectionRequestCode = 4201
    private var pendingPermissionResult: MethodChannel.Result? = null
    private lateinit var rtmpBridge: RtmpBridge

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        rtmpBridge = RtmpBridge(this)

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
                        rtmpBridge.start(
                            url = args["url"] as String,
                            width = args["width"] as Int,
                            height = args["height"] as Int,
                            bitrate = args["bitrate"] as Int,
                            fps = args["fps"] as Int,
                        )
                        result.success(null)
                    }
                    "stopStream" -> {
                        rtmpBridge.stop()
                        result.success(null)
                    }
                    "isStreaming" -> result.success(rtmpBridge.isStreaming())
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == projectionRequestCode) {
            val granted = resultCode == Activity.RESULT_OK && data != null
            if (granted) rtmpBridge.attachProjection(resultCode, data!!)
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }
}
