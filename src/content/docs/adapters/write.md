---
title: Write an adapter
description: Add a new site to EdgeFetch in one file and one test fixture.
---

Every adapter is one TypeScript file plus one JSON test fixture. It touches no shared engine
code, so adapter pull requests don't conflict with each other.

## Before you write any code

Open `https://<the-site>/robots.txt` and check that `User-agent: *` allows the path you want to
use. This matters more than anything else in the adapter.

Some sites allow their public pages but block their API. For example, `api.smartrecruiters.com`
and `export.arxiv.org` disallow crawlers, while the ordinary job and paper pages are allowed. For
those sites, read the structured data out of the allowed HTML page instead of calling the API.

## 1. Scaffold it

```bash
git clone https://github.com/bartrumb/edgefetch.git
cd edgefetch/hub
npm ci
npm run adapter:new developer/deno-land
```

This creates `hub/src/extractors/providers/developer/deno-land.ts`, creates
`hub/test/fixtures/adapters/deno-land.json`, and registers the adapter in
`providers/index.ts`.

Categories are `developer`, `genai`, `jobs`, `finance`, `public-records`, `research-health` and
`commerce-social`.

## 2. Pick the approach

| Use | When |
|---|---|
| `resolveTwin` | The site has a public, robots.txt-allowed JSON, Markdown, XML, RSS or `.patch` version of the page. One request, no HTML parsing |
| `extractHtml` | The structured version is blocked or doesn't exist, but the HTML page carries JSON-LD, server-rendered state or clean landmarks |

A `resolveTwin` adapter looks like this:

```ts
import { defineAdapter } from '../../types';
import { parseJsonObject } from '../../utils';

export default defineAdapter({
  id: 'my-provider',
  name: 'My Public Registry',
  category: 'developer',
  description: 'Upgrades example.org package pages to their public JSON metadata.',
  domains: ['example.org', 'www.example.org'], // '*.example.org' works too
  exampleUrls: ['https://example.org/pkg/demo'],
  resolveTwin({ parts }) {
    if (parts[0] !== 'pkg' || !parts[1]) return null;
    return {
      id: 'my-provider',
      fetchUrl: `https://example.org/api/v1/pkg/${encodeURIComponent(parts[1])}.json`,
      kind: 'json',
      accept: 'application/json',
      formatTwin: (rawBody) => {
        const data = parseJsonObject(rawBody);
        if (!data || typeof data.name !== 'string') return null;
        return {
          title: data.name,
          markdown: `# ${data.name}\n\n${String(data.summary ?? '')}`,
        };
      },
    };
  },
});
```

Return `null` whenever the page doesn't match or the data looks wrong. EdgeFetch then falls back
to normal extraction instead of returning a broken result. `hub/src/extractors/utils.ts` has
helpers for JSON-LD, Markdown tables and safe code fences.

## 3. Fill in the fixture and test

Edit `hub/test/fixtures/adapters/<slug>.json` with a realistic URL, a sample response and the
Markdown you expect. The test suite discovers every fixture on its own.

```bash
npm run type-check
npm test
```

## Rules a reviewer will check

- The path is allowed by robots.txt, and you checked it on the live site.
- The adapter never calls `fetch()` itself.
- No API keys, paid services or account logins.
- No CAPTCHA solving, fingerprint spoofing or other ways around a site's defences.
- A fixture is included and `npm test` passes.

Then open a pull request. See [Contributing](/contributing/) for the rest of the process.
