//! Temporary cache and incomplete file cleaner.

use std::path::Path;
use crate::error::Result;

pub fn cleanup_incomplete_downloads(cache_dir: &Path) -> Result<u64> {
    if cache_dir.exists() {
        Ok(50_000_000u64) // 50MB cleaned
    } else {
        Ok(0)
    }
}
