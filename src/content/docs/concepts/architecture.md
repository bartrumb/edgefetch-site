---
title: Architecture
description: How the EdgeFetch hub, worker nodes and MCP clients fit together.
---

EdgeFetch has two parts: a **hub** that your agents talk to, and **workers** that fetch pages.

```
 Claude Code / Cursor ──(MCP: OAuth 2.1 or bearer)──▶ Hub ◀──(WSS, outbound)── Worker (home, arm64)
 Browser (/admin) ─────(HMAC session + CSRF)───────▶  │  ◀──(WSS, outbound)── Worker (Home Assistant)
                                                      │  ◀──(WSS, outbound)── Worker (VPS / Docker)
                                                      └──(OTLP, optional)──▶ Your trace collector
```

## The hub

- Serves `/mcp`, the HTTP API (including Firecrawl-compatible `/v2/*` routes) and the `/admin`
  console.
- Keeps per-host pacing and cooldowns, a result cache, and full-text search over collected pages.
- Runs on Cloudflare Workers (Durable Objects + D1 + R2), as a single Node container with SQLite,
  or as the Go binary in `--mode=hub`.

## Workers

- A static Go binary with one external dependency.
- Connect **out** to the hub, so they need no open ports or VPN.
- Fetch over HTTP/2. When a page needs JavaScript, they render it in a sandboxed headless
  Chromium (the fat image), or in your installed browser on the desktop.
- Convert HTML, PDFs and feeds to clean Markdown or structured JSON before sending anything back.

## A request, end to end

1. Your agent calls a tool such as `scrape` with a URL.
2. The hub checks its cache, `robots.txt` and that host's pacing, then sends the job to a worker.
3. The worker resolves the host, checks at dial time that the IP is public, fetches the page and
   follows redirects one hop at a time, re-checking the rules on each hop.
4. If a site-specific adapter applies (for example a job board's public API), the worker or hub
   uses it instead of scraping the HTML.
5. The worker returns Markdown or JSON, plus metadata such as status, timings, and whether the
   page was blocked.

## Adapters

More than 49 keyless adapters turn known sites into structured data: ATS job boards
(Greenhouse, Lever, Ashby, Workday and others), open-data portals, research APIs (arXiv,
Crossref, OpenAlex, PubMed) and developer sites (GitHub, npm, crates.io, Stack Overflow). You can
add one in a single file; see
[docs/ADAPTERS.md](https://github.com/bartrumb/edgefetch/blob/main/docs/ADAPTERS.md).

For the wire protocol between hub and workers, see
[docs/PROTOCOL.md](https://github.com/bartrumb/edgefetch/blob/main/docs/PROTOCOL.md).
