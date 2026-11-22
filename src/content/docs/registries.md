---
title: Registries and bot lists
description: Where EdgeFetch is listed as an MCP server and a known, polite bot, what's live today, and how operators register their own fleets.
---

EdgeFetch is registered in two kinds of places. MCP directories let people find and install
it. Bot directories let website owners recognise it as a polite fetcher acting for a person, not
a crawler collecting AI training data.

## Two identities, kept apart

Because anyone can run EdgeFetch, there are two separate things to register:

| What | Who registers it | What it covers |
|---|---|---|
| **The project** | The maintainer | The `EdgeFetch` user agent and its documentation, MCP directory listings, and signed releases |
| **A fleet** | Each operator, for their own hub | That operator's own signing key, so sites can verify their traffic |

The repository never ships a shared signing key. If it did, anyone could sign as you, and the key
would end up revoked for everyone.

## Status

This page is kept current. Nothing is marked live until the listing is active.

| Directory | Kind | Status |
|---|---|---|
| [Official MCP Registry](https://registry.modelcontextprotocol.io/v0/servers?search=edgefetch) | MCP | **Live (`active`, `v2.7.0`)** as `io.github.bartrumb/edgefetch`, published automatically via GitHub OIDC on every signed release |
| [Glama](https://glama.ai/mcp/servers) | MCP | `glama.json` published in repository; searchable directly inside `/admin` and `discover_mcps` |
| [PulseMCP](https://www.pulsemcp.com) and [mcp.so](https://mcp.so) | MCP | Planned |
| [Known Agents](https://knownagents.com) | Bot directory | Planned, as a user-triggered fetcher that does not train models |
| [Cloudflare Verified Bots](https://radar.cloudflare.com/bots) | Bot directory | Per operator, using Web Bot Auth. See below |
| [OpenSSF Best Practices](https://www.bestpractices.dev) | Open-source security badge | Planned |

## What EdgeFetch tells site owners about itself

- **User agent:** `EdgeFetch/<version> (bot@edgefetch.dev)`, with the robots.txt token `EdgeFetch`.
  Operators should replace the contact with their own.
- **A policy file:** every hub serves `/.well-known/edgefetch-bot.json`, saying it follows
  robots.txt strictly, stops at challenges, and does not train AI models. This site serves the
  same file at [edgefetch.dev/.well-known/edgefetch-bot.json](https://edgefetch.dev/.well-known/edgefetch-bot.json).
- **Signatures:** with Web Bot Auth switched on, requests carry RFC 9421 HTTP Message Signatures
  that a site can check against the operator's published key.

For the site owner's view, see [For website owners](/site-owners/).

## Register your own fleet with Cloudflare Verified Bots

If you run a hub and want your traffic recognised:

1. Create a signing key:

   ```bash
   edgefetch keygen-bot-auth
   ```

2. Give the private seed to your hub:

   ```bash
   cd hub
   npx wrangler secret put BOT_SIGNING_PRIVATE_KEY
   ```

   On the Go or portable hub, set the same value as an environment variable. Workers that fetch
   directly also need `EDGEFETCH_BOT_SIGNING_KEY` and `EDGEFETCH_BOT_DIRECTORY_URL`.

3. Check that your key directory is live and signed:

   ```bash
   curl -i https://<your-hub>/.well-known/http-message-signatures-directory
   ```

   You should see `200`, the content type
   `application/http-message-signatures-directory+json`, `signature` and `signature-input`
   headers, and a JSON body with your Ed25519 key.

4. Submit it in the Cloudflare dashboard as a user-triggered fetcher (not a training crawler),
   with Web Bot Auth as the verification method and that directory URL.

## Polite pools for research sites

SEC EDGAR, OpenAlex, Crossref and NCBI give better service to clients that identify themselves.
Put a real contact in your user agent:

```bash
EDGEFETCH_USER_AGENT="EdgeFetch/2.7 (mailto:you@yourdomain.com)"
```

The full maintainer notes are in
[docs/REGISTRATION.md](https://github.com/bartrumb/edgefetch/blob/main/docs/REGISTRATION.md).
