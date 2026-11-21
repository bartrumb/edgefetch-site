# edgefetch.dev

Source for [edgefetch.dev](https://edgefetch.dev), the documentation site for
[EdgeFetch](https://github.com/bartrumb/edgefetch), a self-hosted web scraping and search MCP
server for AI agents.

Built with [Astro Starlight](https://starlight.astro.build) and served as static assets from a
Cloudflare Worker.

## Run it locally

```bash
npm install
npm run dev        # http://localhost:4321
```

## Deploy

```bash
npm run deploy     # astro build && wrangler deploy
```

`wrangler.jsonc` attaches the Worker `edgefetch-site` to `edgefetch.dev` and `www.edgefetch.dev`.

## Where things live

| Path | What it is |
|---|---|
| `src/content/docs/` | Every docs page, in Markdown or MDX |
| `src/components/Hero.astro`, `Home.astro` | The custom homepage |
| `src/styles/theme.css` | Brand colours and fonts for Starlight |
| `src/assets/` | Logo artwork |
| `public/` | Favicon, social card, `robots.txt`, `llms.txt`, `.well-known/` |

## Contributing

Fixes to the docs are welcome. Open a pull request against `main`. For changes to EdgeFetch
itself, use the [main repository](https://github.com/bartrumb/edgefetch).

Documentation content in this repository is MIT licensed. EdgeFetch itself uses an open-source worker, SDKs, and adapters (`MIT`) with a fair-source hub (`FSL-1.1`, `MIT` after two years).
