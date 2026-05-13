#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_DIR="$ROOT_DIR/public"
MANIFEST_PATH="$PUBLIC_DIR/showcase/screenshots/manifest.json"
SCENES_PATH="$ROOT_DIR/scripts/screenshot-scenes.json"

WEB_REPO_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
DEFAULT_PASTIERA_REPO="$HOME/gits/GitHub/pastiera"
if [[ -d "$WEB_REPO_ROOT/../pastiera/.git" ]]; then
  DEFAULT_PASTIERA_REPO="$(cd "$WEB_REPO_ROOT/../pastiera" && pwd)"
fi

AVD_NAME=""
APK_PATH=""
PASTIERA_REPO="$DEFAULT_PASTIERA_REPO"
BUILD_ID=""
PASTIERA_COMMIT=""
LOCALES=()
SCREEN_WIDTH="1440"
SCREEN_HEIGHT="1440"
EMULATOR_PORT=""
SHOW_EMULATOR="0"
VERBOSE="0"
BOOT_TIMEOUT_SEC="300"
LOCALE_SETTLE_SEC="8"

SDK_ROOT="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
EMULATOR_BIN=""
ADB_BIN=""
ADB_SERIAL=""
EMULATOR_LOG=""
STARTED_EMULATOR="0"

usage() {
  cat <<USAGE
Usage:
  capture-emulator-screenshots.sh --avd <name> [--pastiera-repo <path>] [--apk <path.apk>] [--build-id <id>] [--locale en-US] [--locale de-DE] [--width 1440] [--height 1440] [--emulator-port 5584] [--show-emulator] [--verbose] [--boot-timeout-sec 300] [--locale-settle-sec 8] [--pastiera-commit <sha>]

Defaults:
  - If --apk is omitted, APK is auto-built from --pastiera-repo via ./gradlew :app:assembleDebug
  - If --build-id is omitted, build id is auto-generated from commit+timestamp
  - Default screenshot size is 1440x1440
  - Locale is applied by restarting emulator per locale with locale boot props (deterministic, no adb-root locale write)
  - Locale/app readiness uses dynamic waits; --locale-settle-sec is only an extra safety buffer

Example (recommended, auto-build):
  npm run docs:screenshots:capture -- \\
    --avd Pastiera_API_36 \\
    --pastiera-repo ~/gits/GitHub/pastiera \\
    --locale en-US \\
    --locale de-DE \\
    --show-emulator \\
    --verbose

Example (explicit APK):
  npm run docs:screenshots:capture -- \\
    --avd Pastiera_API_36 \\
    --apk /tmp/pastiera-debug.apk \\
    --build-id v0.86-abc1234 \\
    --pastiera-commit abc1234
USAGE
}

require_file() {
  local file="$1"
  local label="$2"
  [[ -f "$file" ]] || {
    echo "$label not found: $file" >&2
    exit 1
  }
}

resolve_android_bins() {
  local emulator_candidate="$SDK_ROOT/emulator/emulator"
  local adb_candidate="$SDK_ROOT/platform-tools/adb"

  if [[ -x "$emulator_candidate" ]]; then
    EMULATOR_BIN="$emulator_candidate"
  elif command -v emulator >/dev/null 2>&1; then
    EMULATOR_BIN="$(command -v emulator)"
  else
    echo "Could not find emulator binary. Expected at $emulator_candidate" >&2
    exit 1
  fi

  if [[ -x "$adb_candidate" ]]; then
    ADB_BIN="$adb_candidate"
  elif command -v adb >/dev/null 2>&1; then
    ADB_BIN="$(command -v adb)"
  else
    echo "Could not find adb binary. Expected at $adb_candidate" >&2
    exit 1
  fi
}

adb_cmd() {
  "$ADB_BIN" -s "$ADB_SERIAL" "$@"
}

serial_state() {
  "$ADB_BIN" devices | awk -v s="$ADB_SERIAL" '$1 == s { print $2 }'
}

