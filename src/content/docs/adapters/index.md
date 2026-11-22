---
title: Site adapters
description: The 56 built-in declarative YAML adapters that turn known sites, job boards and open-data portals into clean structured results, with no API keys.
---

Most pages are fetched as HTML and cleaned into Markdown. For sites with a better public source,
such as a JSON API, a feed, a `.patch` file or structured data in the page, a **declarative YAML adapter** uses
that instead. You get cleaner results in fewer requests, without any API keys.

## How adapters behave

- **Zero executable code.** Every adapter is a declarative YAML manifest (`internal/extract/manifests/*.yaml`) compiled into a single checked JSON IR (`compiled.json`) embedded in both the Hub and the Go binary.
- **They never fetch on their own.** An adapter declares the URL template or HTML selectors it wants, and EdgeFetch fetches it with the usual `robots.txt` checks, dial-time IP checks, per-host pacing and tracing.
- **They fail open.** If a site changes its JSON or markup, the adapter returns nothing and EdgeFetch falls back to normal extraction, so the request still succeeds.
- **They're keyless and MIT-licensed.** Built-in adapters only use public, free sources. For authenticated private APIs (GitHub repos, Linear, Notion, Jira), connect an MCP server in `/admin`'s **MCP Registry & Encrypted Connectors** vault instead.

To see which adapter would handle a URL, call the `find_extractors` MCP tool, or list them all
with `GET /v1/extractors` (filter with `?category=jobs`).

## The catalog

There are **56 declarative YAML manifests** across 7 categories. Several manifests cover whole multi-tenant platforms.

### Jobs

Greenhouse and Lever (US and EU), Ashby, Workday, Workable, Rippling, Gem, Pinpoint, Teamtailor,
BambooHR, Breezy and Recruitee, JazzHR, iCIMS, SAP SuccessFactors RMK, Jibe, Oracle HCM and other
enterprise ATSs, and public job feeds. The `jobs` tool searches across them and normalises pay to
`{ min, max, currency, period, basis }`, with `basis` set to `base`, `ote` or `total` so a
commission-heavy range never passes for base salary.

### Developer

npm, PyPI, crates.io, RubyGems, Packagist, Hex, JSR, pkg.go.dev, GitHub Gists & commits, GitLab and Forgejo,
Stack Exchange, IETF RFCs, NIST NVD, the Apple App Store and Google Play.

### Research and health

arXiv, PubMed and PMC, DOI and Crossref, OpenAlex, ClinicalTrials.gov, PubChem and openFDA. Set a
contact address in your User-Agent to join the "polite pool" that several of these offer.

### Public records

Socrata, CKAN (including data.gov), ArcGIS REST, Legistar council records and USAspending.

### Finance

SEC EDGAR, Y Combinator and Work at a Startup, and Polymarket.

### AI and archives

Hugging Face model cards, OpenRouter model listings and the Internet Archive.

### Community and commerce

Hacker News, Lobsters, Reddit, Bluesky, Mastodon, Discourse, DEV, MediaWiki sites, Shopify and WooCommerce stores,
and Open Food Facts.

## Missing a site?

[Request an adapter](https://github.com/bartrumb/edgefetch/issues/new/choose) with the extractor
request template, or [write one](/adapters/write/). Each one is a single declarative YAML file.
