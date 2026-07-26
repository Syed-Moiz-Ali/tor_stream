# CORRECTION ADDENDUM: Pure-Rust Torrent Engine (No C++, No libtorrent-rasterbar)

This overrides Part A.1-A.4 and Chunks 1.1-1.4 from the original build-plan doc.
Everything else (Rust workspace layout, HTTP streaming API contract, SQLite→Hive
addendum, Flutter/Riverpod UI, later chunks) stays as previously specced — the ONLY
change is removing the C++/cxx/libtorrent-rasterbar layer entirely and doing the
bittorrent protocol itself in pure Rust.

**Why this is worth doing, not just "possible":** cutting C++ out entirely removes
an entire class of build/link/packaging pain (per-platform CMake builds, vcpkg,
ABI mismatches across Android NDK versions, cross-compiling C++ for iOS) that was
previously the single riskiest part of the whole project. It also removes `unsafe`
FFI surface area almost completely — FFmpeg is still invoked, but as a subprocess
(shelling out to the `ffmpeg` binary), not linked C++.

---

## E.1 Engine choice

Use **`librqbit`** (the library behind the `rqbit` torrent client/server) as the
core bittorrent engine crate. It's the most actively maintained pure-Rust
bittorrent implementation, and notably it's _already built around the
"HTTP-streamable torrent server" use case_ — rqbit itself ships an HTTP interface
for streaming torrent content, which is architecturally close to what this project
needs, so you're not fighting the library's design assumptions.

```toml
# core/engine/Cargo.toml
[dependencies]
librqbit = "*"  # pin to the latest stable release at implementation time —
                 # check docs.rs/librqbit and the crate's CHANGELOG before
                 # implementation; this crate evolves quickly, don't assume
                 # exact method names below are final without verifying against
                 # current docs.
```

**Instruction to Claude Code:** before implementing Chunk 1 (below), fetch and read
the current `librqbit` docs on docs.rs and its example code in the upstream repo
(`ikatson/rqbit` on GitHub) to confirm exact API names for session creation, adding
a magnet/torrent, per-file priority, and reading piece data — the sketch below is
the architecture, not a literal API transcript. Do not guess at method signatures;
verify them against the actual crate version being pinned.

Fallback options if `librqbit` turns out to be missing a needed capability
(document whichever you end up needing in `/docs/architecture.md`):

- `cratetorrent` — older, less maintained, but simpler codebase if you need to
  fork/patch something librqbit doesn't expose.
- Writing the piece-selection/streaming layer yourself on top of a lower-level
  pure-Rust peer-wire-protocol crate — last resort, significant extra scope.

---

## E.2 Revised process/crate layout (replaces old A.1/A.2)

```
/core
  Cargo.toml
  /engine
    src/session.rs      # wraps librqbit::Session, no unsafe/FFI needed here at all
    src/scheduler.rs     # same piece-priority-window algorithm as before (Part A.4),
                          # now driving librqbit's own priority/piece-selection API
                          # instead of the old C API shim
    src/types.rs         # same TorrentId/FileEntry/PiecePriority/StreamCursor types
                          # as before — these don't change
  /server                # unchanged from before (axum, range requests, cursor API)
  /db  or  (Hive per addendum — Rust side has no persistence, per that addendum)
  /metadata               # unchanged (TMDB, filename parsing)
  /daemon                 # unchanged binary crate wiring engine+server together

  # REMOVED entirely: /native/libtorrent-bridge, any cxx bridge module,
  # ffi_bridge.rs, CMake build steps, vcpkg/apt libtorrent install instructions.
```

FFmpeg remains the only place anything gets "shelled out to" rather than pure
Rust — invoke the `ffmpeg` CLI binary as a subprocess (`tokio::process::Command`)
for remux/transcode, same as originally planned. This is a process boundary, not a
linked C++ dependency, so it doesn't reintroduce the build-complexity problem.

---

## E.3 Revised session wrapper (replaces the cxx-based TorrentSession)

