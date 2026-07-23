//! Artwork tracking & manager module.

use crate::models::Artwork;

/// Helper manager for collecting artwork files.
#[derive(Debug, Clone, Default)]
pub struct ArtworkManager {
    artworks: Vec<Artwork>,
}

impl ArtworkManager {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn add(&mut self, artwork: Artwork) {
        self.artworks.push(artwork);
    }

    pub fn artworks(&self) -> &[Artwork] {
        &self.artworks
    }

    pub fn into_artworks(self) -> Vec<Artwork> {
        self.artworks
    }
}
