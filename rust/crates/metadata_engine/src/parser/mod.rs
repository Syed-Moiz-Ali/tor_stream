//! Torrent metadata parser.

use std::path::Path;
use crate::detector::detect_media_type;
use crate::models::{FileCategory, MediaFile};

/// Raw torrent file entry input.
#[derive(Debug, Clone)]
pub struct RawFileEntry {
    pub index: u32,
    pub path: String,
    pub size: u64,
}

/// Parse raw torrent file entries into initial [`MediaFile`] instances.
pub fn parse_file_entries(entries: &[RawFileEntry]) -> Vec<MediaFile> {
    entries
        .iter()
        .map(|entry| {
            let path_obj = Path::new(&entry.path);
            let file_name = path_obj
                .file_name()
                .and_then(|n| n.to_str())
                .unwrap_or(&entry.path)
                .to_string();
            let extension = path_obj
                .extension()
                .and_then(|e| e.to_str())
                .unwrap_or("")
                .to_lowercase();

            let media_type = detect_media_type(&extension);

            MediaFile {
                file_index: entry.index,
                path: entry.path.clone(),
                file_name,
                extension,
                size: entry.size,
                media_type,
                category: FileCategory::Ignored,
                confidence_score: 0.0,
                video_info: None,
                audio_tracks: Vec::new(),
                subtitle_tracks: Vec::new(),
            }
        })
        .collect()
}
