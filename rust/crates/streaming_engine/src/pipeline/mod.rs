//! Streaming Pipeline Coordinator.

use std::time::Instant;
use tracing::info;

use crate::buffer::{BufferConfig, BufferManager};
use crate::cache::MemoryCache;
use crate::error::{StreamingError, Result};
use crate::models::{BufferStatus, CacheStatus, PlaybackState, StreamStatistics};
use crate::monitor::StreamMonitor;
use crate::playback::PlaybackStateMachine;
use crate::reader::StreamingReader;
use crate::scheduler::PieceScheduler;
use crate::statistics::StreamStatisticsCollector;
use torrent_engine::EventBus;

/// Pipeline coordinator for an active adaptive torrent stream session.
pub struct StreamingPipeline {
    pub torrent_id: u64,
    pub file_index: u32,
    pub file_size: u64,
    pub state_machine: PlaybackStateMachine,
    pub buffer_manager: BufferManager,
    pub scheduler: PieceScheduler,
    pub memory_cache: MemoryCache,
    pub reader: StreamingReader,
    pub stats: StreamStatisticsCollector,
    pub monitor: StreamMonitor,
    pub event_bus: EventBus,
    start_time: Instant,
}

impl StreamingPipeline {
    pub fn new(
        torrent_id: u64,
        file_index: u32,
        file_size: u64,
        piece_length: u32,
        total_pieces: u32,
        file_start_piece: u32,
        file_num_pieces: u32,
        cache_capacity_bytes: u64,
        event_bus: EventBus,
    ) -> Self {
        let state_machine = PlaybackStateMachine::new(torrent_id, file_index);
        let buffer_manager = BufferManager::new(torrent_id, file_index, BufferConfig::default());
        let scheduler = PieceScheduler::new(
            torrent_id,
            file_index,
            piece_length,
            total_pieces,
            file_start_piece,
            file_num_pieces,
        );
        let memory_cache = MemoryCache::new(cache_capacity_bytes);
        let reader = StreamingReader::new(
            torrent_id,
            file_index,
            file_size,
            piece_length,
            file_start_piece,
            memory_cache.clone(),
        );
        let stats = StreamStatisticsCollector::new(torrent_id, file_index);
        let monitor = StreamMonitor::new(buffer_manager.clone(), state_machine.clone());

        Self {
            torrent_id,
            file_index,
            file_size,
            state_machine,
            buffer_manager,
            scheduler,
            memory_cache,
            reader,
            stats,
            monitor,
            event_bus,
            start_time: Instant::now(),
        }
    }

    pub async fn prepare(&self) -> Result<()> {
        self.state_machine.transition_to(PlaybackState::Preparing).await?;
        self.event_bus.publish(torrent_engine::EngineEvent::Error {
            id: Some(self.torrent_id),
            message: "Stream prepare".to_string(),
            fatal: false,
        });

        self.state_machine.transition_to(PlaybackState::Buffering).await?;
        self.scheduler.update_playback_position(0).await;
        Ok(())
    }

    pub async fn start(&self) -> Result<()> {
        let current = self.state_machine.state().await;
        if current == PlaybackState::Buffering || current == PlaybackState::Ready || current == PlaybackState::Paused {
            self.state_machine.transition_to(PlaybackState::Playing).await?;
            let latency = self.start_time.elapsed().as_millis() as u64;
            self.stats.record_startup_latency(latency).await;
            self.stats.record_state(PlaybackState::Playing).await;
            info!(torrent_id = self.torrent_id, latency_ms = latency, "Stream playback started");
        }
        Ok(())
    }

    pub async fn pause(&self) -> Result<()> {
        self.state_machine.transition_to(PlaybackState::Paused).await?;
        self.stats.record_state(PlaybackState::Paused).await;
        Ok(())
    }

    pub async fn resume(&self) -> Result<()> {
        self.state_machine.transition_to(PlaybackState::Playing).await?;
        self.stats.record_state(PlaybackState::Playing).await;
        Ok(())
    }

    pub async fn seek(&self, target_offset_bytes: u64) -> Result<()> {
        if target_offset_bytes >= self.file_size {
            return Err(StreamingError::InvalidSeekOffset {
                offset_bytes: target_offset_bytes,
                file_size: self.file_size,
            });
        }

        self.state_machine.transition_to(PlaybackState::Seeking).await?;
        self.scheduler.update_playback_position(target_offset_bytes).await;
        self.state_machine.transition_to(PlaybackState::Buffering).await?;
        info!(torrent_id = self.torrent_id, offset = target_offset_bytes, "Stream seek completed");
        Ok(())
    }

    pub async fn stop(&self) -> Result<()> {
        let _ = self.state_machine.transition_to(PlaybackState::Idle).await;
        self.stats.record_state(PlaybackState::Idle).await;
        Ok(())
    }

    pub async fn get_buffer_status(&self) -> BufferStatus {
        self.buffer_manager.status().await
    }

    pub async fn get_cache_status(&self) -> CacheStatus {
        self.memory_cache.status().await
    }

    pub async fn get_statistics(&self) -> StreamStatistics {
        self.stats.get().await
    }
}