kill_emulator_on_serial() {
  adb_cmd emu kill >/dev/null 2>&1 || true
  # Fallback if adb cannot talk to the stuck process.
  pkill -f "qemu-system-x86_64-headless.*-port ${EMULATOR_PORT}" >/dev/null 2>&1 || true
  pkill -f "qemu-system-x86_64.*-port ${EMULATOR_PORT}" >/dev/null 2>&1 || true
}

log() {
  if [[ "$VERBOSE" == "1" ]]; then
    echo "$@"
  fi
}

current_focus() {
  local focus
  focus="$(adb_cmd shell dumpsys window windows 2>/dev/null | awk -F' ' '/mCurrentFocus/ {print $0; exit}')"
  if [[ -n "$focus" ]]; then
    echo "$focus"
    return 0
  fi
  adb_cmd shell dumpsys activity activities 2>/dev/null | awk -F' ' '/mResumedActivity|mFocusedActivity/ {print $0; exit}'
}

is_app_foreground() {
  local pkg="$1"
  if current_focus | grep -q "$pkg"; then
    return 0
  fi
  adb_cmd shell dumpsys activity activities 2>/dev/null \
    | grep -E "topResumedActivity|mResumedActivity|mFocusedApp" \
    | grep -q "$pkg"
}

is_system_or_installer_focus() {
  local focus="$1"
  [[ "$focus" == *"com.android.systemui"* ]] \
    || [[ "$focus" == *"com.android.permissioncontroller"* ]] \
    || [[ "$focus" == *"com.google.android.packageinstaller"* ]] \
    || [[ "$focus" == *"android/com.android.internal.app"* ]] \
    || [[ "$focus" == *"com.google.android.gms"* ]] \
    || [[ "$focus" == *"com.google.android.play.core"* ]] \
    || [[ "$focus" == *"com.android.vending"* ]]
}

is_ime_picker_visible() {
  local xml
  xml="$(adb_cmd shell uiautomator dump /sdcard/window_dump.xml >/dev/null 2>&1; adb_cmd shell cat /sdcard/window_dump.xml 2>/dev/null || true)"
  [[ -n "$xml" ]] || return 1
  [[ "$xml" == *"Gboard"* && "$xml" == *"Pastiera"* ]]
}

is_tutorial_foreground() {
  current_focus | grep -q "it\\.palsoftware\\.pastiera/.TutorialActivity"
}

tap_bounds_center() {
  local b="$1"
  # input format: "x1 y1 x2 y2"
  read -r x1 y1 x2 y2 <<<"$b"
  local cx=$(( (x1 + x2) / 2 ))
  local cy=$(( (y1 + y2) / 2 ))
  adb_cmd shell input tap "$cx" "$cy" >/dev/null 2>&1 || true
}

extract_first_bounds_for_text() {
  local xml="$1"
  local pattern="$2"
  echo "$xml" \
    | tr '<' '\n' \
    | grep -E "text=\"(${pattern})\"" \
    | head -n1 \
    | sed -n 's/.*bounds="\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]".*/\1 \2 \3 \4/p'
}

try_tap_known_dialog_button() {
  local xml
  xml="$(adb_cmd shell uiautomator dump /sdcard/window_dump.xml >/dev/null 2>&1; adb_cmd shell cat /sdcard/window_dump.xml 2>/dev/null || true)"
  [[ -n "$xml" ]] || return 1

  # Prefer dismissive actions first to avoid enabling unrelated system features/updaters.
  local dismiss_pattern="Not now|Later|Ignore|Cancel|No thanks|Abbrechen|Später|Nicht jetzt|Ignorieren|Nein danke"
  local confirm_pattern="Wait|OK|Allow|Continue|Next|Skip|Done|Start|Warten|Zulassen|Weiter|Fortfahren|Überspringen|Fertig|Starten"
  local bounds

  bounds="$(extract_first_bounds_for_text "$xml" "$dismiss_pattern")"
  if [[ -n "$bounds" ]]; then
    log "Tapped dismiss dialog button: $bounds"
    tap_bounds_center "$bounds"
    return 0
  fi

  bounds="$(extract_first_bounds_for_text "$xml" "$confirm_pattern")"
  if [[ -n "$bounds" ]]; then
    log "Tapped confirm dialog button: $bounds"
    tap_bounds_center "$bounds"
    return 0
  fi

  return 1
}