```rust
// core/engine/src/session.rs — architecture sketch, verify exact librqbit
// calls against current docs before implementing

pub struct TorrentSession {
    inner: librqbit::Session,           // or Arc<librqbit::Session> if the crate
                                          // requires shared ownership across tasks
}

impl TorrentSession {
    pub async fn new(config: SessionConfig) -> anyhow::Result<Self> { ... }

    pub async fn add_magnet(&self, uri: &str) -> anyhow::Result<TorrentHandleWrapper> {
        // delegate to librqbit's add-torrent-by-magnet call
    }

    pub async fn file_list(&self, handle: &TorrentHandleWrapper) -> Vec<FileEntry> {
        // map librqbit's file metadata into this project's FileEntry type
        // (Part A.3 — unchanged)
    }

    pub async fn set_piece_priorities(&self, handle: &TorrentHandleWrapper,
                                        priorities: &[(u32, PiecePriority)]) {
        // drive librqbit's own priority/selection mechanism per piece —
        // this is where scheduler.rs's algorithm output gets applied;
        // the ALGORITHM in Part A.4 is unchanged, only the call target is
    }

    pub async fn read_piece(&self, handle: &TorrentHandleWrapper, piece: u32,
                              timeout: Duration) -> anyhow::Result<Bytes> {
        // block (with timeout) until librqbit has this piece, then return bytes —
        // same semantics as the old lt_read_piece FFI call, now pure async Rust
    }
}
```

The **scheduler algorithm itself (Part A.4 — sliding window, urgent/high/normal/
skip priorities, backward-seek/forward-seek/multi-cursor edge cases) does not
change at all.** Only the thing it's calling into changes, from an unsafe FFI call
into a safe async Rust method on `librqbit::Session`.

---

## E.4 Revised Chunk 1 (replaces old Chunks 1.1-1.4)

### Chunk 1.1′ — Pure-Rust engine wrapper

```
Add librqbit as a dependency to core/engine. Before writing any code, fetch
librqbit's current docs.rs page and its GitHub examples directory to confirm the
real API for: creating a session, adding a torrent from a magnet URI, listing
files in a torrent, setting per-piece or per-file priority, and reading a
specific piece's bytes once available (with a timeout). Then implement
core/engine/src/session.rs's TorrentSession wrapper (per E.3's sketch, adjusted
to the real API) using the same public types from Part A.3 (TorrentId, FileEntry,
PiecePriority, StreamCursor) so nothing downstream (scheduler, server) needs to
change.

Deliverable: an integration test that adds a known-legal test magnet (e.g. Big
Buck Bunny's official Creative Commons torrent), retrieves its file list, and
confirms metadata resolves correctly over pure-Rust DHT/peer discovery — no C++,
no cxx, no CMake anywhere in the build.
```

### Chunk 1.2′ — Piece scheduler (unchanged algorithm, new call target)

```
Implement core/engine/src/scheduler.rs exactly per Part A.4's algorithm, calling
TorrentSession::set_piece_priorities from Chunk 1.1′ instead of the old FFI call.
Same unit tests as originally specced (backward seek, forward seek past frontier,
multi-cursor), using a mocked TorrentSession trait so these tests still don't
need real network/torrent activity.
```

### Chunk 1.3′ — CLI + manual verification

```
Same as original Chunk 1.4: engine-cli with add/stream subcommands, manually
verify sequential streaming produces a playable partial file in VLC. No changes
needed to this chunk's goal, only that it's now exercising the pure-Rust path.
```

_(Old "Chunk 1.1 — C++ shim" and its CMake/vcpkg/apt install instructions are
deleted outright — there is nothing to build or link in C++ anymore.)_

Everything from Chunk 2 onward (HTTP streaming server, Flutter bridge, Hive
persistence, licensing, etc.) is unaffected by this change and stays exactly as
previously specced in the other three docs.

---

## E.5 What to tell Claude Code

```
The torrent engine is pure Rust using the librqbit crate — there is no C++ code,
no cxx bridge, no libtorrent-rasterbar, no CMake, no vcpkg anywhere in this
project. If you find yourself about to write a C++ file, a build.rs invoking
cmake, or a cxx::bridge module for the torrent engine specifically, stop — that
means you're working from the outdated pre-correction version of the plan.
FFmpeg is still used, but only as a subprocess (tokio::process::Command), never
linked. Before implementing any librqbit call, check its current docs.rs page —
don't assume method names from memory, the API surface here is from a fast-moving
crate and may have shifted since this document was written.
```
