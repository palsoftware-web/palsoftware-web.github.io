---
title: Pastiera Feature Matrix
description: Inventory of Pastiera features, docs, media, and candidate Maestro scenarios.
---

Snapshot date: 2026-05-23

Reference repositories:

- App: `palsoftware/pastiera`
- Docs/site: `palsoftware/palsoftware-web`

## Purpose

This matrix is a working inventory for tutorial scenarios that should serve three jobs at once:

- feature showcase
- user-facing how-to path
- repeatable E2E/Maestro coverage

Statuses are intentionally pragmatic. `covered by unit/e2e? unknown` means the code or docs imply the feature, but this pass did not prove end-to-end coverage.

## Source Notes

Primary sources checked:

- Pastiera `README.md`
- Pastiera app code under `app/src/main/java`
- Pastiera assets under `app/src/main/assets/common` and `app/src/main/assets/devices`
- Pastiera local docs under `docs/*.md`
- Pastiera unit tests under `app/src/test/java`
- Current docs pages under `apps/docs/src/content/docs`
- Current docs screenshot and Maestro assets under `apps/docs/e2e`, `apps/docs/scripts`, and `apps/docs/public/showcase/screenshots`

## Feature Matrix

| Area | Feature | User value | Key settings / entry points | Existing docs | Existing automated coverage | Suggested Maestro scenario | Media status | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Onboarding | IME setup and first typing flow | Helps users enable Pastiera, select it, and verify that the physical keyboard path works | Android input method picker; Pastiera settings; `TutorialActivity`; `ImeTestScreen` | `guides/getting-started`, localized variants | `apps/docs/e2e/maestro/tutorial-onboarding.yaml`; app-side instrumentation only sample/unknown | Full first-run setup: open settings, enable IME, switch IME, type sample text, return to docs/tutorial state | needs media beyond current quick-check; existing `quick-check.png` only | P0 |
| Typing core | Physical keyboard input, modifiers, punctuation, auto-space | Core promise: make hardware typing fast and predictable | `Settings > Keyboard & Timing`; `SettingsManager`; `InputEventRouter`; `TextInputController` | `guides/typing-and-navigation`; README | Unit coverage: `TextInputControllerTest`, `InputEventRouterModifierE2ETest`, `PunctuationTest`, `ModifierStateControllerTest` | Type sentence with Shift, Alt, punctuation, backspace, enter; assert text output and status changes | needs scenario media | P0 |
| Long press | Long-press behavior and timing | Lets users choose whether hold actions mean Alt, SYM, variations, etc. | `Settings > Keyboard & Timing`; `Long Press Modifier`; `Long Press Duration`; `KeyboardTimingSettingsScreen` | `guides/typing-and-navigation`, FAQ; localized docs mention it | Unit coverage likely indirect via router/timing tests; covered by unit/e2e? unknown | Change long-press mode to variations, hold a letter, select alternate character | needs media | P0 |
| Variations | Character variations, including German umlauts / ß and accent variants | Makes accents and alternate letters available from a physical keyboard | `Settings > Customization > Customize Variations`; `VariationCustomizationScreen`; `VariationButtonHandler`; assets `common/variations/*.json` | `guides/sym-and-variations`; README; partial FAQ | Unit coverage: `VariationRepositoryLayoutOverrideTest`; UI/E2E unknown | German setup: choose QWERTZ multitap or variations, produce `ä`, `ö`, `ü`, `ß`, show variation bar | `SCREENSHOT_TODO: sym-pages-and-variations`; no committed matching screenshot | P0 |
| Static variation bar | Fixed symbol/number rows and layer behavior | Gives power users predictable utility keys without context switching | `StatusBarButtonsScreen`; `static_variation_*` settings; `VariationBarView` | Partial in `guides/sym-and-variations`; README mentions optional static bar | covered by unit/e2e? unknown | Toggle static symbols row, type brackets/numbers from row, verify sticky layer behavior | needs media | P1 |
| SYM pages | Reorderable symbol/emoji pages, touch and physical-key use | Turns the SYM key into a configurable layer system | `Settings > Customization > Customize SYM Keyboard`; `SymCustomizationScreen`; assets `common/sym/*.json` | `guides/sym-and-variations`; README; local `docs/status_bar_buttons.md` is developer-focused | Unit coverage: `SymLayoutController` not obviously covered; covered by unit/e2e? unknown | Open SYM, switch pages, enter symbol, verify optional auto-close | `screenshot-scenes.json` has `sym-variations-overview`, but screenshot open | P0 |
| Emoji | Emoji page, full emoji picker, recent/search data | Fast offline emoji insertion without leaving keyboard flow | SYM page; status bar emoji button; `EmojiPickerDialog`; `EmojiPickerView`; assets `common/emoji`, `common/emoji_search/*.tsv` | `guides/sym-and-variations`; FAQ says search is offline; no dedicated emoji-search page | Repository/data coverage unknown; UI/E2E unknown | Open emoji search, search localized term, insert emoji, verify recent emoji | Existing `emoji-search-inline.png`; scene exists | P0 |
| Clipboard | Clipboard history panel and status bar count | Reuse recent clipboard entries from the keyboard surface | SYM clipboard page; status bar clipboard button; `ClipboardHistoryManager`; `ClipboardHistoryPopupView`; `ClipboardDatabase` | Mentioned in `guides/sym-and-variations`, FAQ; no dedicated clipboard page | covered by unit/e2e? unknown | Copy two strings, open clipboard history, paste one, verify count/state | `screenshot-scenes.json` has `clipboard-history-panel`, but screenshot open | P0 |
| Status bar | Status bar customization and button slots | Lets users keep frequent tools visible and hide noise | `Settings > Customization > Status Bar Buttons`; `StatusBarButtonsScreen`; button factories | User docs partial; local `docs/status_bar_buttons.md` is developer-focused | covered by unit/e2e? unknown | Configure left/right slots: clipboard, emoji, symbols, language; verify status bar preview and IME bar | needs media | P1 |
| Navigation | Nav Mode | Hardware navigation/editing without touching screen | Double-tap Ctrl outside text fields; `Settings > Customization > Nav Mode`; `NavModeSettingsScreen`; `NavModeHandler` | `guides/typing-and-navigation`; README | Unit coverage: `InputEventRouterCtrlHoldNavModeTest`, `TextSelectionHelperWordNavigationTest` | Activate Nav Mode, move cursor with ESDF/IJKL, exit mode, verify LED/status | needs media | P0 |
| Navigation | Ctrl shortcuts and delete alternatives | Faster editing commands for selected apps/contexts | `Settings > Customization > Nav Mode`; layout-aware Ctrl setting; `ctrl_key_mappings.json` | Partial in `guides/typing-and-navigation`; README note distinguishes Ctrl hold from Nav Mode | Unit coverage: `InputEventRouterShortcutKeysTest`, `InputEventRouterForwardDeleteAlternativesTest`, `SettingsManagerLayoutSwitchTest` | Hold Ctrl + key for select/delete/cursor action, compare with latched Nav Mode behavior | needs media | P1 |
| Launcher | Launcher shortcuts and QuickLauncher | Open assigned apps quickly from launcher or keyboard shortcut | Launcher context; SYM power shortcuts; `QuickLauncherActivity`; `LauncherShortcutsScreen`; `LauncherShortcutController` | README; local `docs/LAUNCHER_SHORTCUTS.md`; partial `guides/typing-and-navigation` | covered by unit/e2e? unknown | Assign app to letter, open from launcher; open QuickLauncher from shortcut key, launch app | needs docs refresh; needs media | P0 |
| Launcher | Power shortcuts | Use shortcut assignments outside launcher after SYM activation | SYM then letter; `LauncherShortcutController`; `LauncherShortcutAssignmentActivity` | README; local `docs/LAUNCHER_SHORTCUTS.md` | covered by unit/e2e? unknown | Press SYM, press assigned letter in non-launcher context, verify target app opens | needs media | P1 |
| App-specific behavior | Messenger Enter behavior / app overrides | Makes Enter send/newline behavior fit chat apps and per-app expectations | `AppEnterBehaviorScreen`; `AppPickerDialog`; settings in `SettingsManager` | needs docs | covered by unit/e2e? unknown | Add override for a messenger package, type message, press Enter, verify configured send/newline behavior | needs media | P0 |
| Text expansion | Text Expander / substitutions / auto-corrections | Expands or corrects common text patterns while typing | `AutoCorrectSettingsScreen`; `AutoCorrectEditScreen`; assets `common/autocorrect/auto_corrections_*.json`; user dictionaries | `guides/suggestions-and-dictionaries`; local `docs/dictionary_autocorrect.md`; README | Unit coverage: `AutoReplaceControllerLogicTest`, `AutoCorrectionManager` likely indirect | Enable substitution set, type trigger, press space/enter, verify replacement and undo path if available | needs media | P0 |
| Suggestions | Dictionaries, suggestions, autocorrect | Better typing through suggestions, user dictionary, and locale dictionaries | `Settings > Text Input`; `AutoCorrectSettingsScreen`; `InstalledDictionariesActivity`; assets dictionaries and serialized dictionaries | `guides/suggestions-and-dictionaries`; local `docs/dictionary_autocorrect.md`, `custom_dictionary_guide.md` | Unit coverage: `SuggestionEngineTest`, `DictionaryRepositoryTest`, `SymSpellTest`, `CurrentWordTrackerTest`, `CasingHelperTest`, `WordNormalizationTest` | Type misspelled word, show suggestions, accept correction, add custom word, verify future suggestion | needs media | P0 |
| Languages/layouts | Built-in layouts and language switching | Adapts physical keyboard output to language/user expectations | `Settings > Languages and Maps`; `LanguagesScreen`; `KeyboardLayoutSettingsScreen`; assets `common/layouts/*.json`; `locale_layout_mapping.json` | `guides/languages-and-layouts`; local `docs/online-dicts_layouts.md`; README | Unit coverage: `AdditionalSubtypeUtilsLayoutTest`, `SettingsManagerLayoutSwitchTest`, `KeyMappingLoaderTest` | Enable two layouts, switch from status bar, type language-specific keys | `SCREENSHOT_TODO: languages-and-layouts-input-styles`; needs media | P0 |
| Languages/layouts | German QWERTZ multitap and umlauts | Direct German typing on compact physical keyboards | `german_multitap_qwertz.json`; layout selection; multi-tap timing | FAQ and recipes mention it; no dedicated scenario | Unit coverage: `MultiTapControllerTest`; layout-specific output coverage unknown | Select German multitap layout, press multi-tap sequences for `ä`, `ö`, `ü`, `ß` | needs media | P0 |
| Languages/layouts | Vietnamese Telex | Native Vietnamese input from physical keyboard | `vietnamese_telex_qwerty.json`; `VietnameseTelexProcessor`; layout selection | `guides/languages-and-layouts`; recipes mention it; no dedicated page despite backlog | Unit coverage: `VietnameseTelexProcessorTest` | Select Telex layout, type Telex sequence, assert composed Vietnamese output | `screenshot-scenes.json` has `vietnamese-telex-layout`, but screenshot open | P0 |
| Languages/layouts | Greek, Cyrillic, Arabic, Ukrainian, Serbian, Turkish, Norwegian, Bulgarian, Armenian, Russian layouts | Broad language support and transliteration options | Layout assets under `common/layouts`; language/subtype settings | `guides/languages-and-layouts`; FAQ; no per-locale docs | Unit coverage partial via layout loader/subtype tests | Cycle through representative non-Latin layout, type sample, switch back | needs media | P1 |
| Device support | Device profiles and physical key maps | Makes hardware differences manageable across Titan 2, Q25, Key2, MP01, etc. | `Settings > Device Profile` or advanced settings; `DeviceSpecific`; assets `devices/*/alt_key_mappings.json` | `guides/device-profiles`; device archive docs; README | Unit coverage: `DeviceSpecificTest`, `PhysicalKeyboardInputMethodServiceDeviceBehaviorTest`, `KeyMappingLoaderTest` | Select/auto-detect profile, verify Alt/SYM mapping differs by profile | `screenshot-scenes.json` has `device-profile-q25`, but screenshot open | P0 |
| Device support | Device archive/debug capture | Records real device key behavior for future profile work | `docs/device-archives`; `DebugCaptureStore`; `TrackpadDebugActivity` | Pastiera local `docs/device-archives/*`; not user-facing docs | covered by unit/e2e? unknown | Developer-only scenario: capture key archive and export JSON | needs docs decision; media optional | P2 |
| Backup/data | Manual backup and restore ZIP | Lets users migrate or recover complex customization | `Settings > Advanced > Backup/Restore`; `BackupManager`; `RestoreManager`; `BackupContract` | `guides/backup-and-updates`; local `docs/backup_system.md`; README | Unit coverage: `RestoreManagerAndBackupContractTest`, `RestoreManagerIntegrationTest` | Change setting/layout, create backup, reset/change value, restore, verify setting and custom map | `SCREENSHOT_TODO: backup-and-updates-advanced-settings`; needs media | P0 |
| Backup/data | Android Auto Backup | Passive migration through Android backup where supported | Android backup rules; `backup_rules.xml`, `data_extraction_rules.xml` | README mentions it; local `docs/backup_system.md` likely technical | covered by unit/e2e? unknown | Usually not a Maestro target; document constraints and manual verification checklist | needs docs clarity | P2 |
| Updates/releases | GitHub stable/nightly update flow and F-Droid nightly differences | Helps users choose update channel and avoid surprises | Settings update check; `UpdateChecker`; `UpdatePolicy`; `UpdateCheckWorker`; public F-Droid repo | `guides/backup-and-updates`; `developer/release-channels`; README; release public JSON | Unit coverage: `UpdateCheckerFlavorLogicTest`, `FlavorBuildConfigTest` | Mock/no-network friendly scenario: open About/Advanced update state and ignored release UI | needs media; network-dependent behavior needs test strategy | P1 |
| Sounds | Typing sounds and custom soundpacks | Tactile/audio feedback with optional custom packs | `TypingSoundSettingsRow`; `TypingSoundPlayer`; raw sound assets; soundpack import | `guides/typing-soundpacks`; localized variants | covered by unit/e2e? unknown | Enable sound, choose bundled/custom pack, verify setting persists; audio assertion probably manual | needs media, not necessarily audio capture | P1 |
| Accessibility | Accessibility settings and TalkBack/layout announcements | Makes keyboard status and layout changes understandable with screen readers | `AccessibilitySettingsScreen`; resource strings; IME status/layout announcements | FAQ/audit mention; no dedicated accessibility page | covered by unit/e2e? unknown | Enable accessibility option, switch layout/status, verify content descriptions via UIAutomator dump or manual TalkBack checklist | needs docs and media | P0 |
| Virtual keyboard | Virtual keyboard / compact Pastierina mode | Controls whether Pastiera shows an on-screen keyboard surface or compact status-only UI | IME selector; `SoftwareKeyboardAutoDetector`; `KeyboardVisibilityController`; `AospKeyboardView` | README mentions on-screen keyboard disabled/Pastierina; partial docs | Unit coverage: `SoftwareKeyboardAutoDetectorTest`, `AospKeyboardViewTest` | Toggle/show software keyboard mode, verify compact status bar and physical typing still works | needs docs and media | P1 |
| Trackpad/gestures | Swipe bar and trackpad gestures | Cursor movement and touchpad-like control from keyboard area/device | `Settings > Advanced`; `TrackpadGestureSettingsScreen`; `TrackpadGestureDetector`; `TrackpadEventDeviceResolver` | `guides/typing-and-navigation` mentions swipe movement; no dedicated trackpad guide | Unit coverage: `TrackpadEventDeviceResolverTest`; detector E2E unknown | Use swipe bar to move cursor; verify sensitivity setting changes movement | needs media | P1 |
| Speech | Microphone / speech recognition | Voice input from status bar button | status bar microphone button; `SpeechRecognitionActivity`; `SpeechRecognitionManager` | likely needs docs | Unit coverage: `SpeechRecognitionManagerLanguageTagTest` | Tap mic, permission flow, return recognized text; may need mocked/manual scenario | needs docs and media | P2 |
| UI localization | App UI translations | Makes settings usable in multiple languages | Android resources `values-*`; `AppLocaleManager`; localized docs | Localized docs exist for de/it plus root English; app strings for several locales | covered by unit/e2e? unknown | Switch app locale, verify major settings labels and docs links | needs media if showcased | P2 |
| Customization files | JSON import/export for layouts, variations, SYM/Ctrl maps | Power-user control and recoverable configuration | Files under app `files/`; in-app import/export screens; external key editor link | README; `guides/languages-and-layouts`; local layout/dictionary docs | Unit coverage: layout/mapping loader tests; E2E unknown | Import a small custom layout or variation JSON, type key, export/backup | needs docs refresh and media | P1 |

