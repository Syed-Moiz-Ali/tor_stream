use rusqlite::params;
use tracing::info;

use crate::error::Result;
use crate::index_engine;
use crate::models::{SearchField, SearchFilters, SearchResult, SortField, SortOrder, SortOptions};

pub struct SearchEngine;

impl SearchEngine {
    pub fn search(
        query: &str,
        filters: Option<&SearchFilters>,
        _sort: Option<&SortOptions>,
        limit: usize,
        offset: usize,
    ) -> Result<Vec<SearchResult>> {
        let conn = index_engine::get_connection().lock().unwrap();
        let clean = query.trim().to_lowercase();
        let like_pattern = format!("%{}%", clean.replace('%', "\\%").replace('_', "\\_"));

        let mut sql = String::from(
            "SELECT DISTINCT si.torrent_id, si.content, si.field
             FROM search_index si WHERE si.content LIKE ?1 ESCAPE '\\'",
        );
        let mut filter_params: Vec<Box<dyn rusqlite::types::ToSql>> = vec![Box::new(&like_pattern)];

        if let Some(f) = filters {
            if !f.categories.is_empty() {
                let cats: Vec<String> = f.categories.iter().map(|c| format!("{:?}", c)).collect();
                let placeholders: Vec<String> = (0..cats.len()).map(|i| format!("?{}", i + 2)).collect();
                sql.push_str(&format!(
                    " AND si.torrent_id IN (SELECT torrent_id FROM search_index WHERE field='category' AND content IN ({}))",
                    placeholders.join(",")
                ));
                for cat in cats {
                    filter_params.push(Box::new(cat));
                }
            }
            if !f.status.is_empty() {
                let placeholders: Vec<String> = (filter_params.len() + 1..)
                    .take(f.status.len())
                    .map(|i| format!("?{}", i))
                    .collect();
                sql.push_str(&format!(
                    " AND si.torrent_id IN (SELECT torrent_id FROM search_index WHERE field='status' AND content IN ({}))",
                    placeholders.join(",")
                ));
                for s in &f.status {
                    filter_params.push(Box::new(s.clone()));
                }
            }
            if let Some(ref codec) = f.codec {
                let idx = filter_params.len() + 1;
                sql.push_str(&format!(
                    " AND si.torrent_id IN (SELECT torrent_id FROM search_index WHERE field='codec' AND content LIKE ?{})",
                    idx
                ));
                filter_params.push(Box::new(format!("%{}%", codec)));
            }
            if let Some(ref res) = f.resolution {
                let idx = filter_params.len() + 1;
                sql.push_str(&format!(
                    " AND si.torrent_id IN (SELECT torrent_id FROM search_index WHERE field='resolution' AND content LIKE ?{})",
                    idx
                ));
                filter_params.push(Box::new(format!("%{}%", res)));
            }
        }

        sql.push_str(" ORDER BY si.torrent_id ASC");

        let mut stmt = conn.prepare(&sql)?;
        let param_refs: Vec<&dyn rusqlite::types::ToSql> = filter_params.iter().map(|p| p.as_ref()).collect();
        let rows = stmt.query_map(param_refs.as_slice(), |r| {
            let torrent_id: u64 = r.get(0)?;
            let content: String = r.get(1)?;
            let field: String = r.get(2)?;
            Ok((torrent_id, content, field))
        })?;

        let mut grouped: std::collections::HashMap<u64, (String, Vec<String>)> =
            std::collections::HashMap::new();
        for row in rows {
            let (tid, content, field) = row?;
            let entry = grouped.entry(tid).or_default();
            if field == "title" || field == "torrent_name" {
                entry.0 = content;
            }
            entry.1.push(field);
        }

        let mut results: Vec<SearchResult> = grouped
            .into_iter()
            .map(|(tid, (title, fields))| {
                let matched_on = if fields.contains(&"title".to_string()) || fields.contains(&"torrent_name".to_string()) {
                    if clean.len() > 2 { "title" } else { "partial" }
                } else if fields.iter().any(|f| f.contains("file_")) {
                    "filename"
                } else if fields.contains(&"folder_name".to_string()) {
                    "folder"
                } else if fields.contains(&"subtitle_lang".to_string()) || fields.contains(&"subtitle_file".to_string()) {
                    "subtitle"
                } else if fields.contains(&"audio_lang".to_string()) || fields.contains(&"audio_codec".to_string()) {
                    "audio"
                } else {
                    "metadata"
                };

                SearchResult {
                    torrent_id: tid,
                    title,
                    category: String::new(),
                    primary_file_index: 0,
                    total_bytes: 0,
                    artwork_path: None,
                    relevance_score: 1.0,
                    matched_on: matched_on.to_string(),
                }
            })
            .collect();

        if let Some(s) = _sort {
            match s.field {
                SortField::Name | SortField::Alphabetical => {
                    results.sort_by(|a, b| a.title.to_lowercase().cmp(&b.title.to_lowercase()));
                }
                SortField::DateAdded | SortField::LastPlayed => {
                    results.sort_by(|a, b| b.torrent_id.cmp(&a.torrent_id));
                }
                _ => {}
            }
            if matches!(s.order, SortOrder::Descending) {
                results.reverse();
            }
        }

        let total = results.len();
        let paginated = results.into_iter().skip(offset).take(limit).collect();

        info!(query = %clean, total, "Search completed");
        Ok(paginated)
    }

