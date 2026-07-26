package com.example.tor_stream

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.tor_stream.player.StreamMethodChannel

class MainActivity : FlutterActivity() {

    private var streamChannel: StreamMethodChannel? = null
    private var foregroundBridge: ForegroundServiceBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        streamChannel = StreamMethodChannel(applicationContext, messenger)
        foregroundBridge = ForegroundServiceBridge(applicationContext, messenger)
    }

    override fun onDestroy() {
        streamChannel?.release()
        streamChannel = null
        foregroundBridge?.release()
        foregroundBridge = null
        super.onDestroy()
    }
}
