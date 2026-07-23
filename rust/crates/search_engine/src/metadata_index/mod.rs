//! Metadata extraction indexer.

pub fn extract_search_tags(title: &str, file_name: &str) -> String {
    let combined = format!("{} {}", title, file_name).to_lowercase();
    let mut tags = Vec::new();
    if combined.contains("2160p") || combined.contains("4k") {
        tags.push("4k");
    }
    if combined.contains("1080p") {
        tags.push("1080p");
    }
    if combined.contains("hdr") {
        tags.push("hdr");
    }
    if combined.contains("hevc") || combined.contains("x265") {
        tags.push("hevc");
    }
    tags.join(" ")
}
