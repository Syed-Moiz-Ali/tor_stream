//! Performance and Health Monitor for active stream pipeline.

use crate::buffer::BufferManager;
use crate::models::PlaybackState;
use crate::playback::PlaybackStateMachine;

/// Monitors buffer health and triggers stall/recovery state transitions.
pub struct StreamMonitor {
    buffer_manager: BufferManager,
    state_machine: PlaybackStateMachine,
}

impl StreamMonitor {
    pub fn new(buffer_manager: BufferManager, state_machine: PlaybackStateMachine) -> Self {
        Self {
            buffer_manager,
            state_machine,
        }
    }

    /// Check buffer health and evaluate state transitions.
    pub async fn check_health(&self) {
        let status = self.buffer_manager.status().await;
        let current_state = self.state_machine.state().await;

        if status.is_buffering && current_state == PlaybackState::Playing {
            let _ = self.state_machine.transition_to(PlaybackState::Recovering).await;
        } else if status.is_ready && current_state == PlaybackState::Recovering {
            let _ = self.state_machine.transition_to(PlaybackState::Playing).await;
        } else if status.is_ready && current_state == PlaybackState::Buffering {
            let _ = self.state_machine.transition_to(PlaybackState::Ready).await;
        }
    }
}
