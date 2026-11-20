---
title: Connect an MCP client
description: Use EdgeFetch from Claude Code, Claude Desktop, Cursor and other MCP clients.
---

EdgeFetch speaks the [Model Context Protocol](https://modelcontextprotocol.io) in two ways.

## Local `stdio` (recommended for one machine)

The client starts `edgefetch mcp` as a child process. Nothing listens on a port.

```bash
edgefetch install-mcp   # configures Claude Desktop and Cursor
```

For any other client, add a `stdio` server that runs `edgefetch` with the argument `mcp`. In the
common JSON format:

```json
{
  "mcpServers": {
    "edgefetch": {
      "command": "edgefetch",
      "args": ["mcp"]
    }
  }
}
```

For Claude Code:

```bash
claude mcp add edgefetch -- edgefetch mcp
```

## Remote hub over HTTP

A deployed hub serves MCP at `https://<your-hub>/mcp`, using OAuth 2.1 with PKCE or a bearer
token. Point your client at that URL. Dynamic client registration accepts loopback redirect URIs
by default. Allow other hosts with `OAUTH_REDIRECT_ALLOWLIST`.

## Container

The worker image can also run the `stdio` server:

```bash
docker run -i --rm ghcr.io/bartrumb/edgefetch-agent:2.5.5 mcp
```

See the [tools reference](/reference/tools/) for what your agent can call.