try_select_pastiera_from_ime_picker() {
  local xml
  xml="$(adb_cmd shell uiautomator dump /sdcard/window_dump.xml >/dev/null 2>&1; adb_cmd shell cat /sdcard/window_dump.xml 2>/dev/null || true)"
  [[ -n "$xml" ]] || return 1

  local bounds
  bounds="$(extract_first_bounds_for_text "$xml" "Pastiera")"
  if [[ -n "$bounds" ]]; then
    log "Tapped IME picker entry Pastiera: $bounds"
    tap_bounds_center "$bounds"
    sleep 1
    return 0
  fi
  return 1
}

try_tap_tutorial_skip() {
  local xml
  xml="$(adb_cmd shell uiautomator dump /sdcard/window_dump.xml >/dev/null 2>&1; adb_cmd shell cat /sdcard/window_dump.xml 2>/dev/null || true)"
  [[ -n "$xml" ]] || return 1

  # tutorial_skip values from app resources (en/de/it/es/fr/pl/ru/uk/vi)
  local tutorial_skip_pattern="Skip|Überspringen|Salta|Omitir|Passer|Pomiń|Пропустить|Пропустити|Bỏ qua"
  local bounds
  bounds="$(extract_first_bounds_for_text "$xml" "$tutorial_skip_pattern")"
  if [[ -n "$bounds" ]]; then
    log "Tapped tutorial skip button: $bounds"
    tap_bounds_center "$bounds"
    return 0
  fi

  # Fallback: top-left area where skip button is rendered in TutorialActivity.
  adb_cmd shell input tap 100 90 >/dev/null 2>&1 || true
  log "Tapped tutorial skip fallback area (100,90)"
  return 0
}

complete_tutorial_if_present() {
  local waited=0
  while (( waited < BOOT_TIMEOUT_SEC )); do
    if ! is_tutorial_foreground; then
      return 0
    fi
    log "TutorialActivity detected, trying explicit skip."
    try_tap_tutorial_skip || true
    sleep 1
    # If a confirmation dialog appears after skip, dismiss it.
    try_tap_known_dialog_button || true
    sleep 1
    waited=$((waited + 2))
  done

  echo "TutorialActivity did not close after ${BOOT_TIMEOUT_SEC}s." >&2
  return 1
}

wait_for_boot() {
  local waited=0
  adb_cmd wait-for-device
  while true; do
    local boot
    boot="$(adb_cmd shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
    if [[ "$boot" == "1" ]]; then
      return 0
    fi
    if (( waited >= BOOT_TIMEOUT_SEC )); then
      echo "Emulator boot timeout after ${BOOT_TIMEOUT_SEC}s." >&2
      echo "Emulator log: $EMULATOR_LOG" >&2
      return 1
    fi
    if (( waited % 10 == 0 )); then
      echo "Waiting for emulator boot... ${waited}s/${BOOT_TIMEOUT_SEC}s"
    fi
    sleep 2
    waited=$((waited + 2))
  done
}

wait_for_framework_ready() {
  local waited=0
  while true; do
    if adb_cmd shell "service check window 2>/dev/null | grep -q 'found'" >/dev/null 2>&1; then
      return 0
    fi
    if (( waited >= BOOT_TIMEOUT_SEC )); then
      echo "Android framework services not ready after ${BOOT_TIMEOUT_SEC}s (window service missing)." >&2
      echo "Emulator log: $EMULATOR_LOG" >&2
      return 1
    fi
    if (( waited % 10 == 0 )); then
      echo "Waiting for Android framework... ${waited}s/${BOOT_TIMEOUT_SEC}s"
    fi
    sleep 2
    waited=$((waited + 2))
  done
}

unlock_and_prepare_device() {
  adb_cmd shell input keyevent KEYCODE_WAKEUP >/dev/null 2>&1 || true
  adb_cmd shell wm dismiss-keyguard >/dev/null 2>&1 || true
  adb_cmd shell input keyevent KEYCODE_MENU >/dev/null 2>&1 || true
  adb_cmd shell input swipe 540 1800 540 300 >/dev/null 2>&1 || true
  adb_cmd shell input keyevent KEYCODE_HOME >/dev/null 2>&1 || true
}

