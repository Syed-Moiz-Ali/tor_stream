//! Subtitle Engine supporting SRT, ASS, SSA, VTT, SUB, IDX, PGS, SUP and visual styling.

use std::sync::RwLock;

use crate::models::{SubtitleConfig, SubtitleFormat};

/// Subtitle Manager.
pub struct SubtitleEngine {
    config: RwLock<SubtitleConfig>,
}

impl SubtitleEngine {
    pub fn new() -> Self {
        Self {
            config: RwLock::new(SubtitleConfig::default()),
        }
    }

    pub fn set_config(&self, config: SubtitleConfig) {
        *self.config.write().unwrap() = config;
    }

    pub fn get_config(&self) -> SubtitleConfig {
        self.config.read().unwrap().clone()
    }

    pub fn parse_format_by_extension(ext: &str) -> SubtitleFormat {
        match ext.to_lowercase().as_str() {
            "ass" => SubtitleFormat::Ass,
            "ssa" => SubtitleFormat::Ssa,
            "vtt" => SubtitleFormat::Vtt,
            "sub" => SubtitleFormat::Sub,
            "idx" => SubtitleFormat::Idx,
            "pgs" => SubtitleFormat::Pgs,
            "sup" => SubtitleFormat::Sup,
            _ => SubtitleFormat::Srt,
        }
    }

    pub fn adjust_delay(&self, delta_ms: i64) -> i64 {
        let mut cfg = self.config.write().unwrap();
        cfg.delay_ms += delta_ms;
        cfg.delay_ms
    }
}

impl Default for SubtitleEngine {
    fn default() -> Self {
        Self::new()
    }
}
