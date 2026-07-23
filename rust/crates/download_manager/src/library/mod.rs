//! Media Library Organizer, Search, and Filtering.

use crate::error::Result;
use crate::models::LibraryItem;
use crate::persistence::LibraryStore;

/// Media Library Organizer.
pub struct MediaLibrary {
    store: LibraryStore,
}

impl MediaLibrary {
    pub fn new(store: LibraryStore) -> Self {
        Self { store }
    }

    pub fn add_item(&self, item: &LibraryItem) -> Result<()> {
        self.store.upsert_library_item(item)
    }

    pub fn get_all(&self) -> Result<Vec<LibraryItem>> {
        self.store.load_library_items()
    }

    pub fn search(&self, query: &str) -> Result<Vec<LibraryItem>> {
        let all = self.get_all()?;
        let q = query.to_lowercase();
        Ok(all
            .into_iter()
            .filter(|item| item.title.to_lowercase().contains(&q))
            .collect())
    }

    pub fn toggle_favorite(&self, torrent_id: u64) -> Result<()> {
        let all = self.get_all()?;
        if let Some(mut item) = all.into_iter().find(|i| i.torrent_id == torrent_id) {
            item.is_favorite = !item.is_favorite;
            self.store.upsert_library_item(&item)?;
        }
        Ok(())
    }
}
