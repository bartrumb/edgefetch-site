---
title: Install
description: Release binaries, go install, container images and the Home Assistant add-on.
---

## Release binaries

Each [GitHub release](https://github.com/bartrumb/edgefetch/releases/latest) ships static
`CGO_ENABLED=0` builds:

| OS | Architectures |
|---|---|
| Linux | `amd64`, `arm64`, `arm`, `mipsle` (OpenWrt routers) |
| macOS | `amd64`, `arm64` |
| Windows | `amd64`, `arm64` |
| FreeBSD | `amd64`, `arm64` |

Every release includes `checksums.txt`, an Ed25519 signature over it, and SLSA build
provenance. See [Verify a release](/guides/verify-release/).

## go install

Requires Go 1.26 or later. Note the `/v2` in the module path:

```bash
go install github.com/bartrumb/edgefetch/v2/cmd/edgefetch@latest
```

## Container images

Images are multi-arch (`linux/amd64`, `linux/arm64`), run as non-root `65532:65532`, and pull
without logging in.

| Image | What it is |
|---|---|
| `ghcr.io/bartrumb/edgefetch-agent:latest` | "Fat" worker: HTTP/2, headless Chromium, Poppler PDF |
| `ghcr.io/bartrumb/edgefetch-agent:lite` | Distroless worker, about 15 MB of RAM, pure-Go PDF |
| `ghcr.io/bartrumb/edgefetch:latest` | All-in-one hub + worker + SQLite FTS5 |

Pin a version tag such as `2.5.2` in production instead of `latest`.

## Home Assistant OS

Add the repository with the button in the
[README](https://github.com/bartrumb/edgefetch#readme), install **EdgeFetch**, then set
`hub_url`, `agent_token` and `site_id` and start the add-on. It supports `amd64` and `aarch64`.

## Check your setup

```bash
edgefetch doctor
```

`doctor` checks the SSRF guard, the loopback proxy used by the browser, browser detection and PDF
tools, and prints what it found.
