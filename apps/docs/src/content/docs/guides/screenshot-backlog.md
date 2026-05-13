---
title: Screenshot Backlog
description: Open screenshot tasks with locale coverage and English fallback strategy.
---

Last reviewed: 2026-03-06

## Policy

- Primary screenshot language files:
  - `/showcase/screenshots/<build_id>/en/<id>.png`
  - `/showcase/screenshots/<build_id>/de/<id>.png`
- Runtime behavior in docs:
  - Resolve active build from `/showcase/screenshots/manifest.json` (`latestBuild`)
  - Tries current docs locale first
  - Falls back to English if locale-specific screenshot is missing

## Capture command

```bash
npm run docs:screenshots:capture -- \
  --avd Pastiera_API_36 \
  --pastiera-repo ~/gits/GitHub/pastiera \
  --locale en-US \
  --locale de-DE
```

Default capture resolution: `1440x1440`.
If `--apk` is omitted, the script auto-builds from `--pastiera-repo`.
Locale capture uses one emulator restart per locale with boot locale props.

## Open screenshot tasks

| ID | Used in page | en | de | Status |
| --- | --- | --- | --- | --- |
| `emoji-search-inline` | `/guides/emoji-search/` | open | open | Open |
| `clipboard-history-panel` | `/guides/clipboard-history/` | open | open | Open |
| `vietnamese-telex-layout` | `/guides/vietnamese-telex/` | open | open | Open |
| `device-profile-q25` | `/guides/device-profiles/` | open | open | Open |
| `sym-variations-overview` | `/guides/sym-and-variations/` | open | open | Open |

## Capture conventions

1. Use consistent device orientation per page (portrait unless there is a clear reason otherwise).
2. Keep overlays and private content removed from screenshots.
3. Prefer same UI state across locales so diffs are language-only.
4. Commit screenshots with stable filenames and update this table.