wait_for_app_stable_foreground() {
  local pkg="$1"
  local waited=0
  local stable_hits=0
  while (( waited < BOOT_TIMEOUT_SEC )); do
    if is_app_foreground "$pkg"; then
      stable_hits=$((stable_hits + 1))
      if (( stable_hits >= 3 )); then
        return 0
      fi
    else
      stable_hits=0
    fi
    sleep 1
    waited=$((waited + 1))
  done
  return 1
}

ensure_device_provisioned_flags() {
  # Best effort: prevent setup/onboarding flows from blocking scripted capture.
  adb_cmd shell settings put global device_provisioned 1 >/dev/null 2>&1 || true
  adb_cmd shell settings put secure user_setup_complete 1 >/dev/null 2>&1 || true
  adb_cmd shell settings put secure user_setup_personalization_state 1 >/dev/null 2>&1 || true
}

dismiss_blocking_dialogs_until_app_ready() {
  local pkg="$1"
  local waited=0
  while (( waited < BOOT_TIMEOUT_SEC )); do
    if is_app_foreground "$pkg"; then
      return 0
    fi

    local focus
    focus="$(current_focus || true)"
    if [[ -n "$focus" ]]; then
      log "Current focus: $focus"
    else
      log "Current focus empty; checking activity stack."
      if is_app_foreground "$pkg"; then
        return 0
      fi
      log "Activity stack does not show app; trying unlock + relaunch."
      unlock_and_prepare_device
      start_activity "$pkg" "$LAUNCH_ACTIVITY"
      sleep 1
      waited=$((waited + 2))
      continue
    fi

    if is_system_or_installer_focus "$focus"; then
      try_select_pastiera_from_ime_picker || true
      try_tap_known_dialog_button || true
      sleep 1
    else
      # Don't blindly tap when app/launcher is focused; just try to bring app front.
      start_activity "$pkg" "$LAUNCH_ACTIVITY"
      sleep 1
    fi

    waited=$((waited + 2))
  done

  echo "Failed to bring app '$pkg' to foreground after ${BOOT_TIMEOUT_SEC}s." >&2
  echo "Current focus: $(current_focus || true)" >&2
  return 1
}

ensure_ime_selected() {
  local ime_id="$1"
  adb_cmd shell ime enable "$ime_id" >/dev/null 2>&1 || true
  adb_cmd shell ime set "$ime_id" >/dev/null 2>&1 || true
  adb_cmd shell settings put secure default_input_method "$ime_id" >/dev/null 2>&1 || true
  adb_cmd shell settings put secure show_ime_with_hard_keyboard 1 >/dev/null 2>&1 || true
}

verify_ime_selected() {
  local ime_id="$1"
  local current_ime
  current_ime="$(adb_cmd shell settings get secure default_input_method 2>/dev/null | tr -d '\r')"
  [[ "$current_ime" == "$ime_id" ]]
}

focus_primary_input_field() {
  local xml
  xml="$(adb_cmd shell uiautomator dump /sdcard/window_dump.xml >/dev/null 2>&1; adb_cmd shell cat /sdcard/window_dump.xml 2>/dev/null || true)"
  [[ -n "$xml" ]] || return 1

  local bounds
  bounds="$(echo "$xml" \
    | tr '<' '\n' \
    | grep -E 'class="android\.widget\.EditText"' \
    | head -n1 \
    | sed -n 's/.*bounds="\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]".*/\1 \2 \3 \4/p')"
  [[ -n "$bounds" ]] || return 1

  log "Tapped primary input field: $bounds"
  tap_bounds_center "$bounds"
  sleep 1
  return 0
}

ensure_ime_picker_resolved() {
  local ime_id="$1"
  local waited=0
  while (( waited < 20 )); do
    if verify_ime_selected "$ime_id"; then
      return 0
    fi
    if is_ime_picker_visible; then
      try_select_pastiera_from_ime_picker || true
      ensure_ime_selected "$ime_id"
    fi
    sleep 1
    waited=$((waited + 1))
  done
  return 1
}

