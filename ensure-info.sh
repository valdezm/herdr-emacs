#!/usr/bin/env bash
# Idempotently ensure an "info" workspace exists, with the herdr-emacs keybindings
# cheat sheet rendered in its pane, IN A SPECIFIC SESSION. Safe to run on every
# herdr launch/attach — if the session already has an "info" workspace it does nothing.
#
#   $1 = herdr session name (optional; empty = the default session)
#
# Wired up by `install.sh --hook`, which adds a herdr() shell wrapper that calls
# this on launch/attach with the session being opened. Polls that session's socket
# briefly so it also works on a cold start (the wrapper backgrounds it before the
# foreground `herdr` brings the session's server up).
set -eo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sess="${1-}"
hs=()
[ -n "$sess" ] && hs=(--session "$sess")   # session selector for every herdr call

# Wait for THIS session's server socket to answer (cold-start race), up to ~15s.
for _ in $(seq 1 50); do
  herdr "${hs[@]}" workspace list >/dev/null 2>&1 && break
  sleep 0.3
done
herdr "${hs[@]}" workspace list >/dev/null 2>&1 || exit 0   # session never came up; nothing to do

# Already present in THIS session? (literal guard — never duplicate.)
if herdr "${hs[@]}" workspace list 2>/dev/null | grep -q '"label":"info"'; then
  exit 0
fi

# Create it (unfocused) and render the cheat sheet in its root pane.
out="$(herdr "${hs[@]}" workspace create --label info --no-focus 2>/dev/null)" || exit 0
pane="$(printf '%s' "$out" | grep -o '"pane_id":"[^"]*"' | head -1 | cut -d'"' -f4)"
[ -n "$pane" ] && herdr "${hs[@]}" pane run "$pane" "bash '$repo/keys-view.sh'" >/dev/null 2>&1 || true
