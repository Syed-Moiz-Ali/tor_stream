//! Public Rust API for search_engine.

use std::path::PathBuf;
use std::sync::OnceLock;

use crate::collection_engine::CollectionEngine;
use crate::engine::CoreSearchEngine;
use crate::filter_engine::FilterEngine;
use crate::models::{
    SearchFilters, SearchResultItem, SortOptions,
};
use crate::persistence::SearchStore;

static STORE: OnceLock<SearchStore> = OnceLock::new();
static SEARCH: OnceLock<CoreSearchEngine> = OnceLock::new();
static COLLECTION: OnceLock<CollectionEngine> = OnceLock::new();

fn get_db_path() -> PathBuf {
    let base = std::env::temp_dir().join("tor_stream_data");
    base.join("search_index.db")
}

fn get_store() -> &'static SearchStore {
    STORE.get_or_init(|| {
        let db_path = get_db_path();
        SearchStore::open(&db_path).unwrap()
    })
}

fn get_search_engine() -> &'static CoreSearchEngine {
    SEARCH.get_or_init(|| CoreSearchEngine::new(get_store().clone()))
}

fn get_collection_engine() -> &'static CollectionEngine {
    COLLECTION.get_or_init(|| CollectionEngine::new(get_store().clone()))
}

/// Perform fast full-text search query.
pub fn search(query: String) -> anyhow::Result<Vec<SearchResultItem>> {
    Ok(get_search_engine().execute_search(&query)?)
}

/// Apply multi-criteria filtering to search results.
pub fn filter(items: Vec<SearchResultItem>, filters: SearchFilters) -> anyhow::Result<Vec<SearchResultItem>> {
    Ok(FilterEngine::filter_items(items, &filters))
}

/// Apply sorting to search results.
pub fn sort(items: Vec<SearchResultItem>, options: SortOptions) -> anyhow::Result<Vec<SearchResultItem>> {
    Ok(FilterEngine::sort_items(items, &options))
}

/// Create a custom media collection.
pub fn create_collection(name: String, description: String) -> anyhow::Result<u64> {
    Ok(get_collection_engine().create_collection(&name, &description)?)
}

/// Delete a custom media collection.
pub fn delete_collection(id: u64) -> anyhow::Result<()> {
    get_collection_engine().delete_collection(id)?;
    Ok(())
}

/// Add torrent item to custom collection.
pub fn add_to_collection(collection_id: u64, torrent_id: u64) -> anyhow::Result<()> {
    get_collection_engine().add_item(collection_id, torrent_id)?;
    Ok(())
}

/// Remove torrent item from custom collection.
pub fn remove_from_collection(collection_id: u64, torrent_id: u64) -> anyhow::Result<()> {
    get_collection_engine().remove_item(collection_id, torrent_id)?;
    Ok(())
}
