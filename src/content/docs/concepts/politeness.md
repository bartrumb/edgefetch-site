---
title: Politeness rules
description: The rules EdgeFetch always follows when it fetches a page.
---

EdgeFetch fetches pages only when a user or agent asks it to. It is not a web-wide crawler, and it
isn't used to train AI models. These rules are always on: they aren't settings you can turn off.

## robots.txt and Content Signals (100% RFC 9309)

- `robots.txt` is checked following **RFC 9309** (`1 MiB` parse cap, UTF-8 BOM handling, `Allow` and
  `Disallow`, `*` and `$` wildcards, §2.2.1 group combining, §2.2.2 percent-encoding normalization,
  §2.3.1.2 5-redirect handling, §2.4 `Cache-Control: max-age` up to 24h, and `Crawl-delay`) before
  the first request **and again on every redirect hop**.
- Temporary `/robots.txt` network timeouts or `5xx` errors are cached for 60 seconds and reported as
  `blocked: { reason: "robots_unreachable" }` (per RFC 9309 §2.3.1.4), distinct from explicit path
  `Disallow` rules (`reason: "robots"`).
- **Content Signals:** EdgeFetch parses `Content-Signal` lines (`search`, `ai-input`, `ai-train`) in
  the matching `User-agent` group (inheriting global/`*` signals when a specific group omits them).
  When `ai-input=no` is set, EdgeFetch treats the page as disallowed and returns
  `blocked: { reason: "content-signal" }`. EdgeFetch never trains models.
- **Owner-Explicit Partner / Self-Owned Bypass (`ROBOTS_BYPASS_HOSTS`):** `respectRobots: true` is
  locked on by default (`400 robots_required` if set to `false`). Operators crawling domains they
  own or hold written partner authorization for can allowlist specific domain suffixes in both
  `ROBOTS_BYPASS_HOSTS` (on the Hub) and `EDGEFETCH_ROBOTS_BYPASS_HOSTS` / `robots_bypass_hosts`
  (on worker nodes); every bypass call is logged in `hub_events`.
- `robots.txt` and `Content-Signal` blocks are never handed to a fallback service.

## Markdown negotiation and HTTP 402

- **Markdown for Agents:** Page scrapes negotiate `Accept: text/markdown, text/html;q=0.9, */*;q=0.8`
  first, saving bandwidth on origins that serve Markdown natively (`contentSource: "origin-markdown"`).
- **HTTP 402 / x402:** When a site answers with `402 Payment Required` (including `x402` payment
  headers or JSON terms), EdgeFetch classifies the response as `outcome: "payment_required"`,
  reports the price and terms to the calling agent, and **never pays automatically**.

## Rate limits ("3 strikes and you're out")

- On HTTP `429` (when not an anti-bot challenge), EdgeFetch performs **up to 3 adaptive attempts**,
  honouring the origin's `Retry-After` header (or exponential `4s` → `10s` backoff with jitter when
  `Retry-After` is absent) within the call's remaining deadline before returning `rate_limited` and
  placing that host/IP into a fleet cooldown.
- Each host has its own concurrency limit and pacing (`>= 2s` on store catalogs), across the whole fleet.

## Challenges and CAPTCHAs

EdgeFetch recognises challenge pages from Cloudflare, Akamai, DataDome, PerimeterX, AWS WAF,
Imperva and others. When it sees one, it **stops and returns `blocked: true`**. It ships no
stealth plugins, rotating proxies or CAPTCHA solvers.

## Wikipedia & Wikimedia (zero `robots.txt` exceptions)

Wikimedia's `robots.txt` allows reading `/wiki/<Title>` articles and `/w/rest.php/site/v1/sitemap*`, while disallowing `/wiki/Special:` (including `Special:Search`), `/w/api.php`, `/w/rest.php`, and `/api/rest_v1/` for `User-agent: *`. Many scrapers ignore `robots.txt` on those API paths; EdgeFetch **never** carves out `robots.txt` exceptions:

- **Read articles (`/wiki/<Title>`):** `scrape` fetches canonical article pages politely (1 in-flight request per Wikimedia host, `EdgeFetch/2.7 (bot@edgefetch.dev)` User-Agent, 24h default cache with `ETag` / `If-Modified-Since` revalidation, and `mediawiki` adapter cleanup that keeps infobox tables while stripping `[ ]`, `Edit links`, `[edit]`, and `[n]` citation noise).
- **Find articles (`search` with `wikipedia: true` or `site:<lang>.wikipedia.org`):** Resolves canonical `/wiki/<Title>` URLs through the configured search waterfall (with at most one direct `/wiki/<Title>` title guess on fallback) — never touching `Special:Search`, `/w/`, or `/api/`.
- **Bulk & structured data:** After `200` live article requests per caller per Wikimedia host in an hour, EdgeFetch halts crawling with `outcome: "use_bulk_channel"` and directs callers to [Wikimedia Enterprise](https://enterprise.wikimedia.com/) (licensed On-Demand & Snapshot APIs via per-user encrypted vault credentials), [Wikimedia Dumps](https://dumps.wikimedia.org/), or the [`wikimedia/wikipedia`](https://huggingface.co/datasets/wikimedia/wikipedia) dataset.

## Identifying itself

Requests carry an `EdgeFetch/<version>` User-Agent. Operators can sign requests with RFC 9421
HTTP Message Signatures (Ed25519) and publish their key at
`/.well-known/http-message-signatures-directory` on their hub, so a site can check who sent the
traffic. See [For website owners](/site-owners/).
