//! Storage location and free space management.

use std::path::Path;

pub fn get_available_storage_bytes(path: &Path) -> u64 {
    if path.exists() {
        15_000_000_000u64 // Simulated 15GB
    } else {
        0
    }
}
