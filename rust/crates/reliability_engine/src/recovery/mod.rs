//! Process death and crash recovery manager.

use std::path::Path;
use tracing::info;

use crate::error::Result;
use crate::models::SessionSnapshot;
use crate::persistence::SessionStore;

/// Recovery Manager for process death and unexpected crash restoration.
pub struct RecoveryManager {
    store: SessionStore,
}

impl RecoveryManager {
    pub fn new(db_path: &Path) -> Result<Self> {
        let store = SessionStore::open(db_path)?;
        Ok(Self { store })
    }

    /// Restore the most recent active session snapshot.
    pub fn restore_latest_session(&self) -> Result<Option<SessionSnapshot>> {
        info!("Initiating crash & process death session recovery");
        self.store.load_latest_snapshot()
    }

    /// Save current session state.
    pub fn save_session_state(&self, snapshot: &SessionSnapshot) -> Result<()> {
        self.store.save_snapshot(snapshot)
    }
}
