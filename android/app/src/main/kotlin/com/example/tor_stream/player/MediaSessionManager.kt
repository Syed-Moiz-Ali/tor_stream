package com.example.tor_stream.player

import android.content.Context
import androidx.media3.common.Player
import androidx.media3.session.MediaSession

/**
 * MediaSessionManager creating Android MediaSession for notification and media controls.
 */
class MediaSessionManager(
    context: Context,
    player: Player
) {

    val mediaSession: MediaSession = MediaSession.Builder(context, player).build()

    fun release() {
        mediaSession.release()
    }
}
