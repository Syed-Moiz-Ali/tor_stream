//! Media query methods and collection helpers.

use crate::models::{Artwork, MediaFile, SubtitleTrack, TorrentMedia};

impl TorrentMedia {
    /// Get primary playable video file.
    pub fn main_video(&self) -> Option<&MediaFile> {
        self.primary_video.as_ref()
    }

    /// Get all subtitle tracks.
    pub fn subtitles(&self) -> &[SubtitleTrack] {
        &self.subtitles
    }

    /// Get all artwork entries.
    pub fn artwork(&self) -> &[Artwork] {
        &self.artwork
    }

    /// Get all detected video files.
    pub fn video_files(&self) -> &[MediaFile] {
        &self.videos
    }
}
