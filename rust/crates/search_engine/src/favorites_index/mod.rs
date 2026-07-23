//! Favorites Indexer.

use crate::models::SearchResultItem;

pub fn filter_favorites(items: Vec<SearchResultItem>, favorite_ids: &[u64]) -> Vec<SearchResultItem> {
    items
        .into_iter()
        .filter(|i| favorite_ids.contains(&i.torrent_id))
        .collect()
}
