---
title: Add worker nodes
description: Every place an EdgeFetch worker can run, from Docker and Home Assistant to routers, NAS boxes and spare phones.
---

Workers do the fetching and rendering. Each one opens an outbound TLS WebSocket to the hub
(`wss://<hub>/agent/ws`) and waits for jobs, so it works behind CGNAT, Starlink or a home router
with nothing forwarded. Workers run as non-root `65532:65532` and never serve `/admin` or `/mcp`.

Every worker needs the same three settings:

| Setting | What it is |
|---|---|
| `EDGEFETCH_HUB_URL` | Your hub, for example `https://hub.example.com` |
| `EDGEFETCH_AGENT_TOKEN` | The hub's `AGENT_TOKEN` |
| `EDGEFETCH_SITE_ID` | A name for this node, shown in `/admin` |

## Pick an image

| Image | Size | Can do |
|---|---|---|
| `ghcr.io/bartrumb/edgefetch-agent:<version>` | Larger (Alpine + Chromium) | HTTP/2, JavaScript rendering, `interact`, Poppler PDF |
| `ghcr.io/bartrumb/edgefetch-agent:<version>-lite` | About 9 MB, distroless | HTTP/2, Markdown, pure-Go PDF, about 15 MB of RAM |

Pin a version tag in production. The hub routes browser jobs only to nodes that report the
`browser-v1` capability.

## Docker

```bash
docker run -d --name edgefetch-agent --restart=unless-stopped \
  --security-opt no-new-privileges:true \
  -e EDGEFETCH_HUB_URL=https://<your-hub-domain> \
  -e EDGEFETCH_AGENT_TOKEN="<YOUR_AGENT_TOKEN>" \
  -e EDGEFETCH_SITE_ID="node-1" \
  ghcr.io/bartrumb/edgefetch-agent:latest
```

The lite node can run with a read-only root filesystem:

```bash
docker run -d --name edgefetch-lite --restart=unless-stopped --read-only \
  -e EDGEFETCH_HUB_URL=https://<your-hub-domain> \
  -e EDGEFETCH_AGENT_TOKEN="<YOUR_AGENT_TOKEN>" \
  -e EDGEFETCH_SITE_ID="lite-1" \
  ghcr.io/bartrumb/edgefetch-agent:lite --mode=agent
```

`compose.agent.yaml` in the repository is the Compose version of the same thing.

## Home Assistant OS

Use the **Add to Home Assistant** button on [One-click deploys](/deploy/one-click/), install
**EdgeFetch**, and set `hub_url`, `agent_token` and `site_id`. The add-on runs on `amd64` and
`aarch64` with an AppArmor profile, and adds two safety settings of its own:

| Option | Default | What it does |
|---|---|---|
| `pause_ms` | 3000 | The minimum gap between requests to one host. Callers can ask for slower, never faster |
| `pause_jitter_ms` | 1500 | Random extra delay added to every request |
| `allowed_hosts` | empty (all public HTTPS) | Optional list of domains this node may fetch |

## Homelab and NAS templates

| Platform | File in the repository |
|---|---|
| Unraid | `deploy/unraid/edgefetch-agent.xml` |
| CasaOS, Portainer, Coolify | `deploy/casaos/docker-compose.yml` |
| Proxmox LXC | `deploy/proxmox/create-edgefetch-lxc.sh` |
| Kubernetes | `deploy/k8s/agent-deployment.yaml`: non-root, all capabilities dropped, and a `NetworkPolicy` that blocks all ingress and private-range egress |
| Synology | Use the Compose file in Container Manager |

## Bare binary

Download an archive from [GitHub Releases](https://github.com/bartrumb/edgefetch/releases/latest)
and run:

```bash
EDGEFETCH_HUB_URL=https://<your-hub-domain> \
EDGEFETCH_AGENT_TOKEN="<YOUR_AGENT_TOKEN>" \
EDGEFETCH_SITE_ID="mini-pc" \
  edgefetch --mode=agent
```

Static builds cover Linux (`amd64`, `arm64`, `arm`, `mipsle`), macOS, Windows and FreeBSD. That
also covers OpenWrt and GL.iNet routers, OPNsense and pfSense, and MikroTik RouterOS v7 through the
lite container. On a spare Android phone, `deploy/termux/install-termux-agent.sh` sets up a
worker under Termux.

A Windows Package Manager manifest is in `deploy/winget/`.

## Several hubs at once

Give a worker a comma-separated list instead of one URL, and it keeps a connection to each:

```bash
EDGEFETCH_HUB_URLS="wss://cf-hub.example.com,wss://standby.fly.dev"
```

Per-host pacing is shared across all of them, so two hubs can't double the load on a site.

## Set your contact details

If you run your own fleet, set a User-Agent that identifies **you**, so site owners can reach the
operator:

```bash
EDGEFETCH_USER_AGENT="EdgeFetch/2.7 (+https://your-site.example/bot)"
```

The platform matrix in the [README](https://github.com/bartrumb/edgefetch#readme) marks which
targets run daily and which are build-verified only. Reports from real hardware are a welcome
[contribution](/contributing/).
