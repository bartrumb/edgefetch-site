---
title: Security model
description: SSRF protection, sandboxing, signed releases and how to report a vulnerability.
---

EdgeFetch fetches URLs that come from AI agents, which makes those URLs untrusted input. The main
risk is server-side request forgery (SSRF): tricking a worker into reaching your LAN, a cloud
metadata endpoint or your Home Assistant.

## SSRF protection at dial time

- The URL must use `https`, have a multi-label DNS host, and contain no IP literals, `localhost`
  or `user:pass@`.
- The resolved IP is checked **inside the dialer, right before `connect()`**. This blocks
  DNS-rebinding tricks where a name resolves to a public IP at check time and a private one at
  connect time.
- Blocked ranges include loopback, RFC 1918, CGNAT and Tailscale (`100.64.0.0/10`), link-local
  and cloud metadata (`169.254.0.0/16`), ULA, and IPv6 transition prefixes.
- Redirects are followed by hand, up to 5 hops, and every hop is checked again.

## Browser sandboxing, network proxy & VLAN guidance

- **OS process sandbox:** On Windows and macOS, Headless Chromium runs with its **native OS process
  sandbox enabled** (`browserSandbox: "on"`). On Linux containers where `NO_NEW_PRIVS` or disabled
  user namespaces prevent Chromium's namespace sandbox, EdgeFetch probes sandbox startup once,
  falls back only when required, and reports `browserSandbox: "on" | "off"` and `browserVersion` in
  `list_agents` (with optional `EDGEFETCH_REQUIRE_BROWSER_SANDBOX=1` enforcement).
- **Subresource proxy & WebRTC guard:** Chromium runs with every subresource forced through an
  in-process loopback proxy (`--proxy-server=http://127.0.0.1:<port>`,
  `--proxy-bypass-list=<-loopback>`, `--host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE 127.0.0.1"`,
  `--webrtc-ip-handling-policy=disable_non_proxied_udp`, and
  `--enforce-webrtc-ip-permission-check`). Caller extra headers are attached per-request strictly to
  the initial target hostname via CDP `Fetch.enable`.
- **Home network isolation:** Because browser and PDF worker nodes run untrusted JavaScript and
  native document parsers, place home `browser-v1` / `pdf-v1` nodes on an **isolated VLAN or guest
  network** (and a standard non-admin user on Windows) so even an unpatched browser bug cannot reach
  LAN devices. Child processes run with a scrubbed environment, locked-down `/data` (`0700` `0:0`),
  and `PR_SET_DUMPABLE=0`.

## Least privilege

- Containers run as non-root `65532:65532`, with `no-new-privileges` and an AppArmor profile in the
  Home Assistant add-on.
- On Linux the add-on drops to UID 65532 on every OS thread before opening any socket.

## Supply chain

- One external Go dependency. The hub has zero npm runtime dependencies.
- Dependabot watches Go modules, npm and GitHub Actions. `govulncheck` runs in CI.
- Releases are signed and attested. See [Verify a release](/guides/verify-release/).

## Reporting a vulnerability

Please report privately through
[GitHub Security Advisories](https://github.com/bartrumb/edgefetch/security/advisories/new),
not in a public issue. The full threat model is in
[SECURITY.md](https://github.com/bartrumb/edgefetch/blob/main/SECURITY.md).
