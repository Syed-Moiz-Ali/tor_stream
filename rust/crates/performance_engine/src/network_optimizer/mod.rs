//! Network optimizer for peer selection and connection balancing.

/// Calculates dynamic upload rate limit to prevent choking playback download bandwidth.
pub fn calculate_adaptive_upload_limit(download_speed_bps: u64) -> u64 {
    if download_speed_bps < 1_000_000 {
        // Less than 1MB/s download: limit upload to 50KB/s to preserve ACK bandwidth
        50 * 1024
    } else if download_speed_bps < 5_000_000 {
        200 * 1024
    } else {
        0 // Unlimited upload when download is fast
    }
}
