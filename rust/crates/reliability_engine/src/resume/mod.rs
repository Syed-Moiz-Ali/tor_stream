//! Auto-resumption manager for app launch and reboot.

use crate::models::SessionSnapshot;

/// Evaluates if a snapshot should auto-resume on boot or launch.
pub fn should_auto_resume(snapshot: &SessionSnapshot, max_inactivity_ms: i64) -> bool {
    let now_ms = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0);

    (now_ms - snapshot.last_active_timestamp_ms) <= max_inactivity_ms
}
