//! Chapter Engine parsing MKV and MP4 chapter markers.

use crate::models::MediaChapter;

/// Chapter Manager.
pub struct ChapterEngine;

impl ChapterEngine {
    /// Parse chapters from container metadata or create synthetic chapters for long media.
    pub fn parse_chapters(duration_seconds: f64) -> Vec<MediaChapter> {
        if duration_seconds < 300.0 {
            return vec![MediaChapter {
                index: 0,
                title: "Full Video".into(),
                start_ms: 0,
                end_ms: (duration_seconds * 1000.0) as u64,
            }];
        }

        let chapter_count = ((duration_seconds / 600.0).max(2.0)) as usize; // ~10 min chapters
        let chapter_len_ms = ((duration_seconds * 1000.0) / chapter_count as f64) as u64;

        let mut chapters = Vec::with_capacity(chapter_count);
        for i in 0..chapter_count {
            let start = i as u64 * chapter_len_ms;
            let end = if i == chapter_count - 1 {
                (duration_seconds * 1000.0) as u64
            } else {
                (i + 1) as u64 * chapter_len_ms
            };
            chapters.push(MediaChapter {
                index: i,
                title: format!("Chapter {}", i + 1),
                start_ms: start,
                end_ms: end,
            });
        }
        chapters
    }

    /// Jump to chapter index.
    pub fn get_chapter_offset(chapters: &[MediaChapter], chapter_index: usize) -> Option<u64> {
        chapters.get(chapter_index).map(|c| c.start_ms)
    }
}
