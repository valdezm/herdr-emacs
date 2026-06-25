#!/usr/bin/env bash
# Install the herdr-emacs keymap into ~/.config/herdr/config.toml.
# Backs up any existing config first, then reloads the running herdr server.
#
# The Claude Code *skill* installs separately (no copy needed):
#   claude plugin marketplace add valdezm/herdr-emacs
#   claude plugin install herdr@herdr-emacs
set -euo pipefail
cd "$(dirname "$0")"

dest="$HOME/.config/herdr/config.toml"
mkdir -p "$(dirname "$dest")"

if [ -f "$dest" ]; then
  bak="$dest.bak.$(date +%Y%m%d-%H%M%S)"
  cp "$dest" "$bak"
  echo "backed up existing config -> $bak"
fi

cp config.toml "$dest"
echo "installed herdr-emacs keymap -> $dest"

if command -v herdr >/dev/null 2>&1; then
  herdr server reload-config >/dev/null 2>&1 && echo "reloaded running herdr config" \
    || echo "saved. start herdr (or run: herdr server reload-config) to apply"
else
  echo "herdr not on PATH yet — install herdr, then: herdr server reload-config"
fi
