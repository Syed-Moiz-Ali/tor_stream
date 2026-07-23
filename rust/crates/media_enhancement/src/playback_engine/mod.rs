//! Playback enhancements (speed presets, loop/repeat, skip forward/backward).

use std::sync::RwLock;

/// Playback Speed Presets & Preferences.
pub struct PlaybackEngine {
    speed: RwLock<f32>,
    loop_enabled: RwLock<bool>,
    #[allow(dead_code)]
    repeat_enabled: RwLock<bool>,
}

impl PlaybackEngine {
    pub fn new() -> Self {
        Self {
            speed: RwLock::new(1.0),
            loop_enabled: RwLock::new(false),
            repeat_enabled: RwLock::new(false),
        }
    }

    pub fn set_speed(&self, speed: f32) -> f32 {
        let clamped = speed.clamp(0.25, 3.0);
        *self.speed.write().unwrap() = clamped;
        clamped
    }

    pub fn get_speed(&self) -> f32 {
        *self.speed.read().unwrap()
    }

    pub fn set_loop(&self, enabled: bool) {
        *self.loop_enabled.write().unwrap() = enabled;
    }

    pub fn is_loop(&self) -> bool {
        *self.loop_enabled.read().unwrap()
    }
}

impl Default for PlaybackEngine {
    fn default() -> Self {
        Self::new()
    }
}
