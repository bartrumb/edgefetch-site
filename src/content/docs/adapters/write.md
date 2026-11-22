---
title: Write an adapter
description: Add a new site to EdgeFetch in one declarative YAML manifest and one JSON test fixture.
---

Every built-in adapter (`MIT`-licensed) is a single declarative YAML 1.2 Core manifest in
`internal/extract/manifests/<slug>.yaml` plus one JSON test fixture in `hub/test/fixtures/adapters/<slug>.json`.
Adapters contain zero executable TypeScript or Go code, never call `fetch()`, and compile to
`internal/extract/manifests/compiled.json` so both the Hub and the Go binary run the exact same rules.

## Before you write a manifest

Open `https://<the-site>/robots.txt` and check that `User-agent: *` allows the path you want to
use. This matters more than anything else in the adapter.

Some sites allow their public pages but block their API. For example, `api.smartrecruiters.com`,
`export.arxiv.org`, and Open Food Facts' `/api/` disallow crawlers, while the ordinary web pages
are allowed. For those sites, use `htmlRoutes` to read JSON-LD or CSS selectors out of the allowed
HTML page instead of calling the API.

## 1. Scaffold it

```bash
git clone https://github.com/bartrumb/edgefetch.git
cd edgefetch/hub
npm ci
npm run adapter:new developer/my-registry
```

This scaffolds `internal/extract/manifests/my-registry.yaml` and
`hub/test/fixtures/adapters/my-registry.json`.

Categories are `developer`, `genai`, `jobs`, `finance`, `public-records`, `research-health` and
`commerce-social`.

## 2. Pick the approach

| Use | When |
|---|---|
| `match` + `twin` + `extract` (or `routes`) | The site has a public, `robots.txt`-allowed JSON, Markdown, XML, RSS or `.patch` version of the page. One request, no HTML parsing |
| `htmlRoutes` | The API is blocked by `robots.txt` or doesn't exist, and the public HTML page carries Schema.org JSON-LD or clean CSS-selectable fields |

A JSON twin manifest looks like this:

```yaml
id: rubygems
name: RubyGems Registry
category: developer
description: Upgrades rubygems.org gem pages to /api/v1/gems/<gem>.json metadata.
domains:
  - rubygems.org
  - www.rubygems.org
exampleUrls:
  - https://rubygems.org/gems/rails

match:
  exactSegments: false
  pathSegments:
    - gems
    - param: gem
      charset: pkg
      minLen: 1
      maxLen: 80

twin:
  fetchUrl: https://rubygems.org/api/v1/gems/{gem}.json
  kind: json
  accept: application/json

extract:
  requireFields: [name]
  vars:
    name:
      paths: [name]
    version:
      paths: [version]
    info:
      paths: [info]
      trim: true
  titleTemplate: "{name} {version} (RubyGem)"
  titleWhenVar: version
  titleFallbackTemplate: "{name} (RubyGem)"
  introVar: info
  bullets:
    - label: Install
      template: "`gem install {name}`"
      whenVar: version
```

Whenever required fields are missing or a URL doesn't match, EdgeFetch falls back cleanly to
standard extraction instead of returning a broken result. Any `regexExtract` pattern is validated
and executed with linear-time `RE2`.

## 3. Compile, record or edit the fixture, and test

Compile `compiled.json` and run the adapter test harness (which also checks `< 50 ms` per fixture):

```bash
npm run adapter:compile
npm run adapter:test
npm test
```

## Rules a reviewer will check

- The path is allowed by `robots.txt`, and you checked it on the live site.
- No broad eTLD wildcards (`*`, `*.com`, `*.org`), YAML anchors/aliases, or non-443 ports.
- No API keys, paid services or account logins.
- No CAPTCHA solving, fingerprint spoofing or other ways around a site's defences.
- `npm run adapter:check` and `npm test` pass, and commits carry DCO sign-off (`git commit -s`).

See [docs/ADAPTERS.md](https://github.com/bartrumb/edgefetch/blob/main/docs/ADAPTERS.md) for the full manifest schema reference and [Contributing](/contributing/) for the pull request checklist.
