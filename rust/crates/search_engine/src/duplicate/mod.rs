//! Duplicate Media Detection Engine.

use std::collections::HashMap;
use crate::models::{DuplicateGroup, SearchResultItem};

/// Duplicate Detector.
pub struct DuplicateDetector;

impl DuplicateDetector {
    /// Detect duplicate items across different resolutions or encodings.
    pub fn detect_duplicates(items: &[SearchResultItem]) -> Vec<DuplicateGroup> {
        let mut map: HashMap<String, Vec<&SearchResultItem>> = HashMap::new();

        for item in items {
            let normalized_title = item.title.to_lowercase().replace('.', " ").replace('_', " ");
            map.entry(normalized_title).or_default().push(item);
        }

        let mut groups = Vec::new();
        for (key, list) in map {
            if list.len() > 1 {
                let ids = list.iter().map(|i| i.torrent_id).collect();
                let qualities = list.iter().map(|i| i.resolution.clone()).collect();
                groups.push(DuplicateGroup {
                    group_key: key,
                    title: list[0].title.clone(),
                    torrent_ids: ids,
                    qualities,
                });
            }
        }
        groups
    }
}
