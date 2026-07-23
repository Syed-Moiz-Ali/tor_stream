//! Dynamic Cache Auto-tuner based on system memory resources.

/// Calculates optimal memory cache size (in bytes) based on total system RAM and video resolution.
pub fn calculate_optimal_cache_bytes(total_ram_mb: u32, is_4k: bool) -> u64 {
    let base_mb = if is_4k {
        if total_ram_mb >= 6144 { // 6GB+ RAM
            128
        } else if total_ram_mb >= 4096 { // 4GB RAM
            96
        } else {
            64
        }
    } else {
        if total_ram_mb >= 4096 {
            64
        } else if total_ram_mb >= 2048 {
            48
        } else {
            32
        }
    };

    (base_mb as u64) * 1024 * 1024
}
