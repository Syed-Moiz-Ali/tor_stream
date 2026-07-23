package com.example.tor_stream.bridge

import android.net.Uri
import androidx.annotation.OptIn
import androidx.media3.common.C
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.BaseDataSource
import androidx.media3.datasource.DataSpec
import java.io.IOException

@OptIn(UnstableApi::class)
class RustDataSource(
    private val torrentId: Long,
    private val fileIndex: Int,
    private val fileSize: Long
) : BaseDataSource(/* isNetwork = */ false) {

    private var handleId: Long = 0
    private var openedUri: Uri? = null
    private var bytesRemaining: Long = 0
    private var isOpened = false

    companion object {
        init {
            System.loadLibrary("tor_stream")
        }

        @JvmStatic
        private external fun nativeOpenStream(torrentId: Long, fileIndex: Int, fileSize: Long): Long

        @JvmStatic
        private external fun nativeReadBytes(handleId: Long, targetBuffer: ByteArray, offset: Int, length: Int): Int

        @JvmStatic
        private external fun nativeSeek(handleId: Long, position: Long): Boolean

        @JvmStatic
        private external fun nativeCloseStream(handleId: Long)
    }

    override fun open(spec: DataSpec): Long {
        openedUri = spec.uri
        transferInitializing(spec)

        handleId = nativeOpenStream(torrentId, fileIndex, fileSize)
        if (handleId <= 0) {
            throw IOException("Failed to open Rust stream handle for torrentId=$torrentId, fileIndex=$fileIndex")
        }

        if (spec.position > 0) {
            nativeSeek(handleId, spec.position)
        }

        bytesRemaining = if (spec.length != C.LENGTH_UNSET.toLong()) {
            spec.length
        } else {
            fileSize - spec.position
        }

        isOpened = true
        transferStarted(spec)
        return bytesRemaining
    }

    override fun read(buffer: ByteArray, offset: Int, length: Int): Int {
        if (length == 0) return 0
        if (bytesRemaining == 0L) return C.RESULT_END_OF_INPUT

        val bytesToRead = if (bytesRemaining == C.LENGTH_UNSET.toLong()) {
            length
        } else {
            minOf(bytesRemaining, length.toLong()).toInt()
        }

        val readBytes = nativeReadBytes(handleId, buffer, offset, bytesToRead)
        if (readBytes < 0) {
            return C.RESULT_END_OF_INPUT
        }

        if (bytesRemaining != C.LENGTH_UNSET.toLong()) {
            bytesRemaining -= readBytes
        }

        bytesTransferred(readBytes)
        return readBytes
    }

    override fun getUri(): Uri? = openedUri

    override fun close() {
        if (isOpened) {
            isOpened = false
            nativeCloseStream(handleId)
            handleId = 0
            transferEnded()
        }
    }
}
