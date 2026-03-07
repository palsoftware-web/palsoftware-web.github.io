---
title: Common Questions
description: Frequently asked questions from Pastiera users.
---

## Does Pastiera work only on one specific device?

No. The app is built for Android devices with a physical keyboard, but current code and assets explicitly cover more than one device profile. Titan 2 is a long-standing baseline, while Q25 support is newer.

## What practical problems does Pastiera solve?

Mainly these:

- faster text entry on physical-keyboard phones
- easier access to symbols, emoji, clipboard history, and character variants
- better navigation through Nav Mode and shortcuts
- more flexible language and layout switching
- persistent customization through backup and restore

## Where do I change the main typing behavior?

Start with:

- `Settings > Keyboard & Timing`
- `Settings > Smart Features`
- `Settings > Customization`

Those sections cover long press, modifier behavior, Nav Mode, SYM configuration, and daily typing helpers.

## Can long press use variations instead of Alt?

Yes. Set `Settings > Keyboard & Timing > Long Press Modifier` to `Variations`.

That is a good fit if you mostly need accented or alternate characters rather than Alt-driven symbol behavior.

## Is there already support for Vietnamese Telex?

Yes. Current builds include a dedicated Vietnamese Telex layout mode. Set it up from `Settings > Languages and Maps`.

## Are the SYM pages fully configurable now?

Mostly yes. You can enable or disable SYM pages, reorder them, include clipboard, include the full emoji picker, and change auto-close behavior from `Settings > Customization > Customize SYM Keyboard`.

## Is there a QWERTZ multi-tap option for umlauts and sharp s?

Yes. The current layout assets include `German (QWERTZ, multi-tap)` with multi-tap access for `ä`, `ö`, `ü`, and `ß`.

## Why do multi-tap characters sometimes feel harder when I type very fast?

Because multi-tap is timing-based input. If you switch to a multi-tap-heavy layout, there is usually a short adaptation period until your rhythm matches the layout behavior.

## Why do suggestions work better in some languages than in others?

Suggestions depend on the language resources available for the active locale. A layout can be available even when dictionary-backed suggestions are limited or absent.

## Why is clipboard history empty?

First check:

1. that the clipboard page is enabled in SYM customization
2. that you actually copied text in the current session
3. whether Android or your device vendor restricts clipboard visibility

## Is the emoji search online?

No. The current emoji search uses bundled local assets and works offline.

## What is Pastierina mode?

It is the smaller, more minimal Pastiera UI. You can choose it by disabling the on-screen keyboard part of the IME while still using Pastiera as the active input method.

## Should I use nightly builds?

Only if you want newer changes sooner and are comfortable with occasional instability. Back up your setup first.

## What changed since 0.84 beta?

The main user-facing additions after `v0.84beta` include Vietnamese Telex, emoji search in both pickers, German QWERTZ multi-tap, Greek multi-tap improvements, Q25 support, stronger accessibility controls, and deeper SYM/variation customization.
