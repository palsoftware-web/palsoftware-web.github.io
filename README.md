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

## Android App Links

`apps/docs/public/.well-known/assetlinks.json` associates pastiera.eu with
Pastiera Stable (`it.palsoftware.pastiera`) and Nightly
(`it.palsoftware.pastiera.nightly`). Astro copies it unchanged to the site root.

The SHA-256 certificate fingerprints come from the app repository's
`signing/lineages/README.md` (2026-09-05 ceremony): each channel includes its
legacy certificate and the A, B and C rotation certificates. These are app
signing certificates, not hardware attestation certificates or APK file hashes.
Local debug certificates are not included. Keep the existing associations when
adding Plektra packages; pkb.rocks is configured separately.

After publishing, check that
`https://pastiera.eu/.well-known/assetlinks.json` returns HTTP 200 directly,
with `Content-Type: application/json` and the expected JSON. On a device with a
matching signed build, request verification:

```sh
adb shell pm verify-app-links --re-verify it.palsoftware.pastiera.nightly
# Allow a few minutes for Android's asynchronous verification.
adb shell pm get-app-links it.palsoftware.pastiera.nightly
```

Expect `pastiera.eu: verified`. Repeat for `it.palsoftware.pastiera` when
testing Stable. Finally open a settings link from another app without forcing
an Android package or activity. Unpublished pkb.rocks verification remains
separate on Android 12 and later; Android 11 and earlier require all declared
hosts to verify.

Reference: [Android App Links verification](https://developer.android.com/training/app-links/verify-applinks).

### Browser fallback for settings links

GitHub Pages serves the custom 404 page for `/settings/<id>`. It recognizes
the app's stable ID format and attempts `pastiera://setting/<id>` once per
page load. A visible, ordinary anchor remains available when the browser blocks
automatic opening. No package is forced, and returning from the app does not
trigger another attempt. Other missing paths remain ordinary error pages.

This supports future setting IDs without maintaining a second registry.
Because GitHub Pages handles it through the error page, the HTTP status remains
404 even when the settings fallback is shown. JavaScript is required to derive
the link from the requested path; the page includes manual instructions without
JavaScript. Test the built `404.html` at the original requested path, as Pages
does, rather than redirecting the browser to `/404.html`.