start_activity() {
  local pkg="$1"
  local activity="$2"
  local out
  out="$(adb_cmd shell am start -W -n "$pkg/$activity" 2>/dev/null || true)"
  log "am start result: ${out//$'\n'/ | }"
}

start_app_with_retries() {
  local pkg="$1"
  local activity="$2"
  local attempts=3
  local i
  for (( i=1; i<=attempts; i++ )); do
    log "Starting app attempt ${i}/${attempts}"
    adb_cmd shell am force-stop "$pkg" >/dev/null 2>&1 || true
    start_activity "$pkg" "$activity"

    if complete_tutorial_if_present; then
      # Tutorial completion triggers activity transition; force a clean app foreground start.
      start_activity "$pkg" "$activity"
    fi

    if dismiss_blocking_dialogs_until_app_ready "$pkg" && wait_for_app_stable_foreground "$pkg"; then
      return 0
    fi
    sleep 2
  done
  echo "Failed to start app $pkg/$activity after ${attempts} attempts." >&2
  return 1
}

start_emulator() {
  local locale="${1:-}"
  local locale_lang=""
  local locale_country=""
  if [[ -n "$locale" ]]; then
    locale_lang="${locale%%-*}"
    if [[ "$locale" == *-* ]]; then
      locale_country="${locale#*-}"
    fi
  fi

  echo "Starting emulator $AVD_NAME on port $EMULATOR_PORT ($ADB_SERIAL)${locale:+ with locale $locale}"
  EMU_ARGS=(-avd "$AVD_NAME" -port "$EMULATOR_PORT" -no-audio -gpu swiftshader_indirect -no-snapshot-load)
  if [[ -n "$locale" ]]; then
    EMU_ARGS+=("-prop" "persist.sys.locale=$locale")
    if [[ -n "$locale_lang" ]]; then
      EMU_ARGS+=("-prop" "persist.sys.language=$locale_lang")
    fi
    if [[ -n "$locale_country" && "$locale_country" != "$locale_lang" ]]; then
      EMU_ARGS+=("-prop" "persist.sys.country=$locale_country")
    fi
  fi
  if [[ "$SHOW_EMULATOR" != "1" ]]; then
    EMU_ARGS+=(-no-window)
  fi
  log "Emulator command: $EMULATOR_BIN ${EMU_ARGS[*]}"
  "$EMULATOR_BIN" "${EMU_ARGS[@]}" >"$EMULATOR_LOG" 2>&1 &
  STARTED_EMULATOR="1"
  echo "Emulator log: $EMULATOR_LOG"
}

ensure_emulator_running() {
  local state
  state="$(serial_state || true)"

  if [[ "$state" == "device" ]]; then
    echo "Reusing already running emulator on $ADB_SERIAL"
    return 0
  fi

  if [[ "$state" == "offline" ]]; then
    echo "Found offline emulator on $ADB_SERIAL; restarting it."
    kill_emulator_on_serial
    sleep 2
  fi

  start_emulator
}

restart_emulator_for_locale() {
  local locale="$1"
  # Always restart per locale to guarantee deterministic language state.
  kill_emulator_on_serial
  sleep 2
  start_emulator "$locale"
  wait_for_boot
  wait_for_framework_ready
  unlock_and_prepare_device
  ensure_device_provisioned_flags
  sleep 2
}

pick_emulator_port() {
  # Emulator console ports are even numbers.
  local used_ports
  used_ports="$("$ADB_BIN" devices | awk '/^emulator-[0-9]+/{sub("emulator-","",$1); print $1}')"
  for port in 5584 5586 5588 5590 5592 5594 5596 5598 5600; do
    if ! grep -qx "$port" <<<"$used_ports"; then
      echo "$port"
      return 0
    fi
  done
  echo "No free emulator port found in preset range." >&2
  exit 1
}

