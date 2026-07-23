package com.example.tor_stream.player

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class StreamMethodChannel(
    context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "tor_stream/player")
    private val playerManager = PlayerManager(context, channel)

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "prepareStream" -> {
                val torrentId = call.argument<Number>("torrentId")?.toLong() ?: 0L
                val fileIndex = call.argument<Number>("fileIndex")?.toInt() ?: 0
                val fileSize = call.argument<Number>("fileSize")?.toLong() ?: 0L
                val title = call.argument<String>("title") ?: "TorStream"

                playerManager.prepareStream(torrentId, fileIndex, fileSize, title)
                result.success(true)
            }
            "play" -> {
                playerManager.play()
                result.success(true)
            }
            "pause" -> {
                playerManager.pause()
                result.success(true)
            }
            "seekTo" -> {
                val positionMs = call.argument<Number>("positionMs")?.toLong() ?: 0L
                playerManager.seekTo(positionMs)
                result.success(true)
            }
            "stop" -> {
                playerManager.stop()
                result.success(true)
            }
            "getPlaybackState" -> {
                result.success(playerManager.getPlaybackState())
            }
            "getPositionMs" -> {
                result.success(playerManager.getPositionMs())
            }
            "getDurationMs" -> {
                result.success(playerManager.getDurationMs())
            }
            else -> result.notImplemented()
        }
    }

    fun release() {
        channel.setMethodCallHandler(null)
        playerManager.release()
    }
}
