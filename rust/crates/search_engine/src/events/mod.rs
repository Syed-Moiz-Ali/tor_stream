//! Event definitions for search and indexing engine.

use serde::{Deserialize, Serialize};

/// Strongly typed search & indexing events.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SearchEvent {
    /// Indexing started.
    IndexingStarted { total_items: usize },
    /// Indexing finished.
    IndexingFinished { indexed_items: usize, duration_ms: u64 },
    /// Collection created or updated.
    CollectionUpdated { collection_id: u64 },
}
