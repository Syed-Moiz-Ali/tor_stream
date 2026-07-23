//! Subtitle tracking & manager module.

use crate::models::SubtitleTrack;

/// Helper manager for collecting subtitle tracks across files.
#[derive(Debug, Clone, Default)]
pub struct SubtitleManager {
    tracks: Vec<SubtitleTrack>,
}

impl SubtitleManager {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn add(&mut self, track: SubtitleTrack) {
        self.tracks.push(track);
    }

    pub fn tracks(&self) -> &[SubtitleTrack] {
        &self.tracks
    }

    pub fn into_tracks(self) -> Vec<SubtitleTrack> {
        self.tracks
    }
}
