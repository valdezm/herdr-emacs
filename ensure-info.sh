#!/usr/bin/env bash
# Idempotently ensure an "info" workspace exists, showing the herdr-emacs keybindings
# cheat sheet split across panes (one section group per pane), IN A SPECIFIC SESSION.
# Safe to run on every herdr launch/attach — if the session already has an "info"
# workspace it does nothing.
#
#   $1 = herdr session name (optional; empty = the default session)
#
# Layout:  keymap (left)  |  file-viewer keys (top-right)  /  agent recipes (bottom-right)
set -eo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
view="bash '$repo/keys-view.sh'"

sess="${1-}"
hs=()
[ -n "$sess" ] && hs=(--session "$sess")

# id of result.<path>.pane_id from a herdr JSON response on stdin
pane_id() { python3 -c 'import sys,json,functools
d=json.load(sys.stdin)["result"]
for k in sys.argv[1:]: d=d[k]
print(d["pane_id"])' "$@"; }

# Wait for THIS session's server socket to answer (cold-start race), up to ~15s.
for _ in $(seq 1 50); do
  herdr "${hs[@]}" workspace list >/dev/null 2>&1 && break
  sleep 0.3
done
herdr "${hs[@]}" workspace list >/dev/null 2>&1 || exit 0

# Already present in THIS session? (literal guard — never duplicate.)
if herdr "${hs[@]}" workspace list 2>/dev/null | grep -q '"label":"info"'; then
  exit 0
fi

# Create the workspace; root pane = keymap.
root="$(herdr "${hs[@]}" workspace create --label info --no-focus 2>/dev/null | pane_id root_pane)" || exit 0
[ -n "$root" ] || exit 0

# Right column, split into top (viewer) and bottom (agent recipes).
rtop="$(herdr "${hs[@]}" pane split "$root" --direction right --no-focus 2>/dev/null | pane_id pane)"
rbot="$(herdr "${hs[@]}" pane split "$rtop" --direction down --no-focus 2>/dev/null | pane_id pane)"

sleep 1
herdr "${hs[@]}" pane run "$root" "$view 'Panes (emacs window commands)' Tabs Workspaces Agents Global" >/dev/null 2>&1 || true
[ -n "$rtop" ] && herdr "${hs[@]}" pane run "$rtop" "$view 'File viewer (herdr-file-viewer plugin)'" >/dev/null 2>&1 || true
[ -n "$rbot" ] && herdr "${hs[@]}" pane run "$rbot" "$view 'Ask the agent (herdr skill)'" >/dev/null 2>&1 || true
