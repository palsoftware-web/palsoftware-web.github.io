---
title: Screenshot Backlog
description: Open screenshot tasks with locale coverage and English fallback strategy.
---

Last reviewed: 2026-03-06

## Policy

- Primary screenshot language files:
  - `/showcase/screenshots/en/<id>.png`
  - `/showcase/screenshots/de/<id>.png`
- Runtime behavior in docs:
  - Tries current docs locale first
  - Falls back to English if locale-specific screenshot is missing

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
