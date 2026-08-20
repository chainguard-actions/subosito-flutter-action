#!/bin/sh
# Mock curl that serves local Flutter manifest files instead of making network calls.
# Supports both "curl URL" (stdout) and "curl -o FILE URL" (write to file) forms.
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done
case "$*" in
  *flutter_infra_release/releases/releases_linux.json*)
    MANIFEST="${GITHUB_ACTION_PATH}/test/releases_linux.json"
    if [ -n "$out" ]; then
      cat "$MANIFEST" > "$out"
    else
      cat "$MANIFEST"
    fi
    exit 0
    ;;
  *flutter_infra_release/releases/releases_macos.json*)
    MANIFEST="${GITHUB_ACTION_PATH}/test/releases_macos.json"
    if [ -n "$out" ]; then
      cat "$MANIFEST" > "$out"
    else
      cat "$MANIFEST"
    fi
    exit 0
    ;;
  *flutter_infra_release/releases/releases_windows.json*)
    MANIFEST="${GITHUB_ACTION_PATH}/test/releases_windows.json"
    if [ -n "$out" ]; then
      cat "$MANIFEST" > "$out"
    else
      cat "$MANIFEST"
    fi
    exit 0
    ;;
esac
exec /usr/bin/curl "$@"
