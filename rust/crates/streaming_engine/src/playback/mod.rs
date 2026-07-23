//! Thread-safe Playback State Machine.

use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::{info, warn};

use crate::error::{StreamingError, Result};
use crate::models::PlaybackState;

/// Thread-safe playback state machine.
#[derive(Clone)]
pub struct PlaybackStateMachine {
    torrent_id: u64,
    file_index: u32,
    current_state: Arc<RwLock<PlaybackState>>,
}

impl PlaybackStateMachine {
    pub fn new(torrent_id: u64, file_index: u32) -> Self {
        Self {
            torrent_id,
            file_index,
            current_state: Arc::new(RwLock::new(PlaybackState::Idle)),
        }
    }

    pub async fn state(&self) -> PlaybackState {
        *self.current_state.read().await
    }

    /// Attempt a state transition. Enforces valid state machine rules.
    pub async fn transition_to(&self, new_state: PlaybackState) -> Result<PlaybackState> {
        let mut guard = self.current_state.write().await;
        let old = *guard;

        if old == new_state {
            return Ok(old);
        }

        let valid = match (old, new_state) {
            (PlaybackState::Idle, PlaybackState::Preparing) => true,
            (PlaybackState::Preparing, PlaybackState::Buffering) => true,
            (PlaybackState::Preparing, PlaybackState::Error) => true,
            (PlaybackState::Buffering, PlaybackState::Ready) => true,
            (PlaybackState::Buffering, PlaybackState::Playing) => true,
            (PlaybackState::Buffering, PlaybackState::Error) => true,
            (PlaybackState::Ready, PlaybackState::Playing) => true,
            (PlaybackState::Ready, PlaybackState::Seeking) => true,
            (PlaybackState::Playing, PlaybackState::Paused) => true,
            (PlaybackState::Playing, PlaybackState::Seeking) => true,
            (PlaybackState::Playing, PlaybackState::Recovering) => true,
            (PlaybackState::Playing, PlaybackState::Completed) => true,
            (PlaybackState::Paused, PlaybackState::Playing) => true,
            (PlaybackState::Paused, PlaybackState::Seeking) => true,
            (PlaybackState::Seeking, PlaybackState::Buffering) => true,
            (PlaybackState::Seeking, PlaybackState::Ready) => true,
            (PlaybackState::Recovering, PlaybackState::Playing) => true,
            (PlaybackState::Recovering, PlaybackState::Ready) => true,
            (PlaybackState::Recovering, PlaybackState::Error) => true,
            (_, PlaybackState::Error) => true,
            (_, PlaybackState::Idle) => true,
            _ => false,
        };

        if !valid {
            warn!(
                torrent_id = self.torrent_id,
                file_index = self.file_index,
                from = old.as_str(),
                to = new_state.as_str(),
                "Invalid playback state transition attempt"
            );
            return Err(StreamingError::InvalidStateTransition {
                from: old.as_str().to_string(),
                to: new_state.as_str().to_string(),
            });
        }

        info!(
            torrent_id = self.torrent_id,
            file_index = self.file_index,
            from = old.as_str(),
            to = new_state.as_str(),
            "Playback state changed"
        );

        *guard = new_state;
        Ok(old)
    }
}
