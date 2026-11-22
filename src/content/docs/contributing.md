---
title: Contributing
description: How to help with EdgeFetch, the rules every pull request keeps, and the commands to run before you open one.
---

EdgeFetch combines an **open-source worker, SDKs, and site adapters ([MIT](https://github.com/bartrumb/edgefetch/blob/main/LICENSE))** with a **fair-source hub ([FSL-1.1-MIT](https://github.com/bartrumb/edgefetch/blob/main/hub/LICENSE), MIT after two years)**. Issues and pull requests are triaged weekly. The full guide is
[CONTRIBUTING.md](https://github.com/bartrumb/edgefetch/blob/main/CONTRIBUTING.md), and everyone
follows the [Code of Conduct](https://github.com/bartrumb/edgefetch/blob/main/CODE_OF_CONDUCT.md).

## Where help matters most

- **Adapters.** A new site, job board or open-data portal is one declarative YAML manifest and one JSON fixture. Start
  with [Write an adapter](/adapters/write/).
- **False-positive fixtures.** If EdgeFetch flagged a normal page as a bot challenge, or missed a
  real one, an HTML sample makes the classifier better for everyone
  (`internal/classify/waf_test.go` and `hub/src/waf.ts`).
- **Hardware reports.** Tell us EdgeFetch runs on your router, NAS, Raspberry Pi, FreeBSD box or
  Mac, so a platform can move from "build verified" to "live tested".
- **Docs.** This site lives in [bartrumb/edgefetch-site](https://github.com/bartrumb/edgefetch-site).
  Every page has its source there.

## Rules every pull request keeps

1. **Politeness can't get weaker.** No change may loosen robots.txt handling, `Retry-After` and
   `Crawl-delay`, or the dial-time IP checks.
2. **No ways around site defences (permanently out of scope).** Anti-bot fingerprinting, TLS/HTTP2
   fingerprint spoofing, stealth browser patches, CAPTCHA solvers, and rotating residential proxies
   are permanently out of scope.
3. **Every outbound call has a deadline.** Every network fetch carries a timeout and cancels or
   drains unread bodies; contributed adapters run inside a zero-secret, zero-network bulkhead.
4. **DCO sign-off & contributor vouching.** Sign commits with `git commit -s`; first-time external
   PRs are gated by `.github/VOUCHED.td` before untrusted workflows run.
5. **The supply chain stays small.** The Go module keeps strictly one external dependency (`coder/websocket`), and
   the hub keeps runtime dependencies restricted strictly to small, maintainer-vetted packages (`htmlparser2`, `jose`, `oauth4webapi`, `re2js`, `ws`, `yaml`).
6. **Built-in adapters stay keyless (`MIT`).** All built-in adapters (`internal/extract/manifests/` and `hub/src/extractors/`) are MIT-licensed; paid services belong in operator settings, not in the
   adapter library.
7. **Tests come with changes.** Every fix or adapter includes a fixture or a unit test.
8. **Release files stay out of PRs.** Leave `.github/workflows/release.yml` and `keys/` alone
   unless the maintainer asks.

AI-assisted pull requests are welcome if you've read every line yourself, checked robots.txt on
the live site, and run the tests below.

**Inbound = MIT + DCO (`git commit -s`):** By opening a pull request (whether to the `MIT` worker, SDKs, and adapters or to the `FSL-1.1-MIT` hub), you confirm you have the right to license and do license your contribution inbound under the [MIT License](https://github.com/bartrumb/edgefetch/blob/main/LICENSE) alongside your DCO sign-off. No separate CLA is required.

## Check your work locally

Go worker, CLI and Go hub (Go 1.26 or later):

```bash
gofmt -s -w .
go vet ./...
go test -race ./...
```

TypeScript hub (Node.js 22.5 or later):

```bash
cd hub
npm ci
npm run type-check
npm test
npm run deploy:dry
```

Extraction benchmark:

```bash
node bench/run-bench.mjs
```

## Security issues

Please don't open a public issue. Report privately through
[GitHub Security Advisories](https://github.com/bartrumb/edgefetch/security/advisories/new).
