---
title: Politeness rules
description: The rules EdgeFetch always follows when it fetches a page.
---

EdgeFetch fetches pages only when a user or agent asks it to. It is not a web-wide crawler, and it
isn't used to train AI models. These rules are always on: they aren't settings you can turn off.

## robots.txt and Content Signals

- `robots.txt` is checked following RFC 9309 (`Allow`, `Disallow`, `*` and `$` wildcards,
  `Crawl-delay`) before the first request **and again on every redirect hop**.
- **Content Signals:** EdgeFetch parses `Content-Signal` lines (`search`, `ai-input`, `ai-train`) in
  the matching `User-agent` group. When `ai-input=no` is set, EdgeFetch treats the page as
  disallowed and returns `blocked: { reason: "content-signal" }`. EdgeFetch never trains models.
- The product token is `EdgeFetch`, matched case-insensitively. The `User-agent: *` group applies
  if there's no EdgeFetch-specific group.
- `robots.txt` and `Content-Signal` blocks are never handed to a fallback service.

## Markdown negotiation and HTTP 402

- **Markdown for Agents:** Page scrapes negotiate `Accept: text/markdown, text/html;q=0.9, */*;q=0.8`
  first, saving bandwidth on origins that serve Markdown natively (`contentSource: "origin-markdown"`).
- **HTTP 402 / x402:** When a site answers with `402 Payment Required` (including `x402` payment
  headers or JSON terms), EdgeFetch classifies the response as `outcome: "payment_required"`,
  reports the price and terms to the calling agent, and **never pays automatically**.

## Rate limits

- `429` and `503` responses with `Retry-After` put that host into a cooldown.
- Each host has its own concurrency limit and pacing, across the whole fleet.

## Challenges and CAPTCHAs

EdgeFetch recognises challenge pages from Cloudflare, Akamai, DataDome, PerimeterX, AWS WAF,
Imperva and others. When it sees one, it **stops and returns `blocked: true`**. It ships no
stealth plugins, rotating proxies or CAPTCHA solvers.

## Identifying itself

Requests carry an `EdgeFetch/<version>` User-Agent. Operators can sign requests with RFC 9421
HTTP Message Signatures (Ed25519) and publish their key at
`/.well-known/http-message-signatures-directory` on their hub, so a site can check who sent the
traffic. See [For website owners](/site-owners/).
