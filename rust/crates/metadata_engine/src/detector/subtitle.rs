//! Subtitle language and format detection.

use std::path::Path;
use once_cell::sync::Lazy;
use regex::Regex;
use crate::models::SubtitleTrack;

static LANG_CODE_REGEX: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"(?i)[\._\-\s]([a-z]{2,3})[\._\-\s]?(?:sdh|forced|default)?\.(srt|ass|ssa|vtt|pgs|sup)$").unwrap()
});

/// Parse subtitle details from external file path.
pub fn parse_external_subtitle(
    file_index: u32,
    path_str: &str,
    ext: &str,
) -> SubtitleTrack {
    let path = Path::new(path_str);
    let file_name = path
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or(path_str);
    let lower_name = file_name.to_lowercase();

    let language = if let Some(caps) = LANG_CODE_REGEX.captures(file_name) {
        caps.get(1).map_or("eng", |m| m.as_str()).to_lowercase()
    } else if lower_name.contains("english") || lower_name.contains(".eng.") {
        "eng".to_string()
    } else if lower_name.contains("spanish") || lower_name.contains(".spa.") || lower_name.contains(".es.") {
        "spa".to_string()
    } else if lower_name.contains("french") || lower_name.contains(".fre.") || lower_name.contains(".fra.") {
        "fre".to_string()
    } else if lower_name.contains("german") || lower_name.contains(".ger.") || lower_name.contains(".deu.") {
        "ger".to_string()
    } else if lower_name.contains("japanese") || lower_name.contains(".jpn.") || lower_name.contains(".jap.") {
        "jpn".to_string()
    } else {
        "unknown".to_string()
    };

    let is_forced = lower_name.contains("forced");
    let is_default = lower_name.contains("default");

    SubtitleTrack {
        index: file_index,
        language,
        title: file_name.to_string(),
        format: ext.to_uppercase(),
        is_external: true,
        is_forced,
        is_default,
        file_path: Some(path_str.to_string()),
    }
}
