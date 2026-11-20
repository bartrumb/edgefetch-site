---
title: Verify a release
description: Check the Ed25519 checksum signature and the SLSA build provenance of an EdgeFetch release.
---

Every release from v2.5.2 onwards has three things you can check yourself:

1. `checksums.txt`, the SHA-256 of every archive
2. `checksums.txt.sig`, an Ed25519 signature over that file
3. A GitHub SLSA build-provenance attestation for each archive and image

## 1. Download

```bash
gh release download v2.5.3 --repo bartrumb/edgefetch \
  --pattern 'checksums.txt*' --pattern 'release-signing-pub.pem' \
  --pattern 'edgefetch_2.5.3_linux_amd64.tar.gz'
```

## 2. Check the signature

```bash
openssl pkeyutl -verify -pubin -inkey release-signing-pub.pem \
  -rawin -in checksums.txt -sigfile checksums.txt.sig
# Signature Verified Successfully
```

Compare `release-signing-pub.pem` with
[`keys/release-signing-pub.pem`](https://github.com/bartrumb/edgefetch/blob/main/keys/release-signing-pub.pem)
in the repository. Don't trust a key that only came with the download.

## 3. Check the archive hash

```bash
sha256sum --ignore-missing -c checksums.txt
```

## 4. Check the provenance

```bash
gh attestation verify edgefetch_2.5.3_linux_amd64.tar.gz --repo bartrumb/edgefetch
```

This confirms the archive was built by the repository's GitHub Actions release workflow from the
tagged commit.

Container images have attestations too:

```bash
gh attestation verify oci://ghcr.io/bartrumb/edgefetch-agent:2.5.3 --repo bartrumb/edgefetch
```
