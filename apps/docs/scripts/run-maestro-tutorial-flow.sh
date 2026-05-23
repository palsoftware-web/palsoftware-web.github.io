#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_REPO_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
DEFAULT_PASTIERA_REPO="$HOME/gits/GitHub/pastiera"
if [[ -d "$WEB_REPO_ROOT/../pastiera/.git" ]]; then
  DEFAULT_PASTIERA_REPO="$(cd "$WEB_REPO_ROOT/../pastiera" && pwd)"
fi

SDK_ROOT="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
ADB_BIN="${ADB:-$SDK_ROOT/platform-tools/adb}"
EMULATOR_BIN="${EMULATOR:-$SDK_ROOT/emulator/emulator}"
MAESTRO_BIN="${MAESTRO:-$HOME/.maestro/bin/maestro}"

AVD_NAME="Pastiera_API_36"
ADB_SERIAL="emulator-5584"
EMULATOR_PORT="5584"
APK_PATH=""
PASTIERA_REPO="$DEFAULT_PASTIERA_REPO"
FLOW_PATH="$ROOT_DIR/e2e/maestro/tutorial-onboarding.yaml"
RECORD_OUTPUT=""
STARTED_EMULATOR="0"

usage() {
  cat <<USAGE
Usage:
  run-maestro-tutorial-flow.sh [--avd Pastiera_API_36] [--apk path.apk] [--pastiera-repo path] [--device emulator-5584] [--record output.mp4]

Defaults:
  - If --apk is omitted, the latest stable release APK from the Pastiera repo is used when present.
  - If no APK exists, :app:assembleStableDebug is built and the latest stable debug APK is used.
  - The runner starts the AVD when the requested device is not already connected.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --avd)
      AVD_NAME="$2"; shift 2 ;;
    --apk)
      APK_PATH="$2"; shift 2 ;;
    --pastiera-repo)
      PASTIERA_REPO="$2"; shift 2 ;;
    --device|--udid)
      ADB_SERIAL="$2"; EMULATOR_PORT="${2#emulator-}"; shift 2 ;;
    --record)
      RECORD_OUTPUT="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1 ;;
  esac
done

require_executable() {
  local path="$1"
  local label="$2"
  [[ -x "$path" ]] || {
    echo "$label not found or not executable: $path" >&2
    exit 1
  }
}

require_executable "$ADB_BIN" "adb"
require_executable "$EMULATOR_BIN" "emulator"
require_executable "$MAESTRO_BIN" "maestro"
[[ -f "$FLOW_PATH" ]] || { echo "Flow not found: $FLOW_PATH" >&2; exit 1; }

if [[ -z "$APK_PATH" ]]; then
  APK_PATH="$PASTIERA_REPO/app/build/outputs/apk/stable/release/app-stable-release.apk"
  if [[ ! -f "$APK_PATH" ]]; then
    echo "Stable release APK not found; building stable debug APK from $PASTIERA_REPO"
    (cd "$PASTIERA_REPO" && ./gradlew :app:assembleStableDebug)
    APK_PATH="$(find "$PASTIERA_REPO/app/build/outputs/apk" -type f -name "*stable*debug*.apk" | sort | tail -n 1)"
  fi
fi
[[ -f "$APK_PATH" ]] || { echo "APK not found: $APK_PATH" >&2; exit 1; }

adb_state() {
  "$ADB_BIN" devices | awk -v s="$ADB_SERIAL" '$1 == s { print $2 }'
}

cleanup() {
  if [[ "$STARTED_EMULATOR" == "1" ]]; then
    "$ADB_BIN" -s "$ADB_SERIAL" emu kill >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

if [[ "$(adb_state || true)" != "device" ]]; then
  echo "Starting emulator $AVD_NAME on $ADB_SERIAL"
  "$EMULATOR_BIN" -avd "$AVD_NAME" -port "$EMULATOR_PORT" -no-audio -gpu swiftshader_indirect -no-snapshot-load -no-window >/tmp/pastiera-maestro-emulator.log 2>&1 &
  STARTED_EMULATOR="1"
fi

"$ADB_BIN" -s "$ADB_SERIAL" wait-for-device
for _ in $(seq 1 120); do
  if [[ "$("$ADB_BIN" -s "$ADB_SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
    break
  fi
  sleep 1
done

"$ADB_BIN" -s "$ADB_SERIAL" shell settings put global device_provisioned 1 >/dev/null 2>&1 || true
"$ADB_BIN" -s "$ADB_SERIAL" shell settings put secure user_setup_complete 1 >/dev/null 2>&1 || true
"$ADB_BIN" -s "$ADB_SERIAL" shell wm size 1440x1440 >/dev/null 2>&1 || true
"$ADB_BIN" -s "$ADB_SERIAL" shell wm density reset >/dev/null 2>&1 || true
"$ADB_BIN" -s "$ADB_SERIAL" uninstall it.palsoftware.pastiera >/dev/null 2>&1 || true
"$ADB_BIN" -s "$ADB_SERIAL" install -r "$APK_PATH" >/dev/null

export MAESTRO_CLI_NO_ANALYTICS=1
export MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED=true

if [[ -n "$RECORD_OUTPUT" ]]; then
  mkdir -p "$(dirname "$RECORD_OUTPUT")"
  "$MAESTRO_BIN" --device "$ADB_SERIAL" record --local "$FLOW_PATH" "$RECORD_OUTPUT"
else
  "$MAESTRO_BIN" --device "$ADB_SERIAL" test "$FLOW_PATH"
fi

