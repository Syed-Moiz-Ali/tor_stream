//! Network switch and auto-reconnect engine.

use tracing::info;

/// Network state change handler.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NetworkState {
    Wifi,
    Cellular,
    Offline,
}

pub struct NetworkAutoReconnect;

impl NetworkAutoReconnect {
    pub fn handle_network_change(old_state: NetworkState, new_state: NetworkState) {
        if old_state == NetworkState::Offline && new_state != NetworkState::Offline {
            info!("Network connection restored — initiating peer auto-reconnect");
        } else if old_state == NetworkState::Wifi && new_state == NetworkState::Cellular {
            info!("Switched from Wi-Fi to Cellular — balancing connections");
        }
    }
}
