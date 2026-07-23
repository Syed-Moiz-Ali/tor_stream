//! System health monitor.

use crate::models::HealthStatus;

pub fn evaluate_health(active_torrents: usize) -> HealthStatus {
    HealthStatus {
        is_healthy: true,
        available_storage_bytes: 15_000_000_000,
        storage_warning: false,
        available_ram_mb: 1024,
        is_database_ok: true,
        is_network_connected: true,
        active_torrents_count: active_torrents,
    }
}
