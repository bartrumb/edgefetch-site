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

## The browser is fenced in too

Headless Chromium is started with every subresource forced through an in-process loopback proxy
(`--proxy-server=http://127.0.0.1:<port>`, `--proxy-bypass-list=<-loopback>`,
`--host-resolver-rules=MAP * ~NOTFOUND`, and
`--force-webrtc-ip-handling-policy=disable_non_proxied_udp`). Child processes (`chromium` and
`pdftotext`) run with a scrubbed environment so operator tokens never enter the browser process,
and the final post-navigation URL is re-checked against SSRF and `robots.txt` rules before any DOM
is returned.

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
