---
title: Deploy a hub
description: Run the EdgeFetch hub on Cloudflare Workers, a container platform, a VPS or your own box.
---

The hub accepts MCP and HTTP requests, keeps the queue, stores results, and hands work to
connected worker nodes. Pick one place to run it.

## Cloudflare Workers (idles at $0)

The hub runs on hibernating Durable Objects with D1 (FTS5 search) and R2 (artifacts). Use the
**Deploy to Cloudflare** button in the
[README](https://github.com/bartrumb/edgefetch#readme), or:

```bash
git clone https://github.com/bartrumb/edgefetch.git
cd edgefetch/hub
npm ci
npx wrangler deploy
```

Set the caller and agent tokens as Worker secrets, not in `wrangler.jsonc`.

## Render, Railway or Fly.io

These run the all-in-one container with a persistent `/data` volume. The repository includes
`render.yaml`, `railway.json` and `fly.toml`. For Fly:

```bash
fly launch --copy-config
```

## Self-hosted Go hub on a VPS

The Go binary can act as the hub itself:

```bash
EDGEFETCH_CALLER_TOKEN="<32-char-secret>" \
EDGEFETCH_AGENT_TOKEN="<32-char-secret>" \
  edgefetch --mode=hub --addr=0.0.0.0:8080
```

Run `--mode=hub,agent` to make one box both the hub and a worker. Give workers several hub URLs
(`EDGEFETCH_HUB_URLS`) for an active-active standby.

## Tracing

The hub and workers can export OpenTelemetry (OTLP/HTTP JSON) with W3C `traceparent`
propagation, so one trace covers the hub request and the worker's DNS, connect, TLS and
first-byte timings. See
[docs/USAGE.md](https://github.com/bartrumb/edgefetch/blob/main/docs/USAGE.md).
