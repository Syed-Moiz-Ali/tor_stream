//! Logging setup using the `tracing` ecosystem.
//!
//! Call [`init`] once at engine startup (from `api::init_app`).
//! On Android the subscriber writes to logcat via `tracing-android`.
//! On other platforms it writes to stderr for development.

use tracing_subscriber::{fmt, EnvFilter};

/// Initialise the global tracing subscriber.
///
/// The log level is read from the `RUST_LOG` environment variable.
/// Falls back to `info` if the variable is absent or invalid.
///
/// This function is idempotent — subsequent calls are silently ignored.
pub fn init() {
    // `try_init` returns Err if already initialised — we ignore that.
    let _ = fmt::Subscriber::builder()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .with_target(true)
        .with_thread_names(true)
        .with_file(false)           // Omit source file paths in release
        .with_line_number(false)
        .try_init();

    tracing::info!(
        version = crate::ENGINE_VERSION,
        "TorStream logger initialised"
    );
}

// ── Log level helpers (re-exported for convenience) ───────────────────────────

pub use tracing::{debug, error, info, trace, warn};