    pub fn search_field(query: &str, field: SearchField, limit: usize) -> Result<Vec<SearchResult>> {
        let conn = index_engine::get_connection().lock().unwrap();
        let field_prefix = match field {
            SearchField::Title => "title",
            SearchField::TorrentName => "torrent_name",
            SearchField::Filename => "file_",
            SearchField::FolderName => "folder_name",
            SearchField::SubtitleName => "subtitle_",
            SearchField::AudioLanguage => "audio_lang",
            SearchField::Resolution => "resolution",
            SearchField::Codec => "codec",
            SearchField::Year => "year",
            SearchField::Tags => "tags",
            SearchField::Duration => "duration",
            SearchField::All => "",
        };

        let like = format!("%{}%", query.replace('%', "\\%").replace('_', "\\_"));

        if field_prefix.is_empty() {
            let mut stmt = conn.prepare(
                "SELECT DISTINCT torrent_id, ?2 FROM search_index WHERE content LIKE ?1 ESCAPE '\\' LIMIT ?3",
            )?;
            let rows = stmt.query_map(params![like, "", limit as i64], |r| {
                Ok(SearchResult {
                    torrent_id: r.get(0)?,
                    title: String::new(),
                    category: String::new(),
                    primary_file_index: 0,
                    total_bytes: 0,
                    artwork_path: None,
                    relevance_score: 1.0,
                    matched_on: format!("{:?}", field),
                })
            })?;
            rows.collect::<std::result::Result<Vec<_>, _>>()
                .map_err(|e| crate::error::SearchEngineError::Search(e.to_string()))
        } else {
            let field_pattern = format!("{}%", field_prefix);
            let mut stmt = conn.prepare(
                "SELECT DISTINCT torrent_id, ?2 FROM search_index WHERE field LIKE ?4 AND content LIKE ?1 ESCAPE '\\' LIMIT ?3",
            )?;
            let rows = stmt.query_map(params![like, "", limit as i64, field_pattern], |r| {
                Ok(SearchResult {
                    torrent_id: r.get(0)?,
                    title: String::new(),
                    category: String::new(),
                    primary_file_index: 0,
                    total_bytes: 0,
                    artwork_path: None,
                    relevance_score: 1.0,
                    matched_on: format!("{:?}", field),
                })
            })?;
            rows.collect::<std::result::Result<Vec<_>, _>>()
                .map_err(|e| crate::error::SearchEngineError::Search(e.to_string()))
        }
    }

    pub fn get_recently_added(limit: usize) -> Result<Vec<SearchResult>> {
        let conn = index_engine::get_connection().lock().unwrap();
        let mut stmt = conn.prepare(
            "SELECT DISTINCT torrent_id, ?2 FROM search_index WHERE field='category' ORDER BY torrent_id DESC LIMIT ?1",
        )?;
        let rows = stmt.query_map(params![limit as i64, ""], |r| {
            Ok(SearchResult {
                torrent_id: r.get(0)?,
                title: String::new(),
                category: String::new(),
                primary_file_index: 0,
                total_bytes: 0,
                artwork_path: None,
                relevance_score: 1.0,
                matched_on: "recently_added".to_string(),
            })
        })?;
        rows.collect::<std::result::Result<Vec<_>, _>>()
            .map_err(|e| crate::error::SearchEngineError::Search(e.to_string()))
    }
}
