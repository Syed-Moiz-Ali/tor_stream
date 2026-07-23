//! Thumbnail Engine generating timeline and preview thumbnails.

use std::path::PathBuf;
use crate::models::MediaThumbnail;

/// Thumbnail Generator & Cache Manager.
pub struct ThumbnailEngine;

impl ThumbnailEngine {
    /// Generate timeline thumbnails spaced at intervals.
    pub fn generate_timeline_thumbnails(
        duration_seconds: f64,
        interval_seconds: u32,
        cache_dir: &PathBuf,
    ) -> Vec<MediaThumbnail> {
        let count = (duration_seconds / interval_seconds as f64).max(1.0) as usize;
        let mut list = Vec::with_capacity(count);

        for i in 0..count {
            let ts_ms = (i * interval_seconds as usize * 1000) as u64;
            let path = cache_dir.join(format!("thumb_{}.jpg", ts_ms));
            list.push(MediaThumbnail {
                timestamp_ms: ts_ms,
                image_path: path.to_string_lossy().to_string(),
                width: 320,
                height: 180,
            });
        }
        list
    }
}
