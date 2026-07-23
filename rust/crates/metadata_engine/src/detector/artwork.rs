//! Artwork classification for poster, backdrop, cover, thumbnail.

use crate::models::{Artwork, ArtworkType};

/// Classify image file into [`Artwork`].
pub fn classify_artwork(file_index: u32, path: &str, size: u64) -> Artwork {
    let lower = path.to_lowercase();
    let artwork_type = if lower.contains("poster") || lower.contains("cover") || lower.contains("folder") {
        ArtworkType::Poster
    } else if lower.contains("fanart") || lower.contains("backdrop") || lower.contains("background") {
        ArtworkType::Backdrop
    } else if lower.contains("thumb") || lower.contains("preview") {
        ArtworkType::Thumbnail
    } else {
        ArtworkType::Cover
    };

    Artwork {
        file_index,
        path: path.to_string(),
        size,
        artwork_type,
    }
}
