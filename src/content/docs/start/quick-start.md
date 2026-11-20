---
title: Quick start
description: Get EdgeFetch answering your AI agent's web requests in a few minutes.
---

There are two ways to start. Pick the one that matches what you want.

| You want… | Use |
|---|---|
| Your desktop agent (Claude Code, Claude Desktop, Cursor…) to read the web | **Local binary over `stdio`**: no server, no ports |
| A shared hub with an admin console, worker nodes and search | **Docker hub**: one container, no cloud account |

## Option 1: Local binary for your MCP client

```bash
go install github.com/bartrumb/edgefetch/v2/cmd/edgefetch@latest
edgefetch init
edgefetch doctor
```

No Go toolchain? Download a release archive for your OS from
[GitHub Releases](https://github.com/bartrumb/edgefetch/releases/latest) instead.

Then register it with your MCP client:

```bash
edgefetch install-mcp
```

This writes a `stdio` server entry into Claude Desktop and Cursor. For other clients, see
[Connect an MCP client](/start/mcp-clients/).

Try a scrape from the terminal:

```bash
edgefetch scrape https://example.com
```

On the desktop, EdgeFetch uses the Chrome, Edge or Brave you already have installed to render
JavaScript pages. It doesn't download its own browser.

## Option 2: Full hub in Docker

```bash
git clone https://github.com/bartrumb/edgefetch.git
cd edgefetch
CALLER_TOKEN="$(openssl rand -hex 24)" docker compose up --build -d
```

Open `http://127.0.0.1:8787/admin` and paste the `CALLER_TOKEN` you generated. By default,
`docker-compose.yml` binds strictly to `127.0.0.1:8787` so it is never exposed to your LAN unless
you front it with TLS.

The all-in-one container includes the hub, a Go worker with headless Chromium, and SQLite
full-text search under `/data`. It needs no Redis and no Postgres.

## Next steps

- [Deploy a hub](/guides/deploy-hub/) on Cloudflare Workers, a VPS or Home Assistant.
- [Add worker nodes](/guides/workers/) at home, without opening ports.
- Read the [MCP tools reference](/reference/tools/).