autodetect_apk_from_repo() {
  local repo="$1"
  [[ -d "$repo/.git" ]] || {
    echo "Pastiera repo not found: $repo" >&2
    exit 1
  }

  echo "Building Pastiera debug APK from $repo"
  (cd "$repo" && ./gradlew :app:assembleDebug)

  local apk
  apk="$(find "$repo/app/build/outputs/apk" -type f -name "*debug*.apk" | sort | tail -n 1)"
  [[ -n "$apk" ]] || {
    echo "No debug APK found under $repo/app/build/outputs/apk" >&2
    exit 1
  }
  APK_PATH="$apk"

  if [[ -z "$PASTIERA_COMMIT" ]]; then
    PASTIERA_COMMIT="$(git -C "$repo" rev-parse --short HEAD)"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apk)
      APK_PATH="$2"; shift 2 ;;
    --pastiera-repo)
      PASTIERA_REPO="$2"; shift 2 ;;
    --build-id)
      BUILD_ID="$2"; shift 2 ;;
    --avd)
      AVD_NAME="$2"; shift 2 ;;
    --locale)
      LOCALES+=("$2"); shift 2 ;;
    --width)
      SCREEN_WIDTH="$2"; shift 2 ;;
    --height)
      SCREEN_HEIGHT="$2"; shift 2 ;;
    --pastiera-commit)
      PASTIERA_COMMIT="$2"; shift 2 ;;
    --emulator-port)
      EMULATOR_PORT="$2"; shift 2 ;;
    --show-emulator)
      SHOW_EMULATOR="1"; shift ;;
    --verbose)
      VERBOSE="1"; shift ;;
    --boot-timeout-sec)
      BOOT_TIMEOUT_SEC="$2"; shift 2 ;;
    --locale-settle-sec)
      LOCALE_SETTLE_SEC="$2"; shift 2 ;;
    --scenes)
      SCENES_PATH="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1 ;;
  esac
done

