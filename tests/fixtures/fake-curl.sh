#!/bin/sh
# Fake curl: intercepts Flutter release manifest URL and serves local fixture.
# Supports both "curl URL | sh" (stdout) and hardened "curl -o FILE URL" forms.
# Falls through to real curl for other URLs.

out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done

case "$*" in
  *flutter_infra_release/releases/releases_linux*)
    FIXTURE="$GITHUB_WORKSPACE/tests/fixtures/releases_linux.json"
    if [ -n "$out" ]; then
      cat "$FIXTURE" > "$out"
    else
      cat "$FIXTURE"
    fi
    exit 0
    ;;
  *flutter_infra_release/releases/releases_macos*)
    FIXTURE="$GITHUB_WORKSPACE/tests/fixtures/releases_linux.json"
    if [ -n "$out" ]; then
      cat "$FIXTURE" > "$out"
    else
      cat "$FIXTURE"
    fi
    exit 0
    ;;
  *flutter_infra_release/releases/releases_windows*)
    FIXTURE="$GITHUB_WORKSPACE/tests/fixtures/releases_linux.json"
    if [ -n "$out" ]; then
      cat "$FIXTURE" > "$out"
    else
      cat "$FIXTURE"
    fi
    exit 0
    ;;
esac

# Fall through to real curl for other URLs
exec /usr/bin/curl "$@"
