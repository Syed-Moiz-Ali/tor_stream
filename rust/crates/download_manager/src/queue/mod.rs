//! Download Queue Manager handling concurrency, state transitions, and priority scheduling.

use std::sync::Arc;
use dashmap::DashMap;
use tracing::info;

use crate::error::{DownloadManagerError, Result};
use crate::models::{DownloadState, DownloadTask, QueuePriority};
use crate::persistence::LibraryStore;

/// Thread-safe Download Queue Manager.
#[derive(Clone)]
pub struct DownloadQueue {
    store: LibraryStore,
    tasks: Arc<DashMap<u64, DownloadTask>>,
    max_active: usize,
}

impl DownloadQueue {
    pub fn new(store: LibraryStore, max_active: usize) -> Result<Self> {
        let queue = Self {
            store: store.clone(),
            tasks: Arc::new(DashMap::new()),
            max_active,
        };

        // Hydrate from SQLite
        let loaded = store.load_all_downloads()?;
        for task in loaded {
            queue.tasks.insert(task.id, task);
        }
        Ok(queue)
    }

    pub fn enqueue_task(&self, mut task: DownloadTask) -> Result<()> {
        task.state = DownloadState::Queued;
        self.store.upsert_download(&task)?;
        self.tasks.insert(task.id, task);
        self.process_queue()?;
        Ok(())
    }

    pub fn pause_task(&self, id: u64) -> Result<()> {
        if let Some(mut task) = self.tasks.get_mut(&id) {
            task.state = DownloadState::Paused;
            self.store.upsert_download(&task)?;
            info!(id, "Download task paused");
        } else {
            return Err(DownloadManagerError::TaskNotFound { id });
        }
        self.process_queue()?;
        Ok(())
    }

    pub fn resume_task(&self, id: u64) -> Result<()> {
        if let Some(mut task) = self.tasks.get_mut(&id) {
            task.state = DownloadState::Queued;
            self.store.upsert_download(&task)?;
            info!(id, "Download task resumed");
        } else {
            return Err(DownloadManagerError::TaskNotFound { id });
        }
        self.process_queue()?;
        Ok(())
    }

    pub fn cancel_task(&self, id: u64) -> Result<()> {
        if let Some(mut task) = self.tasks.get_mut(&id) {
            task.state = DownloadState::Cancelled;
            self.store.upsert_download(&task)?;
        } else {
            return Err(DownloadManagerError::TaskNotFound { id });
        }
        self.process_queue()?;
        Ok(())
    }

    pub fn set_priority(&self, id: u64, priority: QueuePriority) -> Result<()> {
        if let Some(mut task) = self.tasks.get_mut(&id) {
            task.priority = priority;
            self.store.upsert_download(&task)?;
        } else {
            return Err(DownloadManagerError::TaskNotFound { id });
        }
        self.process_queue()?;
        Ok(())
    }

    pub fn process_queue(&self) -> Result<()> {
        let active_count = self
            .tasks
            .iter()
            .filter(|t| t.state == DownloadState::Downloading)
            .count();

        if active_count >= self.max_active {
            return Ok(());
        }

        let slots_available = self.max_active - active_count;
        let mut queued_ids: Vec<(u64, QueuePriority, i64)> = self
            .tasks
            .iter()
            .filter(|t| t.state == DownloadState::Queued)
            .map(|t| (t.id, t.priority, t.added_at_ms))
            .collect();

        // Sort by Priority DESC, then added_at ASC
        queued_ids.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.2.cmp(&b.2)));

        for (id, _, _) in queued_ids.into_iter().take(slots_available) {
            if let Some(mut task) = self.tasks.get_mut(&id) {
                task.state = DownloadState::Downloading;
                self.store.upsert_download(&task)?;
                info!(id, "Promoted queued download to active Downloading state");
            }
        }
        Ok(())
    }

    pub fn get_all(&self) -> Vec<DownloadTask> {
        let mut list: Vec<DownloadTask> = self.tasks.iter().map(|r| r.value().clone()).collect();
        list.sort_by(|a, b| b.priority.cmp(&a.priority).then_with(|| a.added_at_ms.cmp(&b.added_at_ms)));
        list
    }
}
