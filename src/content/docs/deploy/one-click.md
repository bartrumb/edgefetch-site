---
title: One-click deploys
description: The deploy buttons in the EdgeFetch repository, what each one creates, and what to set afterwards.
---

The README has a deploy button for each hosted platform. Every button starts from the same
public repository, so you can read exactly what gets deployed before you click.

| Button | Creates | Good for |
|---|---|---|
| [![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/bartrumb/edgefetch/tree/main/hub) | The TypeScript hub as a Cloudflare Worker with a hibernating Durable Object | A hub that costs $0 while idle |
| [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/bartrumb/edgefetch) | The all-in-one container from `render.yaml`, with a disk at `/data` | One service with the hub, a worker and search together |
| [![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/github/bartrumb/edgefetch) | The all-in-one container from `railway.json` | Same as Render, on Railway |
| [![Deploy on Deno](https://deno.com/button)](https://console.deno.com/new?clone=https://github.com/bartrumb/edgefetch&entrypoint=hub/portable/deno-server.ts) | The portable hub on Deno Deploy (`hub/portable/deno-server.ts`) | A serverless hub off Cloudflare, with Turso and S3 for storage |
| [![Add to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fbartrumb%2Fedgefetch) | Adds the EdgeFetch add-on repository to Home Assistant OS | A worker node on the box you already run |

Fly.io has no button, but the repository includes `fly.toml`:

```bash
fly launch --copy-config
```

## After you click

1. **Set two secrets.** `CALLER_TOKEN` is what your agents and the `/admin` console use.
   `AGENT_TOKEN` is what worker nodes use to connect. Use long random values, for example
   `openssl rand -hex 24`.
2. **Open `/admin`** on your new hub and sign in with the caller token.
3. **Connect your agent** to `https://<your-hub>/mcp`. See
   [Connect an MCP client](/start/mcp-clients/).
4. **Add a worker** if your hub has none built in. See [Add worker nodes](/guides/workers/).

On Cloudflare, a hub with no workers still fetches through Cloudflare's own network, but adding
a worker at home gives you your own IP address and a headless browser for JavaScript pages.

## Optional features to switch on

All of these are off until you configure them:

| Feature | What to set |
|---|---|
| Encrypted MCP Registry vault (`/admin`) | `VAULT_MASTER_KEY` (`>= 24` random chars, e.g. `openssl rand -hex 32`) |
| Multi-user Sign in with GitHub | `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`, `GITHUB_OWNER_LOGIN`, and `GITHUB_ALLOWED_USERS="alice,@my-org"` (`SIGNUP_MODE=invite_only` default) |
| Web search | `SERPER_API_KEY`, `BRAVE_API_KEY` or `TAVILY_API_KEY`, or `SEARXNG_URL` for a free self-hosted option |
| Stored artifacts and crawl history | The `ARTIFACTS` R2 bucket and `META` D1 database in `hub/wrangler.toml` (`0001_tracking.sql` + `0002_multiuser.sql`) |
| Full-text search over what you've collected | The `SEARCH` D1 database |
| Signed requests (Web Bot Auth) | `BOT_SIGNING_PRIVATE_KEY`, from `edgefetch keygen-bot-auth` |
| Tracing | `OTEL_EXPORTER_OTLP_ENDPOINT` and `OTEL_EXPORTER_OTLP_HEADERS` |
| Heavy single-page apps | `CRAWL4AI_API_URL`, or `FIRECRAWL_API_URL` and `FIRECRAWL_API_KEY`, as a fallback after robots.txt passes |
