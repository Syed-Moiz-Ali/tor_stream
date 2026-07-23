//! Domain models for search and discovery.

use serde::{Deserialize, Serialize};

/// Search Filter Options.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SearchFilters {
    pub category: Option<String>,
    pub status: Option<String>,
    pub is_favorite: Option<bool>,
    pub continue_watching: Option<bool>,
    pub resolution: Option<String>,
    pub audio_language: Option<String>,
}

/// Sort criteria options.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SortBy {
    Title,
    DateAdded,
    LastPlayed,
    Progress,
    Duration,
    FileSize,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SortDirection {
    Ascending,
    Descending,
}

/// Sort Options structure.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SortOptions {
    pub sort_by: SortBy,
    pub direction: SortDirection,
}

impl Default for SortOptions {
    fn default() -> Self {
        Self {
            sort_by: SortBy::DateAdded,
            direction: SortDirection::Descending,
        }
    }
}

/// Search Result entry.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SearchResultItem {
    pub torrent_id: u64,
    pub title: String,
    pub category: String,
    pub file_name: String,
    pub resolution: String,
    pub codec: String,
    pub total_bytes: u64,
    pub progress: f32,
    pub relevance_score: f32,
}

/// Custom Collection entity.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaCollection {
    pub id: u64,
    pub name: String,
    pub description: String,
    pub torrent_ids: Vec<u64>,
    pub created_at_ms: i64,
}

/// Duplicate Media Group entry.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DuplicateGroup {
    pub group_key: String,
    pub title: String,
    pub torrent_ids: Vec<u64>,
    pub qualities: Vec<String>,
}
