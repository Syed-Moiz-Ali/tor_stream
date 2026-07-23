//! Bandwidth controls and limits.

use crate::models::BandwidthSettings;
use std::sync::RwLock;

pub struct BandwidthManager {
    settings: RwLock<BandwidthSettings>,
}

impl BandwidthManager {
    pub fn new() -> Self {
        Self {
            settings: RwLock::new(BandwidthSettings::default()),
        }
    }

    pub fn set_limits(&self, settings: BandwidthSettings) {
        *self.settings.write().unwrap() = settings;
    }

    pub fn get_settings(&self) -> BandwidthSettings {
        self.settings.read().unwrap().clone()
    }
}

impl Default for BandwidthManager {
    fn default() -> Self {
        Self::new()
    }
}
