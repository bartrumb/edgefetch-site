---
title: MCP tools
description: The tools EdgeFetch exposes to MCP clients.
---

A hub exposes these 14 tools. Some, such as `search_collection` and `agent`, need hub storage or an LLM key you configure.

| Tool | What it does |
|---|---|
| `scrape` | Fetch one URL and return clean Markdown (or JSON), rendering JavaScript when needed |
| `fetch_url` | Fetch one URL with fewer transforms: status, headers and body |
| `fetch_batch` | Fetch many URLs in one call |
| `map` | List a site's URLs from its sitemaps and links, optionally filtered |
| `crawl` | Follow links from a start page within limits you set |
| `extract` | Pull structured fields from a page into JSON |
| `search` | Web search through your own Serper, Brave or Tavily keys, or SearXNG for $0 |
| `search_collection` | Full-text search over pages you've already collected |
| `jobs` | Search ATS job boards and return postings with normalised pay ranges |
| `interact` | Drive a page in the browser (click, type, scroll) and return what it shows |
| `read_artifact` | Read a stored large result (PDF text, crawl output) in chunks |
| `find_extractors` | Show which site adapter would handle a URL |
| `agent` | Multi-step research with your own LLM (OpenAI, Anthropic, Gemini, Ollama and others) |
| `list_agents` | Show connected worker nodes and what each can do |

Every result reports whether the page was **blocked** (by `robots.txt` or a challenge), so your
agent can tell "no content" apart from "not allowed".

For parameters and examples, see
[docs/USAGE.md](https://github.com/bartrumb/edgefetch/blob/main/docs/USAGE.md).
