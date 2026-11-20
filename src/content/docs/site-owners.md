---
title: For website owners
description: What the EdgeFetch user agent is, what it does, and how to block or contact it.
---

If you saw `EdgeFetch` in your logs, here's what it is.

## What it is

EdgeFetch is open-source software that people run themselves to let their AI assistant read a web
page **when they ask it to**. It is not a search-engine crawler, and it isn't used to train AI
models. Because anyone can run it, traffic comes from many operators, not from one company.

## What it always does

- Reads and obeys your `robots.txt`, including on every redirect.
- Honours `Retry-After` on `429` and `503` responses, and limits how fast it hits each host.
- Stops when it sees a CAPTCHA or bot challenge. It doesn't try to get past it.

See [Politeness rules](/concepts/politeness/) for the details.

## How to block it

Add this to your `robots.txt`:

```
User-agent: EdgeFetch
Disallow: /
```

To allow it on part of your site only:

```
User-agent: EdgeFetch
Allow: /docs/
Disallow: /
```

## Verifying a request

Operators can sign requests with RFC 9421 HTTP Message Signatures (Ed25519). A signed request
includes `Signature`, `Signature-Input` and `Signature-Agent` headers. `Signature-Agent` points to
the operator's key directory at `/.well-known/http-message-signatures-directory`. An unsigned
request that only *claims* to be EdgeFetch could come from anyone.

## Contact

- About the software, or to report abusive use of it:
  [bot@edgefetch.dev](mailto:bot@edgefetch.dev) or a
  [GitHub issue](https://github.com/bartrumb/edgefetch/issues).
- About traffic from a particular operator: they are encouraged to put their own contact
  details in the User-Agent, so check the header first.
