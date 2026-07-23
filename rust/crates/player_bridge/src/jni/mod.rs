//! Native JNI C-FFI exports for Android Media3 RustDataSource.

#![cfg(target_os = "android")]

use jni::JNIEnv;
use jni::objects::{JByteArray, JClass};
use jni::sys::{jboolean, jint, jlong};
use std::sync::atomic::Ordering;

use crate::datasource::{close_handle, get_handle, open_handle};

#[no_mangle]
pub unsafe extern "C" fn Java_com_example_tor_1stream_bridge_RustDataSource_nativeOpenStream(
    _env: JNIEnv,
    _class: JClass,
    torrent_id: jlong,
    file_index: jint,
    file_size: jlong,
) -> jlong {
    open_handle(torrent_id as u64, file_index as u32, file_size as u64)
}

#[no_mangle]
pub unsafe extern "C" fn Java_com_example_tor_1stream_bridge_RustDataSource_nativeReadBytes(
    #[allow(unused_mut)] mut env: JNIEnv,
    _class: JClass,
    handle_id: jlong,
    target_buffer: JByteArray,
    offset: jint,
    length: jint,
) -> jint {
    let handle = match get_handle(handle_id) {
        Some(h) => h,
        None => return -1,
    };

    let buffer_len = match env.get_array_length(&target_buffer) {
        Ok(l) => l as usize,
        Err(_) => return -1,
    };

    if (offset as usize) + (length as usize) > buffer_len {
        return -1;
    }

    let mut temp_buf = vec![0u8; length as usize];
    let runtime = match tokio::runtime::Builder::new_current_thread().enable_all().build() {
        Ok(r) => r,
        Err(_) => return -1,
    };

    let read_res = runtime.block_on(crate::reader::read_into_buffer(&handle, &mut temp_buf));
    match read_res {
        Ok(bytes_read) => {
            if bytes_read == 0 {
                return -1; // EOF for ExoPlayer
            }

            let slice = &temp_buf[..bytes_read];
            let i8_slice: &[i8] = std::slice::from_raw_parts(slice.as_ptr() as *const i8, bytes_read);

            if env.set_byte_array_region(&target_buffer, offset, i8_slice).is_ok() {
                bytes_read as jint
            } else {
                -1
            }
        }
        Err(_) => -1,
    }
}

#[no_mangle]
pub unsafe extern "C" fn Java_com_example_tor_1stream_bridge_RustDataSource_nativeSeek(
    _env: JNIEnv,
    _class: JClass,
    handle_id: jlong,
    position: jlong,
) -> jboolean {
    if let Some(handle) = get_handle(handle_id) {
        handle.current_offset.store(position as u64, Ordering::Relaxed);
        1 // true
    } else {
        0 // false
    }
}

#[no_mangle]
pub unsafe extern "C" fn Java_com_example_tor_1stream_bridge_RustDataSource_nativeCloseStream(
    _env: JNIEnv,
    _class: JClass,
    handle_id: jlong,
) {
    close_handle(handle_id);
}
