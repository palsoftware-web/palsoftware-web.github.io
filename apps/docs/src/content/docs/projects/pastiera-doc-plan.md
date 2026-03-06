---
title: Pastiera Documentation Plan
description: Execution plan for keeping Pastiera docs accurate and maintainable.
---

Plan baseline date: March 6, 2026

## Goals

- Keep docs usable for both end users and contributors.
- Ensure every advertised feature has a canonical page.
- Track documentation freshness against actual feature changes.

## Documentation model

- `README.md` in reference repo:
  - Product summary
  - Install + requirements
  - Link hub to full docs
- Feature pages (this docs site):
  - User behavior and settings
  - Known limitations
  - Source links (issue/PR/commit)
- Developer pages:
  - Architecture notes
  - Data/storage format and migration notes
  - Test strategy and validation steps

## Work plan

1. Phase 1 (immediate, high impact)
   - Add pages for:
     - Emoji search (settings picker + inline picker behavior)
     - Clipboard history
     - Telex input mode
     - Device support (start with Q25 + Titan2 notes)
   - Update `README.md` feature list to include new capabilities explicitly.
2. Phase 2 (consistency and discoverability)
   - Add "Layouts and language packs" page:
     - shipped layouts
     - locale coverage
     - import/export/online flows
   - Add "SYM and variations behavior matrix" page:
     - key press/release behavior
     - lock states
     - customization points
3. Phase 3 (maintenance automation)
   - Add a lightweight checklist in PR template:
     - "Docs updated?" with link to changed page
   - Add monthly audit pass:
     - compare merged PR titles vs docs pages
     - update freshness table in feature audit

## Definition of done for each feature page

- Includes user-facing "how to use" steps.
- Includes settings path names as seen in app UI.
- Includes at least one screenshot or visual.
- Links to implementation evidence:
  - issue
  - PR
  - key commit(s)
- Includes "last reviewed" date in page frontmatter or footer.

## Suggested ownership

- Feature author updates docs in same PR whenever possible.
- Maintainer performs a monthly docs freshness sweep.
- Community contributors can open docs-only PRs tied to closed issues.

## First backlog to execute

1. [Emoji Search](/guides/emoji-search/)
2. [Clipboard History](/guides/clipboard-history/)
3. [Vietnamese Telex](/guides/vietnamese-telex/)
4. [Device Profiles](/guides/device-profiles/)
5. [SYM and Variations](/guides/sym-and-variations/)

Supporting tracker:
- [Screenshot Backlog](/guides/screenshot-backlog/)
