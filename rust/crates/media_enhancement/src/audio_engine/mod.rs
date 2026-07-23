//! Audio Track Engine supporting channel layouts and audio delay tuning.

use std::sync::RwLock;

/// Audio Track Manager.
pub struct AudioEngine {
    active_track_index: RwLock<u32>,
    audio_delay_ms: RwLock<i64>,
}

impl AudioEngine {
    pub fn new() -> Self {
        Self {
            active_track_index: RwLock::new(0),
            audio_delay_ms: RwLock::new(0),
        }
    }

    pub fn select_track(&self, index: u32) {
        *self.active_track_index.write().unwrap() = index;
    }

    pub fn get_active_track(&self) -> u32 {
        *self.active_track_index.read().unwrap()
    }

    pub fn set_audio_delay(&self, delay_ms: i64) {
        *self.audio_delay_ms.write().unwrap() = delay_ms;
    }

    pub fn get_audio_delay(&self) -> i64 {
        *self.audio_delay_ms.read().unwrap()
    }
}

impl Default for AudioEngine {
    fn default() -> Self {
        Self::new()
    }
}
