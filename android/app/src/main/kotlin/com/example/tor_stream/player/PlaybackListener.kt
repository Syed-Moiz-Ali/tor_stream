package com.example.tor_stream.player

import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import io.flutter.plugin.common.MethodChannel

class PlaybackListener(
    private val channel: MethodChannel
) : Player.Listener {

    override fun onPlaybackStateChanged(state: Int) {
        val stateStr = matchState(state)
        channel.invokeMethod("onPlaybackStateChanged", mapOf("state" to stateStr))
    }

    override fun onIsPlayingChanged(isPlaying: Boolean) {
        channel.invokeMethod("onIsPlayingChanged", mapOf("isPlaying" to isPlaying))
    }

    override fun onPlayerError(error: PlaybackException) {
        channel.invokeMethod("onPlayerError", mapOf("message" to (error.message ?: "Unknown playback error")))
    }

    private fun matchState(state: Int): String {
        return when (state) {
            Player.STATE_IDLE -> "idle"
            Player.STATE_BUFFERING -> "buffering"
            Player.STATE_READY -> "ready"
            Player.STATE_ENDED -> "completed"
            else -> "unknown"
        }
    }
}
