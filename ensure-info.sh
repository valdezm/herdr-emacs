#!/usr/bin/env bash
# Idempotently ensure an "info" workspace exists with the herdr-emacs keybindings
# cheat sheet rendered in its pane. Safe to run on every herdr launch — if the
# workspace already exists it does nothing.
#
# Wired up by `install.sh --hook`, which adds a herdr() shell wrapper that calls
# this on launch/attach. Polls the socket briefly so it also works on a cold
# server start (the wrapper backgrounds it before `herdr` brings the server up).
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Wait for the server socket to answer (cold-start race), up to ~15s.
for _ in $(seq 1 50); do
  herdr workspace list >/dev/null 2>&1 && break
  sleep 0.3
done
herdr workspace list >/dev/null 2>&1 || exit 0   # no server came up; nothing to do

# Already present? (literal guard — never duplicate.)
if herdr workspace list 2>/dev/null | grep -q '"label":"info"'; then
  exit 0
fi

# Create it (unfocused) and render the cheat sheet in its root pane.
out="$(herdr workspace create --label info --no-focus 2>/dev/null)" || exit 0
pane="$(printf '%s' "$out" | grep -o '"pane_id":"[^"]*"' | head -1 | cut -d'"' -f4)"
[ -n "$pane" ] && herdr pane run "$pane" "bash '$repo/keys-view.sh'" >/dev/null 2>&1 || true
