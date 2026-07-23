//! Fast disk I/O and piece validation optimizer.

use sha1::{Digest, Sha1};

/// Fast piece hash validation helper.
pub fn validate_piece_hash(data: &[u8], expected_hash: &[u8; 20]) -> bool {
    let mut hasher = Sha1::new();
    hasher.update(data);
    let result = hasher.finalize();
    result.as_slice() == expected_hash
}
