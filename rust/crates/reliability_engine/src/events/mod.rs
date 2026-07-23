//! Event definitions for reliability engine.

use serde::{Deserialize, Serialize};
use crate::models::{HealthStatus, SessionSnapshot};

/// Strongly typed reliability and recovery events.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ReliabilityEvent {
    /// Recovery procedure initiated.
    RecoveryStarted { cause: String },
    /// Recovery completed successfully.
    RecoveryFinished { restored_sessions_count: usize },
    /// Verification of storage and database started.
    VerificationStarted,
    /// Verification finished with repair counts.
    VerificationFinished { repaired_pieces_count: u32 },
    /// Low storage space warning emitted.
    StorageWarning { available_bytes: u64 },
    /// Previous session snapshot restored.
    SessionRestored { snapshot: SessionSnapshot },
    /// System health status updated.
    HealthStatusUpdated { status: HealthStatus },
}
