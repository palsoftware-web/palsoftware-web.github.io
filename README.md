# Pastiera Web Docs

This repository hosts the public website/docs for Pastiera at `https://pastiera.eu`.

The Android app source is maintained in a separate repository:
- `https://github.com/palsoftware/pastiera`

## Repository focus

- Public project overview and feature documentation
- Screenshot-based guides (locale-aware with English fallback)
- GitHub Pages deployment

## Structure

- `apps/docs` - Astro Starlight site
- `.github/workflows/docs-pages.yml` - GitHub Pages build/deploy workflow

## Local commands

```bash
npm install
npm run docs:dev
npm run docs:build
```

## Screenshot pipelines

Maestro tutorial smoke flow:

```bash
apps/docs/scripts/run-maestro-tutorial-flow.sh \
  --avd Pastiera_API_36 \
  --pastiera-repo ~/gits/GitHub/pastiera
```

To render the same flow as a local video:

```bash
apps/docs/scripts/run-maestro-tutorial-flow.sh \
  --avd Pastiera_API_36 \
  --record apps/docs/public/showcase/tutorials/tutorial-onboarding.mp4
```

Install Maestro locally first with:

```bash
curl -fsSL "https://get.maestro.mobile.dev" | bash
```

Static mockup generator:

```bash
npm run docs:images
```

Emulator capture pipeline (build + locale aware):

```bash
npm run docs:screenshots:capture -- \
  --avd Pastiera_API_36 \
  --pastiera-repo ~/gits/GitHub/pastiera \
  --locale en-US \
  --locale de-DE \
  --show-emulator \
  --verbose
```

Default capture resolution is `1440x1440`. Override with `--width` and `--height` if needed.
If `--apk` is omitted, the script builds `:app:assembleDebug` automatically from `--pastiera-repo`.
Locale handling is done by restarting emulator per locale with boot props (no runtime `setprop` dependency).
The capture runner also performs best-effort IME activation and dialog/onboarding dismissal before scene capture.

Captured screenshots and build mapping are stored in:
- `apps/docs/public/showcase/screenshots/<build_id>/<locale>/`
- `apps/docs/public/showcase/screenshots/manifest.json`
