//! Bulk index manager for 100,000+ media items.

use crate::error::Result;
use crate::models::SearchResultItem;
use crate::persistence::SearchStore;

/// Bulk Index Manager.
pub struct IndexEngine {
    store: SearchStore,
}

impl IndexEngine {
    pub fn new(store: SearchStore) -> Self {
        Self { store }
    }

    pub fn index_items(&self, items: &[SearchResultItem]) -> Result<()> {
        for item in items {
            self.store.index_item(item, "en", 2024, "hdr 4k 1080p")?;
        }
        Ok(())
    }
}
