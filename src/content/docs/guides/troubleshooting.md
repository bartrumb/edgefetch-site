---
title: Troubleshooting & OpenTelemetry traces
description: Capture sanitized OpenTelemetry traces and diagnostic bundles without leaking tokens.
---

EdgeFetch emits vendor-agnostic W3C `traceparent` headers and OpenTelemetry OTLP/HTTP JSON spans across both the Go worker/CLI and the TypeScript hub.

## One-command diagnostic bundle (`edgefetch bug-report`)

When filing a [GitHub bug report](https://github.com/bartrumb/edgefetch/issues/new?template=bug_report.yml), run:

```bash
# HTTP/2 + SSR extraction trace
edgefetch bug-report https://example.com/docs/page

# Headless Chromium render trace
edgefetch bug-report --render https://example.com/spa-page
```

`edgefetch bug-report` prints a ready-to-paste Markdown block containing:

- OS, CPU architecture, Go runtime, and detected capabilities (`browser-v1`, `pdf-v1`)
- Boolean-only configuration presence (`set (redacted)` vs `unset` — **never** secret values)
- Sanitized URL (credentials, query strings, and `#fragments` stripped)
- W3C `traceparent` + collapsible OTLP/JSON span (`dnsMs`, `connectMs`, `tlsMs`, `ttfbMs`, `robotsMs`, HTTP protocol, WAF vendor, and Markdown length)

## Print OTLP spans locally without a collector

Set `EDGEFETCH_OTEL_STDOUT=1` (or `OTEL_EXPORTER_OTLP_ENDPOINT=stdout`) to write OTLP/JSON span batches to `stderr`:

```bash
EDGEFETCH_OTEL_STDOUT=1 edgefetch scrape https://example.com/docs/page
```

## Export to Grafana Tempo, Jaeger or Honeycomb

Set standard OpenTelemetry environment variables on your hub or worker nodes:

```bash
OTEL_EXPORTER_OTLP_ENDPOINT="https://otel.example.com"
OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer%20<your-ingest-token>"
OTEL_SERVICE_NAME="edgefetch"
```
