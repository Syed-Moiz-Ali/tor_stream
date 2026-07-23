//! Favorites manager.

use crate::error::Result;
use crate::models::LibraryItem;
use crate::persistence::LibraryStore;

pub struct FavoritesManager {
    store: LibraryStore,
}

impl FavoritesManager {
    pub fn new(store: LibraryStore) -> Self {
        Self { store }
    }

    pub fn get_favorites(&self) -> Result<Vec<LibraryItem>> {
        let all = self.store.load_library_items()?;
        Ok(all.into_iter().filter(|i| i.is_favorite).collect())
    }
}
