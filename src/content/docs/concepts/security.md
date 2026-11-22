---
title: Security model
description: Dial-time SSRF protection, Direct Pipe CDP sandboxing, per-user AES-256-GCM MCP vault, signed releases and vulnerability reporting.
---

EdgeFetch fetches URLs and federated tool outputs on behalf of AI agents, which makes every target URL and remote response untrusted input.

## SSRF protection at dial time

- Target URLs must use `https`, have a multi-label DNS host, and contain no IP literals, `localhost`
  or `user:pass@`.
- The resolved IP is checked **inside the dialer, right before `connect()`**. This blocks
  DNS-rebinding tricks where a name resolves to a public IP at check time and a private one at
  connect time.
- Blocked ranges include loopback, RFC 1918, CGNAT and Tailscale (`100.64.0.0/10`), link-local
  and cloud metadata (`169.254.0.0/16`), ULA, and IPv6 transition prefixes.
- Redirects are followed manually, up to 5 hops, re-checking `robots.txt` and dial-time IP rules on every hop.

## Direct Pipe CDP, browser sandboxing & VLAN guidance

- **Zero listening browser ports:** Headless Chromium communicates with the Go worker strictly over anonymous OS pipes (**Direct Pipe CDP**, `--remote-debugging-pipe` on Linux, macOS, and Windows via `CreateProcessW` FD 3/4 inheritance + Job Object kill-on-close) — Chromium opens **zero** TCP debugging sockets.
- **OS process sandbox:** On Windows and macOS, Headless Chromium runs with its **native OS process
  sandbox enabled** (`browserSandbox: "on"`). On Linux containers where `NO_NEW_PRIVS` or disabled
  user namespaces prevent Chromium's namespace sandbox, EdgeFetch probes sandbox startup once,
  falls back only when required, and reports `browserSandbox: "on" | "off"` in `list_agents`
  (with optional `EDGEFETCH_REQUIRE_BROWSER_SANDBOX=1` hard enforcement).
- **Subresource proxy, WebRTC guard & initiator-proven headers:** Every browser subresource is forced through an in-process SSRF-checked loopback proxy (`--host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE 127.0.0.1"`, `--webrtc-ip-handling-policy=disable_non_proxied_udp`). Caller custom headers are attached via CDP `Fetch.requestPaused` strictly to the initiator-proven initial navigation request and never leak to subresources or cross-origin redirects.
- **Home network isolation:** Place home `browser-v1` / `pdf-v1` nodes on an **isolated VLAN or guest network** (and a standard non-admin account on Windows). Child processes run with a scrubbed environment, `O_NOFOLLOW`-verified `/data` permissions, and `PR_SET_DUMPABLE=0`.

## Multi-user isolation & `AES-256-GCM` MCP vault

- **Per-user tenant boundaries:** On multi-user hubs using GitHub OAuth (`SIGNUP_MODE=invite_only` default), OAuth grants, `/v1/interact` session HMACs, `/v1/agent` runs, FTS5 collections, and `private/<userId>/...` R2 cache objects are bound to `user_id`.
- **Origin-bound `AES-256-GCM` credential vault:** Downstream MCP server tokens and headers configured in `/admin` require `VAULT_MASTER_KEY` (`>= 24` chars, fail-closed), derive a unique key per user and origin with WebCrypto `HKDF-SHA256`, and authenticate `AAD = "${userId}|${remoteOrigin}"`. Decrypted secrets are write-only, never returned to `/admin`, and never forwarded across cross-origin redirects.
- **Prompt-injection & Markdown defences:** Extracted Markdown syncs CommonMark fence state, neutralises bare URLs adjacent to code spans, strips bidi/zero-width smuggling characters, and runs linear-time prompt-injection scanning across web pages and federated MCP responses.

## Least privilege & supply chain

- Containers run as non-root `65532:65532` with `no-new-privileges` and an AppArmor profile in the Home Assistant add-on.
- **Small, audited dependency surface:** The Go module keeps strictly **1 external dependency** (`github.com/coder/websocket`, zero transitive dependencies). Site adapters are 100% declarative YAML (`compiled.json`) with zero executable code, and the Hub restricts runtime packages to small vetted libraries (`htmlparser2`, `jose`, `oauth4webapi`, `re2js`, `ws`, `yaml`).
- Releases are immutable, signed with Ed25519 (`environment: release` with admin bypass disabled), and attested with GitHub SLSA build provenance; `edgefetch update` verifies Ed25519 + SHA-256 before replacing binaries. See [Verify a release](/guides/verify-release/).

## Reporting a vulnerability

Please report privately through
[GitHub Security Advisories](https://github.com/bartrumb/edgefetch/security/advisories/new),
not in a public issue. The full threat model is in
[SECURITY.md](https://github.com/bartrumb/edgefetch/blob/main/SECURITY.md).
