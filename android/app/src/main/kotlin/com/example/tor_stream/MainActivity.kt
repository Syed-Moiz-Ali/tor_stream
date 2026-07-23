package com.example.tor_stream

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.tor_stream.player.StreamMethodChannel

class MainActivity : FlutterActivity() {

    private var streamChannel: StreamMethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        streamChannel = StreamMethodChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        streamChannel?.release()
        streamChannel = null
        super.onDestroy()
    }
}
