//! Recently Played Indexer.

use crate::models::SearchResultItem;

pub fn filter_recently_played(items: Vec<SearchResultItem>) -> Vec<SearchResultItem> {
    items.into_iter().filter(|i| i.progress > 0.0).collect()
}
