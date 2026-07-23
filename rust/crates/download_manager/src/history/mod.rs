//! Watch History manager.

use crate::error::Result;
use crate::models::ContinueWatchingItem;
use crate::persistence::LibraryStore;

pub struct HistoryManager {
    store: LibraryStore,
}

impl HistoryManager {
    pub fn new(store: LibraryStore) -> Self {
        Self { store }
    }

    pub fn get_recently_played(&self) -> Result<Vec<ContinueWatchingItem>> {
        self.store.load_continue_watching()
    }
}
