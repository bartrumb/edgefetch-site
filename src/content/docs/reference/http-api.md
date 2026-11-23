---
title: REST API & OpenAPI 3.1
description: Full HTTP endpoint reference, curl examples, and OpenAPI 3.1.0 specification for EdgeFetch Hub.
---

Every EdgeFetch Hub exposes a stateless JSON REST API alongside its Streamable HTTP [MCP server](/reference/tools/) (`POST /mcp`). Both surfaces share the exact same canonical JSON Schema 2020-12 definitions so tool and REST parameters never drift.

## OpenAPI 3.1.0 specification

- **Canonical specification:** [`https://edgefetch.dev/openapi.json`](https://edgefetch.dev/openapi.json)
- **Live Hub specification:** `https://<your-hub>/openapi.json` (served with `Access-Control-Allow-Origin: *` and `X-Content-Type-Options: nosniff` on Cloudflare Workers, Docker/Node Portable Hub, Deno, and `edgefetch --mode=hub`)

```bash
curl -sS https://edgefetch.dev/openapi.json | jq '{openapi, version: .info.version, paths: (.paths | length)}'
```

## Authentication

Protected `/v1/*`, `/v2/*`, `/fetch`, `/agents`, and `/mcp` endpoints accept either a Bearer token or a self-hosted OAuth 2.1 access token:

1. **Bearer / API Token (`bearerAuth`):** Pass `Authorization: Bearer <token>` (or `X-API-Key: <token>`) using your Hub `CALLER_TOKEN` or scoped `MCP_TOKEN`.
2. **OAuth 2.1 + PKCE & GitHub Sign-In (`oauth2Pkce`):** Self-hosted Authorization Code flow with mandatory `S256` PKCE, RFC 7591 Dynamic Client Registration, and optional multi-user **Sign in with GitHub** (`GET /auth/github/login`, `SIGNUP_MODE=invite_only` default):
   - Protected Resource Metadata (RFC 9728): `GET /.well-known/oauth-protected-resource`
   - Authorization Server Metadata (RFC 8414): `GET /.well-known/oauth-authorization-server`
   - Scopes: `crawl:read` (capabilities, extractors, MCP registry search, host telemetry, stored artifacts, search) and `crawl:fetch` (outbound scraping, crawling, mapping, browser interaction, jobs, catalog, federated `query_mcp`, and autonomous agent runs).

## Endpoint reference

### Discovery & system

| Method & Path | Auth / Scope | Description |
|---|---|---|
| `GET /health` | Public | Liveness check (`{ "ok": true }`) |
| `GET /openapi.json` | Public | OpenAPI `3.1.0` JSON specification (CORS-enabled) |
| `GET /.well-known/edgefetch-bot.json` | Public | Bot transparency manifest (`robots.txt` & `Content-Signal` policy) |
| `GET /.well-known/http-message-signatures-directory` | Public | RFC 9421 Web Bot Auth Ed25519 JWKS directory |
| `GET /.well-known/oauth-protected-resource` | Public | RFC 9728 OAuth 2.1 Protected Resource metadata |
| `GET /.well-known/oauth-authorization-server` | Public | RFC 8414 OAuth 2.1 Authorization Server metadata |
| `GET /auth/github/login` | Public (interactive) | Start GitHub OAuth 2.1 PKCE login for `/admin` or `/oauth/authorize` |
| `GET /auth/github/callback` | Public (interactive) | Complete GitHub OAuth callback (`SIGNUP_MODE=invite_only` / `@org` gated) |
| `GET /v1/capabilities` | `crawl:read` | Configured R2, D1, FTS5, SERP, OCR, MCP vault, and BYO-LLM bindings |
| `GET /v1/extractors` | `crawl:read` | List all 56 built-in declarative YAML site & API adapters (`?category=...`) |
| `GET /v1/mcp/registry` | `crawl:read` | Search Official MCP Registry + Glama (`?q=...&source=all&limit=20`) |
| `GET /v1/hosts` | `crawl:read` | Per-host EWMA TTFB, polite pause windows, and `429` health |
| `GET /v1/artifacts/{blobSha256}` | `crawl:read` | Stream or page stored R2 raw/Markdown artifacts (`?offset=&limit=`) |
| `GET /agents` | `CALLER_TOKEN` | Connected outbound Go worker nodes (capabilities, sandbox posture, arch, counters) |

### Core `/v1/*` & coordinator endpoints

| Method & Path | Scope | Description |
|---|---|---|
| `POST /v1/scrape` | `crawl:fetch` | Scrape one `https://` URL to clean Markdown, JSON, PDF text/OCR, or metadata |
| `POST /v1/batch/scrape` | `crawl:fetch` | Scrape 1..100 URLs politely (`sync: true` or async batch ID) |
| `GET /v1/batch/scrape/{batchId}` | `crawl:read` | Poll batch scrape progress and results |
| `DELETE /v1/batch/scrape/{batchId}` | `crawl:fetch` | Cancel a running batch scrape job |
| `POST /v1/extract` | `crawl:fetch` | Extract BM25 query-ranked passages across 1..20 URLs |
| `POST /v1/interact` | `crawl:fetch` | Drive a sandboxed Headless Chromium session (`click`, `fill`, `scroll`, `screenshot`) |
| `POST /v1/map` | `crawl:fetch` | Rapidly list a domain's URLs from sitemaps, `/llms.txt`, and links |
| `POST /v1/crawl/params-preview` | `crawl:read` | Convert natural-language crawl goals into `includePaths` / `excludePaths` |
| `POST /v1/crawl` | `crawl:fetch` | Start an async (or `sync: true`) breadth-first site crawl with optional webhooks |
| `GET /v1/crawl/{crawlId}` | `crawl:read` | Poll crawl status and paged documents |
| `DELETE /v1/crawl/{crawlId}` | `crawl:fetch` | Cancel an active crawl job |
| `POST /v1/search` | `crawl:read` | Hybrid web search waterfall (D1 FTS5 + `site:` edge-map + Serper/SearXNG/Tavily/Brave) |
| `GET /v1/collections/{collectionId}/search` | `crawl:read` | Query an indexed D1 FTS5 collection (`?q=...&limit=10`) |
| `POST /v1/collections/{collectionId}/search` | `crawl:read` | Query an indexed D1 FTS5 collection via JSON body |
| `POST /v1/ingest-tab` | `crawl:fetch` | Clip and index a user browser tab into D1 FTS5 |
| `POST /v1/jobs` | `crawl:fetch` | Search 16+ ATS boards with normalized base pay, or `verify` saved job URLs |
| `POST /v1/catalog` | `crawl:fetch` | Polite sequential Shopify & WooCommerce catalog extraction and variant diffing |
| `GET /v1/catalog/{catalogId}` | `crawl:read` | Poll catalog run metadata and snapshot diff summary |
| `GET /v1/catalog/{catalogId}/records` | `crawl:read` | Page & filter catalog products (`vendor`, `productType`, `availableOnly`, `query`) |
| `POST /v1/agent` | `crawl:fetch` | Multi-step research & schema-validated JSON extraction with BYO-LLM or Ollama |
| `GET /v1/agent/{agentId}` | `crawl:read` | Poll async autonomous agent run status and output |
| `DELETE /v1/agent/{agentId}` | `crawl:fetch` | Cancel a running autonomous agent task |
| `GET /v1/agent/{agentId}/trace` | `crawl:read` | Fetch ordered execution trace spans for an agent run |
| `POST /v1/mcp/query` | `crawl:fetch` | List or call tools on a downstream MCP server connected in the caller's `/admin` vault |
| `POST /fetch` | `CALLER_TOKEN` | Low-level multi-URL coordinator dispatch across worker shards |
| `POST /mcp` | `crawl:read` / `crawl:fetch` | Stateless Streamable HTTP MCP JSON-RPC endpoint |

Drop-in Firecrawl v2 compatibility routes (`POST /v2/scrape`, `/v2/crawl`, `/v2/map`, `/v2/search`, `/v2/extract`, `/v2/agent`) are also documented under the `Compatibility` tag in `openapi.json`.

## Copy-paste `curl` examples

Set your Hub URL and token once in your shell:

```bash
export EDGEFETCH_URL="https://your-hub.example.com"
export EDGEFETCH_TOKEN="your-caller-or-oauth-token"
```

### Scrape a URL to clean Markdown (`/v1/scrape`)

```bash
curl -sS -X POST "$EDGEFETCH_URL/v1/scrape" \
  -H "Authorization: Bearer $EDGEFETCH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://developers.cloudflare.com/workers/",
    "formats": ["markdown"],
    "onlyMainContent": true
  }'
```

### Hybrid web & collection search (`/v1/search`)

```bash
curl -sS -X POST "$EDGEFETCH_URL/v1/search" \
  -H "Authorization: Bearer $EDGEFETCH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "site:go.dev net/http/httptrace phase timing",
    "max_results": 5,
    "mode": "waterfall"
  }'
```

### Multi-ATS job search & link verification (`/v1/jobs`)

```bash
curl -sS -X POST "$EDGEFETCH_URL/v1/jobs" \
  -H "Authorization: Bearer $EDGEFETCH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Systems Engineer",
    "domains": ["cloudflare.com", "tailscale.com"],
    "remote": true,
    "minBase": 160000,
    "limit": 10
  }'
```

### Storefront catalog extraction & diffing (`/v1/catalog`)

```bash
curl -sS -X POST "$EDGEFETCH_URL/v1/catalog" \
  -H "Authorization: Bearer $EDGEFETCH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://shop.example.com",
    "platform": "auto",
    "fields": "lean",
    "maxPages": 10
  }'
```

### BM25 passage extraction across URLs (`/v1/extract`)

```bash
curl -sS -X POST "$EDGEFETCH_URL/v1/extract" \
  -H "Authorization: Bearer $EDGEFETCH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "urls": [
      "https://www.rfc-editor.org/rfc/rfc9309",
      "https://www.rfc-editor.org/rfc/rfc9421"
    ],
    "query": "Crawl-delay Retry-After Ed25519 signature",
    "chunksPerSource": 3
  }'
```

### Async breadth-first site crawl (`/v1/crawl`)

```bash
curl -sS -X POST "$EDGEFETCH_URL/v1/crawl" \
  -H "Authorization: Bearer $EDGEFETCH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://edgefetch.dev",
    "includePaths": ["/guides/*", "/reference/*"],
    "limit": 25,
    "maxDepth": 2,
    "collectionId": "edgefetch-docs"
  }'
```

### Sandboxed Headless Chromium interaction (`/v1/interact`)

```bash
curl -sS -X POST "$EDGEFETCH_URL/v1/interact" \
  -H "Authorization: Bearer $EDGEFETCH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "actions": [
      { "type": "wait", "waitMs": 500 },
      { "type": "scroll" }
    ],
    "formats": ["markdown"]
  }'
```

### Autonomous BYO-LLM research agent (`/v1/agent`)

```bash
curl -sS -X POST "$EDGEFETCH_URL/v1/agent" \
  -H "Authorization: Bearer $EDGEFETCH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Compare the latest stable Go and Node.js LTS release versions with source URLs.",
    "effort": "medium",
    "zeroDataRetention": true,
    "llm": {
      "provider": "openai",
      "model": "gpt-4.1-mini"
    }
  }'
```

## 1-click import into AI tools & SDK generators

- **ChatGPT Custom GPT Actions:** Open **Configure → Actions → Create new action → Import from URL**, paste `https://<your-hub>/openapi.json` (or `https://edgefetch.dev/openapi.json` and update `servers[0].url` to your Hub), and select **Authentication → API Key → Bearer** (or **OAuth** with `https://<your-hub>/oauth/authorize` and `https://<your-hub>/oauth/token`).
- **OpenWebUI:** Go to **Workspace → Tools / External Tools → Add Connection**, set type to **OpenAPI**, enter `https://<your-hub>/openapi.json`, and provide your Hub Bearer token.
- **n8n / Dify / Postman / Scalar:** Import directly from URL `https://<your-hub>/openapi.json` — CORS (`Access-Control-Allow-Origin: *`) is enabled out of the box so browser-hosted workspaces fetch the schema without proxy errors.
- **`openapi-generator` (Typed SDK generation):**

```bash
npx @openapitools/openapi-generator-cli generate \
  -i https://edgefetch.dev/openapi.json \
  -g typescript-fetch \
  -o ./generated/edgefetch-api
```
