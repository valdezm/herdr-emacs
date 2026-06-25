#!/usr/bin/env bash
# Presenter view of the herdr-emacs keybindings.
# Renders keys.md with the best available markdown viewer, falling back to less.
# Meant to run in its own herdr pane (e.g. an "info" workspace) — see README.
set -euo pipefail
cd "$(dirname "$0")"
doc="keys.md"

if command -v glow >/dev/null 2>&1; then
  exec glow -p "$doc"            # paged, styled
elif command -v mdcat >/dev/null 2>&1; then
  mdcat "$doc" | exec less -R
elif command -v bat >/dev/null 2>&1; then
  exec bat --style=plain --paging=always -l markdown "$doc"
else
  exec less -R "$doc"           # always present
fi
