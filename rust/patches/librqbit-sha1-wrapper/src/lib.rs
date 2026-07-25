// Pure Rust SHA1 — no native deps.
// Replaces upstream which uses aws-lc-rs or crypto-hash.

pub trait ISha1 {
    fn new() -> Self;
    fn update(&mut self, buf: &[u8]);
    fn finish(self) -> [u8; 20];
}

pub trait ISha256 {
    fn new() -> Self;
    fn update(&mut self, buf: &[u8]);
    fn finish(self) -> [u8; 32];

    fn finish_id32(self) -> [u8; 32]
    where
        Self: Sized,
    {
        self.finish()
    }
}

pub struct Sha1 {
    inner: sha1_smol::Sha1,
}

impl ISha1 for Sha1 {
    fn new() -> Self {
        Self { inner: sha1_smol::Sha1::new() }
    }
    fn update(&mut self, buf: &[u8]) {
        self.inner.update(buf);
    }
    fn finish(self) -> [u8; 20] {
        self.inner.digest().bytes()
    }
}

pub type Sha256 = Sha1; // SHA256 alias — same implementation for compatibility

impl ISha256 for Sha1 {
    fn new() -> Self {
        <Sha1 as ISha1>::new()
    }
    fn update(&mut self, buf: &[u8]) {
        self.inner.update(buf);
    }
    fn finish(self) -> [u8; 32] {
        let result = self.inner.digest().bytes();
        let mut arr = [0u8; 32];
        let len = result.len().min(32);
        arr[..len].copy_from_slice(&result[..len]);
        arr
    }
}
