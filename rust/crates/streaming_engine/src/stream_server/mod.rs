//! Local HTTP byte-range stream server for ExoPlayer / video_player.
//!
//! Uses raw tokio TcpListener to avoid adding axum/hyper as dependencies.
//! Only handles `GET /stream/{torrent_id}/{file_index}` with `Range` support.

use std::io::SeekFrom;
use std::sync::Arc;
use std::time::Duration;

use once_cell::sync::Lazy;
use tokio::io::{AsyncReadExt, AsyncSeekExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::Mutex;
use tracing::{error, info};

use crate::bridge::ensure_prepared;
use crate::models::StreamUrl;

static SERVER: Lazy<Mutex<Option<Arc<StreamServer>>>> = Lazy::new(|| Mutex::new(None));

const CHUNK_SIZE: usize = 16 * 1024;  // 16KB — smaller = faster first byte to player
const READ_TIMEOUT: Duration = Duration::from_secs(5);  // Retry faster if piece not ready

/// Local HTTP stream server.
#[derive(Clone)]
pub struct StreamServer {
    base_url: String,
}

impl StreamServer {
    /// Start the server on an OS-assigned loopback port, or return the existing one.
    pub async fn ensure_started() -> anyhow::Result<Arc<Self>> {
        let mut guard = SERVER.lock().await;
        if let Some(server) = guard.as_ref() {
            return Ok(Arc::clone(server));
        }

        let listener = TcpListener::bind("127.0.0.1:0").await?;
        let port = listener.local_addr()?.port();
        let base_url = format!("http://127.0.0.1:{}", port);

        let server = Arc::new(StreamServer { base_url: base_url.clone() });

        tokio::spawn(async move {
            info!(port, "Stream server listening");
            loop {
                match listener.accept().await {
                    Ok((stream, _)) => {
                        let base = base_url.clone();
                        tokio::spawn(handle_connection(stream, base));
                    }
                    Err(e) => {
                        error!(error = %e, "Stream server accept error");
                    }
                }
            }
        });

        *guard = Some(Arc::clone(&server));
        Ok(server)
    }

    /// Build a URL for a specific torrent file.
    pub async fn stream_url(&self, torrent_id: u64, file_index: u32) -> StreamUrl {
        let info = match torrent_engine::bridge::get_torrent_file_info(torrent_id, file_index).await {
            Ok(info) => info,
            Err(_) => {
                return StreamUrl {
                    url: format!("{}/stream/{}/{}", self.base_url, torrent_id, file_index),
                    content_type: "application/octet-stream".to_string(),
                    total_length: 0,
                };
            }
        };

        StreamUrl {
            url: format!("{}/stream/{}/{}", self.base_url, torrent_id, file_index),
            content_type: guess_content_type(&info.path),
            total_length: info.size,
        }
    }
}

async fn handle_connection(mut stream: TcpStream, _base_url: String) {
    let mut buf = [0u8; 4096];

    let n = match tokio::time::timeout(Duration::from_secs(5), stream.read(&mut buf)).await {
        Ok(Ok(n)) if n > 0 => n,
        _ => return,
    };

    let request = match std::str::from_utf8(&buf[..n]) {
        Ok(s) => s,
        Err(_) => return,
    };

    // Parse request line: GET /stream/{torrent_id}/{file_index} HTTP/1.1
    let (method, path) = match parse_request_line(request) {
        Some(v) => v,
        None => {
            let _ = respond(&mut stream, "400 Bad Request", "", "").await;
            return;
        }
    };

    if method != "GET" {
        let _ = respond(&mut stream, "405 Method Not Allowed", "", "").await;
        return;
    }

    let path_parts: Vec<&str> = path.split('/').filter(|s| !s.is_empty()).collect();
    if path_parts.len() != 3 || path_parts[0] != "stream" {
        let _ = respond(&mut stream, "404 Not Found", "", "").await;
        return;
    }

    let torrent_id: u64 = match path_parts[1].parse() {
        Ok(v) => v,
        Err(_) => {
            let _ = respond(&mut stream, "400 Bad Request", "invalid torrent id", "").await;
            return;
        }
    };
    let file_index: u32 = match path_parts[2].parse() {
        Ok(v) => v,
        Err(_) => {
            let _ = respond(&mut stream, "400 Bad Request", "invalid file index", "").await;
            return;
        }
    };

    // Ensure pipeline exists
    if let Err(e) = ensure_prepared(torrent_id, file_index).await {
        let _ = respond(&mut stream, "500 Internal Server Error", &e.to_string(), "").await;
        return;
    }

    // Get file metadata
    let info = match torrent_engine::bridge::get_torrent_file_info(torrent_id, file_index).await {
        Ok(i) => i,
        Err(e) => {
            let _ = respond(&mut stream, "404 Not Found", &e.to_string(), "").await;
            return;
        }
    };

    // Parse Range header
    let range = parse_range_header(request, info.size);
    let (start, end) = match range {
        Ok(v) => v,
        Err(e) => {
            let _ = respond(&mut stream, "416 Range Not Satisfiable", &e, "").await;
            return;
        }
    };

    let content_length = end - start + 1;
    let content_type = guess_content_type(&info.path);

    // Open the librqbit file stream, seek, and pipe bytes
    let mut reader = match torrent_engine::bridge::open_stream(torrent_id, file_index).await {
        Ok(r) => r,
        Err(e) => {
            let _ = respond(&mut stream, "500 Internal Server Error", &e.to_string(), "").await;
            return;
        }
    };

    if let Err(e) = reader.seek(SeekFrom::Start(start)).await {
        let _ = respond(&mut stream, "500 Internal Server Error", &e.to_string(), "").await;
        return;
    }

    // Write 206 headers
    let status_line = "HTTP/1.1 206 Partial Content\r\n";
    let headers = format!(
        "{}Content-Type: {}\r\nAccept-Ranges: bytes\r\nContent-Range: bytes {}-{}/{}\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
        status_line, content_type, start, end, info.size, content_length
    );
    if stream.write_all(headers.as_bytes()).await.is_err() {
        return;
    }

    // Stream body in chunks
    let mut remaining = content_length;
    let mut current_offset = start;

    while remaining > 0 {
        let to_read = remaining.min(CHUNK_SIZE as u64) as usize;
        let mut chunk = vec![0u8; to_read];

        let mut read_attempts = 0;
        let max_zero_wait_attempts = 75; // 75 * 200ms = 15 seconds max wait per chunk

        loop {
            if reader.seek(SeekFrom::Start(current_offset)).await.is_err() {
                return;
            }

            match tokio::time::timeout(READ_TIMEOUT, reader.read_exact(&mut chunk)).await {
                Ok(Ok(_)) => {
                    // If chunk contains all zero bytes and torrent is still downloading,
                    // keep waiting for BitTorrent peers to download and write the piece to disk.
                    let is_all_zero = chunk.iter().all(|&b| b == 0);
                    if is_all_zero {
                        let status = torrent_engine::bridge::get_torrent_status(torrent_id).await;
                        let is_complete = status.as_ref().map_or(false, |s| s.progress >= 1.0);
                        let is_downloading = status.as_ref().map_or(false, |s| s.status == torrent_engine::TorrentStatus::Downloading);

                        if !is_complete && is_downloading {
                            read_attempts += 1;
                            tokio::time::sleep(Duration::from_millis(200)).await;
                            continue;
                        }
                    }

                    if stream.write_all(&chunk).await.is_err() {
                        return;
                    }

                    current_offset += to_read as u64;
                    remaining -= to_read as u64;
                    break;
                }
                _ => return,
            }
        }
    }
}

fn parse_request_line(request: &str) -> Option<(&str, &str)> {
    let first_line = request.lines().next()?;
    let mut parts = first_line.split_whitespace();
    let method = parts.next()?;
    let path = parts.next()?;
    Some((method, path))
}

fn parse_range_header(request: &str, file_size: u64) -> Result<(u64, u64), String> {
    for line in request.lines() {
        let line = line.trim();
        if line.to_lowercase().starts_with("range:") {
            let val = line[6..].trim();
            if let Some(bytes_str) = val.strip_prefix("bytes=") {
                let mut parts = bytes_str.split('-');
                let start: u64 = parts.next().unwrap_or("0").parse().map_err(|_| "bad start".to_string())?;
                let end: u64 = parts.next()
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(file_size.saturating_sub(1));
                if start >= file_size {
                    return Err("start past EOF".to_string());
                }
                return Ok((start, end.min(file_size.saturating_sub(1))));
            }
        }
    }
    // No Range header → return full file
    Ok((0, file_size.saturating_sub(1)))
}

async fn respond(stream: &mut TcpStream, status: &str, body: &str, extra_header: &str) -> std::io::Result<()> {
    let resp = format!(
        "HTTP/1.1 {}\r\nContent-Type: text/plain\r\nContent-Length: {}\r\n{}\r\n\r\n{}",
        status,
        body.len(),
        extra_header,
        body
    );
    let _ = stream.write_all(resp.as_bytes()).await;
    Ok(())
}

fn guess_content_type(path: &str) -> String {
    let path = path.to_lowercase();
    if path.ends_with(".mp4") || path.ends_with(".m4v") || path.ends_with(".mov") {
        "video/mp4".to_string()
    } else if path.ends_with(".mkv") {
        "video/x-matroska".to_string()
    } else if path.ends_with(".webm") {
        "video/webm".to_string()
    } else if path.ends_with(".avi") {
        "video/x-msvideo".to_string()
    } else if path.ends_with(".ts") || path.ends_with(".m2ts") {
        "video/mp2t".to_string()
    } else if path.ends_with(".flv") {
        "video/x-flv".to_string()
    } else {
        "video/mp4".to_string()
    }
}
