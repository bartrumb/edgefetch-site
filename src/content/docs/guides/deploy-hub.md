---
title: Deploy a hub
description: Every way to run the EdgeFetch hub, from Cloudflare Workers to one container to the Go binary on a VPS.
---

The hub is the only part of EdgeFetch that faces the internet. It serves `/mcp`, the REST API,
the `/admin` console and OAuth 2.1, keeps per-host pacing and cooldowns, and hands work to
connected workers. Worker nodes never accept inbound connections.

Pick one place to run it. For the click-and-go versions, see [One-click deploys](/deploy/one-click/).

| Option | Runtime | Storage | Idle cost | Workers built in? |
|---|---|---|---|---|
| Cloudflare Workers | TypeScript hub on a hibernating Durable Object | Durable Object SQLite, optional R2 and D1 | $0 on the free plan | No. Cloudflare egress is a fallback only |
| All-in-one container | Node hub + Go worker + Chromium | SQLite with FTS5 under `/data` | Whatever the host charges | Yes |
| Portable hub on Deno or Node | `hub/portable/` | Turso (libSQL over HTTP) and any S3-compatible bucket | Low | No |
| Go binary, `--mode=hub` | One static Go binary | Local | One small VPS | Add `,agent` to run both |

## Cloudflare Workers

```bash
git clone https://github.com/bartrumb/edgefetch.git
cd edgefetch/hub
npm ci
npx wrangler secret put CALLER_TOKEN       # >= 24 random chars (owner/CI API token)
npx wrangler secret put AGENT_TOKEN        # >= 24 random chars (outbound worker secret)
npx wrangler secret put VAULT_MASTER_KEY   # >= 24 random chars (AES-256-GCM MCP vault key)
npm run deploy
```

The Durable Object hibernates between requests, and idle worker pings are answered by
Cloudflare's auto-response without waking it, so a quiet hub costs nothing. R2 (artifacts) and
two D1 databases (`META` for crawl metadata, multi-user accounts & agent runs via `hub/migrations/meta/*.sql`, and `SEARCH` for FTS5 full-text search) are optional bindings in
`hub/wrangler.toml`.

To enable multi-user **Sign in with GitHub** on `/admin` and `/oauth/authorize` (`SIGNUP_MODE=invite_only` by default), set `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `GITHUB_OWNER_LOGIN`, and `GITHUB_ALLOWED_USERS="alice,@your-org"`. Headless `CALLER_TOKEN` bearer auth continues to work alongside GitHub OAuth.

Forks can also enable automated Ed25519-verified upstream release syncing (`.github/workflows/upstream-sync.yml` with repository variable `ENABLE_UPSTREAM_AUTO_SYNC=true`) and automatic tag deploys (`.github/workflows/deploy-hub.yml`).

## All-in-one container

The simplest self-hosted setup: one container with the hub, a Go worker with headless Chromium,
and SQLite full-text search. No Redis, no Postgres.

```bash
git clone https://github.com/bartrumb/edgefetch.git && cd edgefetch
CALLER_TOKEN="$(openssl rand -hex 24)" docker compose up --build -d
# open http://127.0.0.1:8787/admin
```

`docker-compose.yml` binds to `127.0.0.1` only. Put TLS in front of it before you expose it.
The same image runs on Render (`render.yaml`), Railway (`railway.json`), Fly.io (`fly.toml`) and
Coolify. Give it a persistent volume at `/data`.

## Portable hub on Deno Deploy or Node

`hub/portable/` runs the same hub code outside Cloudflare. It swaps D1 for Turso over HTTP and R2
for any S3-compatible store (AWS S3, R2, Tigris, MinIO or Backblaze B2), using WebCrypto SigV4
with no extra dependencies.

```bash
cd hub
npm ci
npm run start:portable   # builds dist/portable-server.mjs and starts it on Node 22.5+
```

Point it at your storage with `TURSO_DATABASE_URL` and `TURSO_AUTH_TOKEN`, plus `S3_ENDPOINT`,
`S3_BUCKET`, `S3_ACCESS_KEY_ID` and `S3_SECRET_ACCESS_KEY`. Without them it keeps everything under
`EDGEFETCH_DATA_DIR` on local disk.

On Deno Deploy, use the button on [One-click deploys](/deploy/one-click/) or point a project at
`hub/portable/deno-server.ts`.

## Go binary on a VPS

The Go binary can be the hub itself, serving `/agent/ws`, `/v1/scrape`, `/fetch` and `/mcp`:

```bash
EDGEFETCH_CALLER_TOKEN="<32-char-secret>" \
EDGEFETCH_AGENT_TOKEN="<32-char-secret>" \
  edgefetch --mode=hub --addr=0.0.0.0:8080
```

Use `--mode=hub,agent` to make one box both the hub and a worker, for example a mini PC on your
tailnet.

## High availability

These layers stack, and none needs an external broker:

- **Several hubs per worker.** Give a worker `EDGEFETCH_HUB_URLS="wss://cf-hub.example.com,wss://standby.fly.dev"`
  and it holds a connection to each, sharing one per-host politeness state.
- **Durable Object shards.** Set `HUB_SHARDS="global,standby"` on the Cloudflare hub and connect
  workers to `?shard=global` and `?shard=standby`.
- **Client failover.** The TypeScript and Python SDKs take a list of `baseUrls` and move to the
  next hub on network errors or `502`, `503` and `504`.

## Tracing

The hub and workers export OpenTelemetry over OTLP/HTTP and pass W3C `traceparent` across the
WebSocket, so the hub's dispatch and the worker's DNS, connect, TLS and first-byte timings show
up as one trace in Honeycomb, Grafana Tempo, Axiom, SigNoz or Jaeger.

```bash
OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io"
OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=<YOUR_API_KEY>"
OTEL_SERVICE_NAME="edgefetch-hub"
```

See also [Troubleshooting and traces](/guides/troubleshooting/).
