#!/bin/sh
# Fake curl: intercept Flutter manifest URL and serve local fixture.
# Supports both "curl URL | sh" (payload to stdout) and hardened "curl -o FILE URL"
# (payload written to FILE).
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
    if [ -n "$out" ]; then
      cat /tmp/flutter-releases/releases_linux.json > "$out"
    else
      cat /tmp/flutter-releases/releases_linux.json
    fi
    exit 0
    ;;
esac
exec /usr/bin/curl "$@"
