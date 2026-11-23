---
title: Architecture
description: How the Federated EdgeFetch Hub, encrypted MCP connectors, worker nodes and MCP clients fit together.
---

EdgeFetch has two parts: a **federated hub** that your agents talk to, and **workers** that fetch pages.

```
 Claude Code / Cursor ──(MCP: OAuth 2.1 or bearer)──▶ Hub ◀──(WSS, outbound)── Worker (home, arm64)
 Browser (/admin) ─────(GitHub OAuth / token + CSRF)▶  │  ◀──(WSS, outbound)── Worker (Home Assistant)
                                                       ├──(AES-256-GCM vault)▶ Connected MCP servers
                                                       └──(OTLP, optional)───▶ Your trace collector
```

## The hub

- Serves `/mcp` (17 tools), the OpenAPI 3.1 REST API (including Firecrawl-compatible `/v2/*` routes), and the `/admin` Control Center.
- Supports multi-user **Sign in with GitHub** (`SIGNUP_MODE=invite_only` default + `@org` allowlists) alongside `CALLER_TOKEN`, isolating OAuth grants, `/v1/interact` sessions, `/v1/agent` runs, FTS5 collections, and `private/<userId>/...` R2 caches per user.
- Includes an in-admin **MCP Registry & Encrypted Connectors** vault (`HKDF-SHA256` + `AES-256-GCM` with origin-bound AAD) to search the Official MCP Registry & Glama and connect downstream MCP servers via OAuth 2.1 PKCE or write-only secret headers.
- Keeps per-host pacing and cooldowns, a result cache, and full-text search over collected pages.
- Runs on Cloudflare Workers (Durable Objects + D1 + R2), on Deno Deploy or Node (`hub/portable/`), as a single all-in-one container with SQLite, or as the Go binary in `--mode=hub`.

## Workers

- A static Go binary with strictly one external dependency (`github.com/coder/websocket`).
- Connect **out** to the hub over TLS WebSockets, so they need no open ports or VPN.
- Fetch over HTTP/2. When a page needs JavaScript, they render it in a sandboxed headless Chromium over Direct Pipe CDP (zero listening TCP ports on Linux, macOS, and Windows).
- Convert HTML, PDFs and feeds to clean Markdown or structured JSON before sending anything back.

## A request, end to end

1. Your agent calls a tool such as `scrape` with a URL.
2. **Tier 1a — Connected MCP server:** If the caller has an enabled MCP connector matching that domain in their vault (and opts into MCP routing), the hub queries the MCP server directly over Streamable HTTP/SSE and marks the result `visibility: "private"`.
3. **Tier 1b — Declarative YAML adapter & outbound workers:** Otherwise, the hub checks its cache, `robots.txt` and per-host pacing, upgrades matching URLs via the 56 declarative YAML adapters (`compiled.json`), and dispatches the fetch to a healthy home worker node.
4. The worker resolves the host, checks inside the dialer right before `connect()` that the IP is public, fetches the page and follows redirects one hop at a time, re-checking `robots.txt` and IP safety on each hop.
5. **Tier 2 — Polite Cloudflare overflow:** Only if no worker is connected (or workers hit `429`), the Cloudflare Hub falls back to direct polite fetch while still enforcing `robots.txt` and `Content-Signal`.

## Adapters

56 MIT-licensed declarative YAML manifests (`internal/extract/manifests/*.yaml`) turn known sites into structured data without executable plugin code: ATS job boards (Greenhouse, Lever, Ashby, Workday and others), open-data portals, research APIs (arXiv, Crossref, OpenAlex, PubMed), storefronts (Shopify, WooCommerce) and developer registries (npm, PyPI, crates.io, RubyGems, Stack Exchange). See [Write an adapter](/adapters/write/).

For the wire protocol between hub and workers, see
[docs/PROTOCOL.md](https://github.com/bartrumb/edgefetch/blob/main/docs/PROTOCOL.md).
