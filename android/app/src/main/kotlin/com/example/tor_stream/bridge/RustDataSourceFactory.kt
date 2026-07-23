package com.example.tor_stream.bridge

import androidx.annotation.OptIn
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DataSource

@OptIn(UnstableApi::class)
class RustDataSourceFactory(
    private val torrentId: Long,
    private val fileIndex: Int,
    private val fileSize: Long
) : DataSource.Factory {

    override fun createDataSource(): DataSource {
        return RustDataSource(torrentId, fileIndex, fileSize)
    }
}
