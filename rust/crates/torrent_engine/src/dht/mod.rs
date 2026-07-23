//! DHT (Distributed Hash Table) management.
//!
//! The DHT allows finding peers for a torrent without a centralised tracker.
//! librqbit bootstraps DHT automatically from a set of well-known nodes.
//! This module exposes the DHT configuration and status.

use crate::config::EngineConfig;

/// DHT configuration derived from [`EngineConfig`].
#[derive(Debug, Clone)]
pub struct DhtConfig {
    /// Whether DHT is enabled for this session.
    pub enabled: bool,
    /// Whether to persist the DHT routing table to disk across restarts.
    pub persist_routing_table: bool,
}

impl DhtConfig {
    /// Build a [`DhtConfig`] from the global engine config.
    pub fn from_engine_config(config: &EngineConfig) -> Self {
        Self {
            enabled:               config.dht_enabled,
            persist_routing_table: true,
        }
    }
}

/// Current DHT runtime status.
#[derive(Debug, Clone, Default)]
pub struct DhtStatus {
    /// Number of nodes in the routing table.
    pub node_count: u32,
    /// Whether the DHT is currently bootstrapped and searching.
    pub is_bootstrapped: bool,
}

/// Manages DHT configuration and status reporting.
///
/// DHT is started automatically by the librqbit `Session` based on
/// `SessionOptions::disable_dht`. This struct records the configuration
/// and exposes it for diagnostics.
#[derive(Clone)]
pub struct DhtManager {
    config: DhtConfig,
}

impl DhtManager {
    pub fn new(config: DhtConfig) -> Self {
        Self { config }
    }

    /// Whether DHT is enabled.
    pub fn is_enabled(&self) -> bool {
        self.config.enabled
    }

    /// Returns the static DHT configuration.
    pub fn config(&self) -> &DhtConfig {
        &self.config
    }
}
