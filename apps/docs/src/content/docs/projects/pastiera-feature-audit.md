---
title: Pastiera Feature Audit
description: Local inventory of Pastiera features vs current documentation coverage.
---

Audit snapshot date: March 6, 2026

Reference repository: `palsoftware/pastiera`

## Method

- Sources used:
  - Pastiera `README.md` and `docs/*.md`
  - Closed issues and merged PRs via GitHub CLI
  - Issue comments where implementation references were provided
- "Last documented" is a best-effort date from `git log` on documentation files.
- This page is intentionally pragmatic: it is a tracking baseline, not an architecture spec.

## Inventory

| Feature cluster | Advertised in public docs | Dedicated doc exists | Last documented (best guess) | Recent implementation evidence | Assessment |
| --- | --- | --- | --- | --- | --- |
| Backup/restore (manual + auto) | Yes (`README`) | Yes (`docs/backup_system.md`) | 2026-01-28 | [Issue #16](https://github.com/palsoftware/pastiera/issues/16) (historic request) | Good coverage, keep fresh with schema changes |
| Launcher + power shortcuts | Yes (`README`) | Yes (`docs/LAUNCHER_SHORTCUTS.md`) | 2025-11-23 | [Commit ce690c5](https://github.com/palsoftware/pastiera/commit/ce690c5) era noted in docs history | Likely stale for recent UX/settings changes |
| Dictionary/autocorrect pipeline | Yes (`README`) | Yes (`docs/dictionary_autocorrect.md`) | 2025-11-23 | [PR #26](https://github.com/palsoftware/pastiera/pull/26), [PR #76](https://github.com/palsoftware/pastiera/pull/76) | Core doc exists but probably outdated after Dec/Feb changes |
| Online layouts repository/import | Partly | Yes (`docs/online-dicts_layouts.md`) | 2026-01-23 | [Commit fabf959](https://github.com/palsoftware/pastiera/commit/fabf959) | Good technical detail, needs user-facing quickstart |
| Custom dictionary workflow | Partly | Yes (`docs/custom_dictionary_guide.md`) | 2026-02-22 | [Commit 7ff17a6](https://github.com/palsoftware/pastiera/commit/7ff17a6) | Fresh, solid |
| Status bar button system | Not directly in README | Yes (`docs/status_bar_buttons.md`) | 2026-01-13 | [Commit 30fd8b7](https://github.com/palsoftware/pastiera/commit/30fd8b7) | Internal-focused; add user map to settings labels |
| Hamburger menu overlay | Not directly in README | Yes (`docs/hamburger_menu.md`) | 2026-01-16 | [Commit 1ca1e6d](https://github.com/palsoftware/pastiera/commit/1ca1e6d) | Reasonable, but tightly implementation-oriented |
| Clipboard history | Yes (`README`) | No dedicated page | README last changed 2026-02-25 | [PR #68](https://github.com/palsoftware/pastiera/pull/68), [Issue #52](https://github.com/palsoftware/pastiera/issues/52), [Issue #77](https://github.com/palsoftware/pastiera/issues/77) | Missing dedicated user/admin documentation |
| Emoji search (both pickers) | Not clearly | No dedicated page | README last changed 2026-02-25 | [PR #141](https://github.com/palsoftware/pastiera/pull/141), [Issue #37](https://github.com/palsoftware/pastiera/issues/37) | New feature, undocumented in dedicated docs |
| SYM custom unicode / picker behavior | Partly | No dedicated page | README last changed 2026-02-25 | [Issue #27](https://github.com/palsoftware/pastiera/issues/27), [Issue #127](https://github.com/palsoftware/pastiera/issues/127) | Needs explicit behavior matrix + settings doc |
| Vietnamese Telex support | No | No dedicated page | n/a | [Issue #43](https://github.com/palsoftware/pastiera/issues/43), [PR #144](https://github.com/palsoftware/pastiera/pull/144) | Implemented recently, high-priority doc gap |
| Greek accented vowel multitap | No | No dedicated page | n/a | [Issue #30](https://github.com/palsoftware/pastiera/issues/30), [PR #143](https://github.com/palsoftware/pastiera/pull/143) | Implemented, not discoverable via docs |
| German multitap layout | No | No dedicated page | n/a | [PR #142](https://github.com/palsoftware/pastiera/pull/142) | Implemented, not documented |
| Ukrainian layout support | Partly (generic layout mention) | No dedicated page | README last changed 2026-02-25 | [PR #105](https://github.com/palsoftware/pastiera/pull/105) | No locale-specific docs |
| Serbian Cyrillic layout support | Partly (generic layout mention) | No dedicated page | README last changed 2026-02-25 | [PR #130](https://github.com/palsoftware/pastiera/pull/130) | No locale-specific docs |
| Q25 device support | No | No dedicated page | n/a | [PR #146](https://github.com/palsoftware/pastiera/pull/146), [Issue #149](https://github.com/palsoftware/pastiera/issues/149) context | Very recent; should be documented first for new users |
| Accessibility (layout announcement) | No | No dedicated page | n/a | [Issue #118](https://github.com/palsoftware/pastiera/issues/118) | Likely implemented but not documented |

## Priority gaps

1. New features shipped in Feb-Mar 2026 without dedicated docs: emoji search, Telex, Q25 support, recent layout additions.
2. High-usage features lack standalone docs: clipboard history, SYM behavior and customization matrix.
3. Existing docs are skewed toward implementation internals; we still need user-facing "how to use" pages.

## Tracking notes

- Closed enhancement issues are not always linked via "Fixes #..."; comments and PR references were needed for mapping.
- Some issue closures represent roadmap/triage closure, not completion (example: older feature-request style issues).
- Keep this file updated on each feature merge touching UX behavior or settings.
