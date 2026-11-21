---
title: Status, licensing and contact
description: Where the EdgeFetch project stands, its open-source worker / fair-source hub licenses, trademarks, and how to get in touch.
---

## Status

EdgeFetch is a young personal project, started in November 2026. It is the only web
and search layer on the author's own three-node fleet (Home Assistant OS, a Windows VM and an
arm64 board). Expect fast changes. Issues and pull requests are triaged weekly.

## License & trademarks

EdgeFetch uses an **open-source worker, SDKs, and adapters / fair-source hub** license split:

- **Open-source worker, CLI, SDKs & all site adapters (`cmd/`, `internal/`, `sdk/`, `extensions/`, `internal/extract/manifests/`, `hub/src/extractors/`):** **[MIT](https://github.com/bartrumb/edgefetch/blob/main/LICENSE)** (and [`hub/src/extractors/LICENSE`](https://github.com/bartrumb/edgefetch/blob/main/hub/src/extractors/LICENSE)).
- **Fair-source hub (`hub/`, excluding `hub/src/extractors/`):** **[FSL-1.1-MIT](https://github.com/bartrumb/edgefetch/blob/main/hub/LICENSE)** (*Functional Source License 1.1, MIT after two years*) — free to read, modify, and self-host personally or internally within your organization; third parties may not offer the Hub as a competing commercial hosted/managed service, and each release converts to `MIT` two years after publication.
- **Inbound contributions:** Inbound = `MIT` + DCO sign-off (`git commit -s`), per [CONTRIBUTING.md](https://github.com/bartrumb/edgefetch/blob/main/CONTRIBUTING.md).

**Trademarks:** **EdgeFetch™** and the EdgeFetch raven logo are trademarks of Brett Bartrum. Neither the MIT License nor the Functional Source License grants permission to use the EdgeFetch name, `edgefetch.dev` domain, or project logos to brand, endorse, or market a third-party product or hosted service.

## Get involved

- [Report a bug or ask for an adapter](https://github.com/bartrumb/edgefetch/issues/new/choose)
- [Read the contributing guide](https://github.com/bartrumb/edgefetch/blob/main/CONTRIBUTING.md)
- [Report a vulnerability privately](https://github.com/bartrumb/edgefetch/security/advisories/new)

## Support the project

EdgeFetch is free and stays free. If it saves you a scraping bill, you can help keep it going:

- **[Sponsor on GitHub](https://github.com/sponsors/bartrumb)**: monthly or one-time, from $5.
  Sponsorship pays for real test hardware, adapter upkeep and time to answer issues.
- **[Get the raven merch](https://merch.edgefetch.dev)**: the robots.txt tee, the raven
  mug and laptop stickers. Every order helps fund the project.

## Contact

[bot@edgefetch.dev](mailto:bot@edgefetch.dev) for anything about the software or the bot.