## Current Media Inventory

| Media/scenario id | Current status | Notes |
| --- | --- | --- |
| `emoji-search-inline` | partial media exists | Existing screenshots under `public/showcase/screenshots/local-1d159ac-*`; likely usable as seed, but page still has screenshot TODOs. |
| `clipboard-history-panel` | needs media | Scene exists in `screenshot-scenes.json`; no committed screenshot found. |
| `vietnamese-telex-layout` | needs media | Scene exists; no committed screenshot found. |
| `device-profile-q25` | needs media | Scene exists; no committed screenshot found. |
| `sym-variations-overview` | needs media | Scene exists; no committed screenshot found. |
| `quick-check` | partial media exists | One English quick-check screenshot exists; not enough for feature showcase. |

## Highest-Value Scenario Backlog

1. **Typing baseline**: setup, type physical-key sample, Shift/Alt/SYM status, punctuation, backspace, enter.
2. **German physical keyboard**: select QWERTZ/multitap, produce umlauts and `ß`, show variations/long-press alternative.
3. **SYM + emoji + clipboard**: configure page order, open SYM, search emoji, paste clipboard entry, auto-close behavior.
4. **Suggestions/substitutions**: enable suggestions, trigger substitution/autocorrect, add word to user dictionary.
5. **Navigation**: demonstrate Ctrl hold shortcut vs double-tap Ctrl Nav Mode and cursor movement.
6. **Device profile**: choose/auto-detect Q25 or Titan 2 profile, show profile-sensitive Alt/SYM behavior.
7. **Backup/restore**: create customization, back up, restore, verify settings/layout/symbol mappings survived.
8. **App override**: configure Messenger Enter behavior for a known package and verify send/newline behavior.
9. **Accessibility**: verify TalkBack-facing labels/announcements for layout/status changes with a manual or UIAutomator-backed checklist.

## Open Questions / Uncertainties

- The exact user-visible settings paths for device profile, app Enter overrides, accessibility, and virtual keyboard mode should be verified on a current build before writing tutorial copy.
- Several features have strong unit coverage but no proven Maestro/UI coverage in this pass.
- Clipboard and update flows depend on Android/OEM/network behavior; scenarios may need stable test doubles or manual verification notes.
- Existing German/Italian localized docs still contain ASCII transliterations such as `Geraeteprofile`, `Oeffne`, and `puo`; if German docs are updated, they should use normal UTF-8 spelling.
