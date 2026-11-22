---
title: Install
description: Release binaries, built-in self-updater, go install, container images and the Home Assistant add-on.
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

Once installed, upgrade in place at any time with Ed25519 + SHA-256 verification:

```bash
edgefetch update
```

## Homebrew (macOS & Linux)

Install from the official [`bartrumb/homebrew-tap`](https://github.com/bartrumb/homebrew-tap) (`arm64` and `amd64` on macOS and Linux, SHA-256 pinned to the signed GitHub release):

```bash
brew install bartrumb/tap/edgefetch
```

## go install

Requires Go 1.24 or later. Note the `/v2` in the module path:

```bash
go install github.com/bartrumb/edgefetch/v2/cmd/edgefetch@latest
```

## Official MCP Registry

EdgeFetch is published on the [Official MCP Registry](https://registry.modelcontextprotocol.io/v0/servers?search=edgefetch) as **`io.github.bartrumb/edgefetch`**.

## Container images

Images are multi-arch (`linux/amd64`, `linux/arm64`), run as non-root `65532:65532`, and pull
without logging in.

| Image | What it is |
|---|---|
| `ghcr.io/bartrumb/edgefetch-agent:2.7.0` | "Fat" worker: HTTP/2, headless Chromium, Poppler PDF |
| `ghcr.io/bartrumb/edgefetch-agent:2.7.0-lite` | Distroless worker, about 15 MB of RAM, pure-Go PDF |
| `ghcr.io/bartrumb/edgefetch:2.7.0` | All-in-one federated hub + worker + SQLite FTS5 |

Pin an explicit version tag such as `2.7.0` in production instead of `latest`.

## Home Assistant OS

Add the repository with the button in the
[README](https://github.com/bartrumb/edgefetch#readme), install **EdgeFetch**, then set
`hub_url`, `agent_token` and `site_id` and start the add-on. It supports `amd64` and `aarch64`.

## Check your setup

```bash
edgefetch doctor
```

`doctor` checks the dial-time SSRF guard, Direct Pipe CDP browser startup, and PDF tools, and prints what it found.
