---
title: MCP tools
description: The 17 tools EdgeFetch exposes to MCP clients, including federated MCP discovery and encrypted connector execution.
---

An EdgeFetch Hub exposes **17 MCP tools** over `POST /mcp` (and local `edgefetch mcp` over `stdio` exposes the core local extraction, browser, search, jobs, and catalog tools). Tools such as `search_collection`, `agent`, and `query_mcp` use optional hub storage, BYO-LLM keys, or `/admin` vault connectors when configured.

| Tool | What it does |
|---|---|
| `scrape` | Fetch one URL and return clean Markdown (or JSON), routing through any matching connected MCP server first, then declarative YAML adapters, then HTTP/2 or headless Chromium |
| `fetch_url` | Fetch one URL with fewer transforms: status, headers and body |
| `fetch_batch` | Fetch many URLs politely in one call |
| `map` | List a site's URLs from its sitemaps, `/llms.txt` and links, optionally filtered |
| `crawl` | Follow links from a start page within limits you set |
| `extract` | Pull BM25 query-ranked passages or structured fields from 1..20 URLs into JSON |
| `search` | Hybrid web search through D1 FTS5 + Serper, Brave or Tavily keys, or SearXNG for $0 |
| `search_collection` | Full-text search over pages you've already collected (isolated per user on multi-user hubs) |
| `jobs` | Search 16+ ATS job boards or `verify` saved job links with normalised base/OTE/total pay ranges |
| `catalog` | Pull a store's full product & variant inventory (Shopify & WooCommerce) politely with snapshot diffs |
| `interact` | Drive a page in a sandboxed headless browser (`click`, `fill`, `scroll`, `screenshot`) and return what it shows |
| `read_artifact` | Read a stored large result (PDF text, crawl output) in chunks |
| `find_extractors` | Show which of the 56 declarative YAML site adapters would handle a URL |
| `discover_mcps` | Search the Official MCP Registry (`registry.modelcontextprotocol.io`) and Glama for remote MCP servers by keyword or domain |
| `query_mcp` | List or invoke tools on an external MCP server connected in the caller's `/admin` `AES-256-GCM` credential vault |
| `agent` | Multi-step research & schema-validated extraction with your own LLM (OpenAI, Anthropic, Gemini, Ollama and others), including connected MCP tools |
| `list_agents` | Show connected worker nodes, capabilities (`browser-v1`, `pdf-v1`), sandbox posture, and counters |

Every result reports whether the page was **blocked** (by `robots.txt`, `Content-Signal: ai-input=no`, or a challenge), so your
agent can tell "no content" apart from "not allowed". Results fetched via an authenticated MCP connector are tagged `visibility: "private"` so user-authenticated data never enters shared caches.

For parameters and examples, see
[docs/USAGE.md](https://github.com/bartrumb/edgefetch/blob/main/docs/USAGE.md).
