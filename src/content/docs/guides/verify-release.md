---
title: Verify a release
description: Check the Ed25519 checksum signature and the SLSA build provenance of an EdgeFetch release, or self-update with automatic verification.
---

Every release has three things you can check yourself:

1. `checksums.txt`, the SHA-256 of every archive
2. `checksums.txt.sig`, an Ed25519 signature over that file
3. A GitHub SLSA build-provenance attestation for each archive and container image

## Automatic verified self-update (`edgefetch update`)

From `v2.7.0` onwards, the Go binary includes a built-in self-updater that downloads `checksums.txt` and `checksums.txt.sig`, verifies the Ed25519 signature against the embedded release public key (`crypto/ed25519`), checks the archive's SHA-256 hash before extracting, and atomically replaces the binary:

```bash
edgefetch update --check   # check whether a newer release exists
edgefetch update           # verify Ed25519 + SHA-256 and upgrade in place
```

## Manual verification

### 1. Download

```bash
gh release download v2.7.1 --repo bartrumb/edgefetch \
  --pattern 'checksums.txt*' \
  --pattern 'edgefetch_2.7.1_linux_amd64.tar.gz'
```

### 2. Check the key and Ed25519 signature

Fetch [`keys/release-signing-pub.pem`](https://github.com/bartrumb/edgefetch/blob/main/keys/release-signing-pub.pem)
from the repository and verify its SPKI DER SHA-256 fingerprint (`2ed9e6f815d727738d51bc48c176f2b63d5176c92975f52943fefcf0afe03272`). Official releases deliberately omit the public key from release assets so verifiers never rely on a key downloaded from the same bundle.

```bash
openssl pkeyutl -verify -pubin -inkey keys/release-signing-pub.pem \
  -rawin -in checksums.txt -sigfile checksums.txt.sig
# Signature Verified Successfully
```

### 3. Check the archive hash

```bash
sha256sum --ignore-missing -c checksums.txt
```

### 4. Check GitHub SLSA provenance

```bash
gh attestation verify edgefetch_2.7.1_linux_amd64.tar.gz --repo bartrumb/edgefetch
```

This confirms the archive was built by the repository's GitHub Actions release workflow from the
immutable `v2.7.1` tag.

Container images carry SLSA attestations too:

```bash
gh attestation verify oci://ghcr.io/bartrumb/edgefetch-agent:2.7.1 --repo bartrumb/edgefetch
```