[[ -n "$AVD_NAME" ]] || { echo "--avd is required" >&2; exit 1; }
[[ ${#LOCALES[@]} -gt 0 ]] || LOCALES=("en-US")
[[ -f "$SCENES_PATH" ]] || { echo "Scenes file not found: $SCENES_PATH" >&2; exit 1; }
[[ "$SCREEN_WIDTH" =~ ^[0-9]+$ ]] || { echo "--width must be numeric" >&2; exit 1; }
[[ "$SCREEN_HEIGHT" =~ ^[0-9]+$ ]] || { echo "--height must be numeric" >&2; exit 1; }
[[ -z "$EMULATOR_PORT" || "$EMULATOR_PORT" =~ ^[0-9]+$ ]] || { echo "--emulator-port must be numeric" >&2; exit 1; }
[[ "$BOOT_TIMEOUT_SEC" =~ ^[0-9]+$ ]] || { echo "--boot-timeout-sec must be numeric" >&2; exit 1; }
[[ "$LOCALE_SETTLE_SEC" =~ ^[0-9]+$ ]] || { echo "--locale-settle-sec must be numeric" >&2; exit 1; }

if [[ -z "$APK_PATH" ]]; then
  autodetect_apk_from_repo "$PASTIERA_REPO"
else
  require_file "$APK_PATH" "APK"
fi

if [[ -z "$BUILD_ID" ]]; then
  local_commit="${PASTIERA_COMMIT:-unknown}"
  ts="$(date +%Y%m%d-%H%M%S)"
  BUILD_ID="local-${local_commit}-${ts}"
fi

resolve_android_bins
command -v jq >/dev/null 2>&1 || { echo "Missing required binary: jq" >&2; exit 1; }
command -v node >/dev/null 2>&1 || { echo "Missing required binary: node" >&2; exit 1; }

if [[ -z "$EMULATOR_PORT" ]]; then
  EMULATOR_PORT="$(pick_emulator_port)"
fi
ADB_SERIAL="emulator-$EMULATOR_PORT"
EMULATOR_LOG="/tmp/pastiera-emulator-${EMULATOR_PORT}.log"

TMP_DIR="$(mktemp -d)"
cleanup() {
  if [[ "$STARTED_EMULATOR" == "1" ]]; then
    kill_emulator_on_serial
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

PACKAGE_NAME="$(jq -r '.packageName' "$SCENES_PATH")"
LAUNCH_ACTIVITY="$(jq -r '.launchActivity' "$SCENES_PATH")"
IME_ID="${PACKAGE_NAME}/.inputmethod.PhysicalKeyboardInputMethodService"

capture_scene() {
  local locale="$1"
  local locale_key
  locale_key="$(echo "$locale" | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)"
  local outdir="$PUBLIC_DIR/showcase/screenshots/$BUILD_ID/$locale_key"
  mkdir -p "$outdir"

  echo "Preparing locale $locale"
  restart_emulator_for_locale "$locale"
  echo "Installing APK: $APK_PATH"
  adb_cmd install -r "$APK_PATH" >/dev/null
  ensure_ime_selected "$IME_ID"
  ensure_ime_picker_resolved "$IME_ID" || {
    echo "Warning: could not verify Pastiera IME as default; continuing." >&2
  }
  ensure_device_provisioned_flags
  if ! adb_cmd shell "wm size ${SCREEN_WIDTH}x${SCREEN_HEIGHT}" >/dev/null 2>&1; then
    echo "Warning: failed to apply wm size ${SCREEN_WIDTH}x${SCREEN_HEIGHT}; continuing." >&2
  fi
  if ! adb_cmd shell "wm density reset" >/dev/null 2>&1; then
    echo "Warning: failed to reset wm density; continuing." >&2
  fi
  sleep 1

  start_app_with_retries "$PACKAGE_NAME" "$LAUNCH_ACTIVITY"
  if (( LOCALE_SETTLE_SEC > 0 )); then
    # Keep a small configurable settle window for device-specific redraw/IME readiness.
    log "Settling after app foreground for ${LOCALE_SETTLE_SEC}s"
    sleep "$LOCALE_SETTLE_SEC"
  fi

  jq -c '.scenes[]' "$SCENES_PATH" | while read -r scene; do
    local id prep
    id="$(echo "$scene" | jq -r '.id')"
    prep="$(echo "$scene" | jq -r '.prepareShell // ""')"

    if [[ -n "$prep" && "$prep" != "null" ]]; then
      focus_primary_input_field || true
      ensure_ime_picker_resolved "$IME_ID" || true
      adb_cmd shell "$prep" >/dev/null 2>&1 || true
      sleep 1
    fi

    echo "Capturing $id ($locale_key)"
    adb_cmd exec-out screencap -p > "$outdir/$id.png"
  done
}

for locale in "${LOCALES[@]}"; do
  capture_scene "$locale"
done

PASTIERA_COMMIT_VALUE="${PASTIERA_COMMIT:-}"
MANIFEST_PATH_ENV="$MANIFEST_PATH" \
BUILD_ID_ENV="$BUILD_ID" \
PASTIERA_COMMIT_ENV="$PASTIERA_COMMIT_VALUE" \
SCREEN_WIDTH_ENV="$SCREEN_WIDTH" \
SCREEN_HEIGHT_ENV="$SCREEN_HEIGHT" \
node <<'NODE'
const fs = require('fs');
const manifestPath = process.env.MANIFEST_PATH_ENV;
const buildId = process.env.BUILD_ID_ENV;
const pastieraCommit = process.env.PASTIERA_COMMIT_ENV || '';
const resolution = `${process.env.SCREEN_WIDTH_ENV}x${process.env.SCREEN_HEIGHT_ENV}`;
const now = new Date().toISOString();

const manifest = fs.existsSync(manifestPath)
  ? JSON.parse(fs.readFileSync(manifestPath, 'utf-8'))
  : { latestBuild: buildId, builds: {} };

manifest.latestBuild = buildId;
manifest.builds = manifest.builds || {};
manifest.builds[buildId] = {
  ...(manifest.builds[buildId] || {}),
  label: buildId,
  sourceRepo: 'palsoftware/pastiera',
  sourceRef: pastieraCommit || 'unknown',
  capturedAt: now,
  commitUrl: pastieraCommit ? `https://github.com/palsoftware/pastiera/commit/${pastieraCommit}` : undefined,
  resolution
};

fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
NODE

echo "Screenshots captured for build $BUILD_ID"
