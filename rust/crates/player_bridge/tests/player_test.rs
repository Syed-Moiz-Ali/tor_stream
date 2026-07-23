//! Unit and integration tests for player_bridge.

use player_bridge::{close_handle, get_handle, open_handle};

#[tokio::test]
async fn test_stream_handle_lifecycle() {
    let handle_id = open_handle(100, 0, 50_000_000);
    assert!(handle_id > 0);

    let handle = get_handle(handle_id);
    assert!(handle.is_some());

    let h = handle.unwrap();
    assert_eq!(h.torrent_id, 100);
    assert_eq!(h.file_index, 0);
    assert_eq!(h.file_size, 50_000_000);

    close_handle(handle_id);
    assert!(get_handle(handle_id).is_none());
}
