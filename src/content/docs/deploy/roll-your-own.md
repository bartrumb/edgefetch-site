---
title: Roll your own
description: Build on EdgeFetch your own way, with the CLI, the REST API, the SDKs, the compatibility routes, the WebAssembly extractor or the browser extension.
---

The hub and workers are one way to use EdgeFetch. Each piece also works on its own, so you can
fit it into whatever you already run.

## Just the CLI

No hub, no server, no ports. Good for scripts and cron jobs:

```bash
edgefetch scrape https://example.com
edgefetch scrape --json --query="installation" https://developers.cloudflare.com/workers/
edgefetch doctor
```

The same rules apply as everywhere else: robots.txt on every hop, dial-time IP checks, and a stop
at challenge pages.

## Local MCP over stdio

`edgefetch mcp` is a complete MCP server that your client starts as a child process. It uses
the Chrome, Edge or Brave you already have installed for JavaScript pages. See
[Connect an MCP client](/start/mcp-clients/).

## The REST API

Every hub exposes the same HTTP API, authenticated with `Authorization: Bearer $CALLER_TOKEN`:

| Endpoint | What it does |
|---|---|
| `POST /v1/scrape` | One URL to clean Markdown or JSON |
| `POST /v1/extract` | Several URLs, with query-ranked chunks |
| `POST /v1/map` | Discover a site's URLs from robots.txt, sitemaps, `llms.txt` and links |
| `POST /v1/crawl`, `GET` and `DELETE /v1/crawl/:id` | Start, poll or cancel a crawl, with signed webhooks |
| `POST /v1/search` | Web search through your own keys or SearXNG, plus your private collections |
| `POST /v1/jobs` | Search ATS job boards with normalised pay |
| `POST /v1/interact` | Drive a headless browser on a capable worker |
| `POST /fetch` | Low-level batch fetch, optionally pinned to one worker with `?site=` |
| `GET /v1/capabilities`, `GET /v1/hosts` | What this hub can do, and per-host health and pacing |

```bash
curl -sS https://<your-hub>/v1/scrape \
  -H "Authorization: Bearer $CALLER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://go.dev/doc/effective_go"}'
```

## SDKs

Two single-file clients live in the repository, with no dependencies beyond the standard
library:

- TypeScript: `sdk/ts/edgefetch-client.ts`
- Python: `sdk/py/edgefetch_client.py`

Both accept a list of hubs and fail over to the next one on network errors or `502`, `503` and
`504`:

```ts
import { EdgeFetchClient } from './sdk/ts/edgefetch-client';

const client = new EdgeFetchClient({
  baseUrls: ['https://edgefetch.example.com', 'https://standby.tailnet.ts.net'],
  token: process.env.CALLER_TOKEN!,
});
```

## Drop-in for Firecrawl and Tavily clients

If your code already uses the Firecrawl v2 or Tavily SDKs, point them at your hub instead:

- Firecrawl v2: `https://<your-hub>/v2/` or `https://<your-hub>/compat/firecrawl/v2/`
- Tavily: `https://<your-hub>/compat/tavily/`

## WebAssembly extractor

`cmd/edgefetch-wasm` builds the HTML-to-Markdown and JSON extractor for `wasip1/wasm`, with no
network access at all. Run it inside `wasmtime`, `wazero` or any Wasm sandbox when you already
have the HTML and only want the clean text.

```bash
make build-wasm
```

## Browser clipper

`extensions/browser-clipper/` is a Manifest V3 extension for Chrome and Firefox. It sends the page
in your active tab, including pages you're signed in to, to your hub's private full-text search
(`POST /v1/ingest-tab`). It only ever clips the tab you choose.

## Write your own worker or hub

The hub-to-worker WebSocket protocol is documented in
[docs/PROTOCOL.md](https://github.com/bartrumb/edgefetch/blob/main/docs/PROTOCOL.md): the hello
handshake, dispatch messages with per-job nonces, and gzip replies to `POST /agent/reply`. The Go
internals, including the dialer checks and per-host locks, are in
[docs/INTERNALS.md](https://github.com/bartrumb/edgefetch/blob/main/docs/INTERNALS.md).
