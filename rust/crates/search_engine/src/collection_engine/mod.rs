//! Collection Manager for custom user media lists.

use crate::error::Result;
use crate::persistence::SearchStore;

/// Collection Manager.
pub struct CollectionEngine {
    store: SearchStore,
}

impl CollectionEngine {
    pub fn new(store: SearchStore) -> Self {
        Self { store }
    }

    pub fn create_collection(&self, name: &str, description: &str) -> Result<u64> {
        self.store.create_collection(name, description)
    }

    pub fn delete_collection(&self, id: u64) -> Result<()> {
        self.store.delete_collection(id)
    }

    pub fn add_item(&self, collection_id: u64, torrent_id: u64) -> Result<()> {
        self.store.add_to_collection(collection_id, torrent_id)
    }

    pub fn remove_item(&self, collection_id: u64, torrent_id: u64) -> Result<()> {
        self.store.remove_from_collection(collection_id, torrent_id)
    }
}
