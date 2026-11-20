# EdgeFetch brand and merch kit

## The mark

The EdgeFetch logo is a **raven** perched on a circuit-board ledge, the "edge". Ravens are big,
clever birds known for fetching things.

| File | Use |
|---|---|
| `raven-on-navy-1024.png` | The logo on its own navy background (site, social, icons) |
| `raven-transparent.png` | Background removed, for print and for placing on any dark colour |

## Colours and type

| Name | Hex | Use |
|---|---|---|
| Night | `#101C2C` | Backgrounds |
| Signal cyan | `#3FC6E0` | Accents and links |
| Ember amber | `#F2A93B` | Small highlights only |
| Fog | `#9FB0C4` | Secondary text |

Type: **Schibsted Grotesk** ExtraBold for the wordmark, **IBM Plex Mono** for anything that looks
like code. Both are OFL-licensed and included in `fonts/`.

## Merch print files (`merch/`)

All files are 300 dpi PNG.

| File | Size | Product |
|---|---|---|
| `tee-front-dark.png` | 4500 × 5400, transparent | Front chest print, for black, navy or charcoal shirts |
| `tee-back-dark.png` | 4500 × 5400, transparent | Back print: the robots.txt joke |
| `mug-11oz-wrap.png` | 2700 × 1050 | Full wrap for an 11 oz mug (navy all round) |
| `sticker-3in-round.png` | 900 × 900 | 3 inch round die-cut sticker |

These are sized to the usual print-on-demand templates (Printful, Printify, Fourthwall). Upload
the PNG and centre it. The shirt designs are for **dark shirts only**: the raven's body is dark
navy, so on a light shirt it would read as a silhouette with glowing edges.

## Rebuild

```powershell
pwsh brand/scripts/make-merch.ps1 -Raven brand/raven-transparent.png -Out brand/merch
```
