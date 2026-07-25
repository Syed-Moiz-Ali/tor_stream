package com.example.tor_stream.player

import android.content.Context
import android.net.Uri
import androidx.annotation.OptIn
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.exoplayer.upstream.DefaultAllocator
import com.example.tor_stream.bridge.RustDataSourceFactory
import io.flutter.plugin.common.MethodChannel

@OptIn(UnstableApi::class)
class PlayerManager(
    private val context: Context,
    private val channel: MethodChannel
) {

    private var exoPlayer: ExoPlayer? = null
    private var mediaSessionManager: MediaSessionManager? = null
    private var listener: PlaybackListener? = null

    fun prepareStream(torrentId: Long, fileIndex: Int, fileSize: Long, title: String) {
        release()

        // Aggressive micro-buffer: start playback after just 500ms of data
        val loadControl = DefaultLoadControl.Builder()
            .setAllocator(DefaultAllocator(true, C.DEFAULT_BUFFER_SEGMENT_SIZE))
            .setBufferDurationsMs(
                /* minBufferMs        = */ 2000,
                /* maxBufferMs        = */ 10000,
                /* bufferForPlaybackMs = */ 500,
                /* bufferForPlaybackAfterRebufferMs = */ 1000
            )
            .build()

        val player = ExoPlayer.Builder(context)
            .setLoadControl(loadControl)
            .build()
        exoPlayer = player

        val listenerImpl = PlaybackListener(channel)
        listener = listenerImpl
        player.addListener(listenerImpl)

        val factory = RustDataSourceFactory(torrentId, fileIndex, fileSize)
        val mediaItem = MediaItem.Builder()
            .setUri(Uri.parse("rust://stream/$torrentId/$fileIndex"))
            .setMediaId("$torrentId:$fileIndex")
            .build()

        val mediaSource = ProgressiveMediaSource.Factory(factory)
            .createMediaSource(mediaItem)

        player.setMediaSource(mediaSource)
        player.prepare()

        mediaSessionManager = MediaSessionManager(context, player)
    }

    fun play() {
        exoPlayer?.play()
    }

    fun pause() {
        exoPlayer?.pause()
    }

    fun seekTo(positionMs: Long) {
        exoPlayer?.seekTo(positionMs)
    }

    fun stop() {
        exoPlayer?.stop()
    }

    fun release() {
        listener?.let { exoPlayer?.removeListener(it) }
        mediaSessionManager?.release()
        exoPlayer?.release()
        exoPlayer = null
        mediaSessionManager = null
        listener = null
    }

    fun getPlaybackState(): String {
        val player = exoPlayer ?: return "idle"
        if (player.isPlaying) return "playing"
        return when (player.playbackState) {
            ExoPlayer.STATE_BUFFERING -> "buffering"
            ExoPlayer.STATE_READY -> "ready"
            ExoPlayer.STATE_ENDED -> "completed"
            else -> "idle"
        }
    }

    fun getPositionMs(): Long = exoPlayer?.currentPosition ?: 0L
    fun getDurationMs(): Long = exoPlayer?.duration ?: 0L
}
