---
title: Add worker nodes
description: Run EdgeFetch workers on home hardware behind NAT, with no port forwarding.
---

Workers do the actual fetching and rendering. Each worker opens an outbound TLS WebSocket
(`WSS /agent/ws`) to the hub, so it works behind CGNAT, Starlink or a home router with nothing
forwarded.

## Docker

```bash
docker run -d --name edgefetch-agent --restart=unless-stopped \
  --security-opt no-new-privileges:true \
  -e EDGEFETCH_HUB_URL=https://<your-hub-domain> \
  -e EDGEFETCH_AGENT_TOKEN="<YOUR_AGENT_TOKEN>" \
  -e EDGEFETCH_SITE_ID="node-1" \
  ghcr.io/bartrumb/edgefetch-agent:2.5.2
```

For a lighter node without a browser, use the `lite` image with `--mode=agent` and a read-only
root filesystem:

```bash
docker run -d --name edgefetch-lite --restart=unless-stopped --read-only \
  -e EDGEFETCH_HUB_URL=https://<your-hub-domain> \
  -e EDGEFETCH_AGENT_TOKEN="<YOUR_AGENT_TOKEN>" \
  -e EDGEFETCH_SITE_ID="lite-1" \
  ghcr.io/bartrumb/edgefetch-agent:2.5.2-lite --mode=agent
```

## Other places it runs

- **Home Assistant OS** add-on (`amd64`, `aarch64`)
- **Kubernetes**, with a read-only root filesystem, `seccomp: RuntimeDefault` and a
  `NetworkPolicy` with no ingress (`deploy/k8s/`)
- **Unraid, CasaOS, Portainer, Synology, Proxmox LXC**, using `compose.agent.yaml`
- **Bare binary** on Linux, macOS, Windows, FreeBSD or OpenWrt

The platform matrix in the README marks which targets run daily and which are build-verified only.

## Set your contact details

If you run your own fleet, set a User-Agent that identifies **you**, so site owners can reach the
operator:

```bash
EDGEFETCH_USER_AGENT="EdgeFetch/2.5 (+https://your-site.example/bot)"
```
