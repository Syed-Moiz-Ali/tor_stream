//! Multi-criteria Filter Engine.

use crate::models::{SearchFilters, SearchResultItem, SortBy, SortDirection, SortOptions};

/// Filter and Sort Engine.
pub struct FilterEngine;

impl FilterEngine {
    pub fn filter_items(items: Vec<SearchResultItem>, filters: &SearchFilters) -> Vec<SearchResultItem> {
        items
            .into_iter()
            .filter(|item| {
                if let Some(cat) = &filters.category {
                    if !item.category.eq_ignore_ascii_case(cat) {
                        return false;
                    }
                }
                if let Some(res) = &filters.resolution {
                    if !item.resolution.eq_ignore_ascii_case(res) {
                        return false;
                    }
                }
                true
            })
            .collect()
    }

    pub fn sort_items(mut items: Vec<SearchResultItem>, options: &SortOptions) -> Vec<SearchResultItem> {
        items.sort_by(|a, b| {
            let cmp = match options.sort_by {
                SortBy::Title => a.title.cmp(&b.title),
                SortBy::FileSize => a.total_bytes.cmp(&b.total_bytes),
                SortBy::Progress => a.progress.partial_cmp(&b.progress).unwrap_or(std::cmp::Ordering::Equal),
                _ => a.torrent_id.cmp(&b.torrent_id),
            };

            if options.direction == SortDirection::Descending {
                cmp.reverse()
            } else {
                cmp
            }
        });
        items
    }
}
