---
title: Release Channels
description: Stable, nightly, and deployment-facing release notes for maintainers and advanced testers.
---

## Stable versus nightly

Pastiera currently distinguishes between stable and nightly release flows.

- stable is the normal public channel
- nightly is for newer pre-release builds and faster verification

## Nightly surfaces

The project currently publishes or references nightly builds through:

- GitHub nightly releases
- the Pages-hosted nightly F-Droid repository

These are operational surfaces, not part of the core user documentation.

## Update behavior

Update-check behavior differs by build flavor and release channel. Some builds can check GitHub directly, while F-Droid-oriented flows may deliberately avoid that and rely on repository updates instead.

## Signing and trust material

Signing attestations and release-channel trust material belong to the upstream project documentation in the app repository and related operational pages. Keep them separate from normal feature docs so the user path stays focused on the app itself.

## Maintainer note

When release behavior changes, update this page and the internal project pages together so channel details stay synchronized with the actual build setup.
