//! Continue Watching progress manager.

use crate::error::Result;
use crate::models::ContinueWatchingItem;
use crate::persistence::LibraryStore;

/// Continue Watching Manager.
pub struct ContinueWatchingManager {
    store: LibraryStore,
}

impl ContinueWatchingManager {
    pub fn new(store: LibraryStore) -> Self {
        Self { store }
    }

    pub fn update_progress(&self, item: ContinueWatchingItem) -> Result<()> {
        self.store.upsert_continue_watching(&item)
    }

    pub fn get_items(&self) -> Result<Vec<ContinueWatchingItem>> {
        self.store.load_continue_watching()
    }
}
