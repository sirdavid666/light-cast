package com.sirdavid.lightcast

import android.content.Context
import android.content.Intent
import android.util.Log
import com.pedro.common.ConnectChecker
import com.pedro.library.rtmp.RtmpDisplay

class RtmpBridge(private val context: Context) {
    private var streaming = false
    private var pendingResultCode: Int = 0
    private var pendingData: Intent? = null

    private val connectChecker = object : ConnectChecker {
        override fun onConnectionStarted(url: String) {
            Log.i(TAG, "RTMP connection starting: $url")
        }
        override fun onConnectionSuccess() {
            Log.i(TAG, "RTMP connected")
        }
        override fun onConnectionFailed(reason: String) {
            Log.e(TAG, "RTMP connection failed: $reason")
            streaming = false
        }
        override fun onNewBitrate(bitrate: Long) {}
        override fun onDisconnect() {
            Log.i(TAG, "RTMP disconnected")
            streaming = false
        }
        override fun onAuthError() {
            Log.e(TAG, "RTMP auth error — check the stream key")
            streaming = false
        }
        override fun onAuthSuccess() {}
    }

    private val rtmpDisplay: RtmpDisplay by lazy {
        RtmpDisplay(context, /* useOpengl = */ true, connectChecker)
    }

    fun attachProjection(resultCode: Int, data: Intent) {
        pendingResultCode = resultCode
        pendingData = data
    }

    fun start(url: String, width: Int, height: Int, bitrate: Int, fps: Int) {
        val data = pendingData
        if (data == null) {
            Log.e(TAG, "start() called before attachProjection() — no screen-capture consent yet")
            return
        }
        val prepared = rtmpDisplay.prepareVideo(width, height, bitrate)
        val audioReady = rtmpDisplay.prepareAudio()
        if (!prepared || !audioReady) {
            Log.e(TAG, "Failed to prepare encoder (video ready=$prepared, audio ready=$audioReady)")
            return
        }
        rtmpDisplay.setIntentResult(pendingResultCode, data)
        rtmpDisplay.startStream(url)
        streaming = true
    }

    fun stop() {
        if (streaming) rtmpDisplay.stopStream()
        streaming = false
    }

    fun isStreaming(): Boolean = streaming

    companion object {
        private const val TAG = "LightCastRtmpBridge"
    }
}
