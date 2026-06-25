#!/usr/bin/env bash
# Presenter view of the herdr-emacs keybindings cheat sheet (keys.md).
# Renders with the best available markdown viewer (glow/bat), else less.
#
#   keys-view.sh                       render the whole cheat sheet
#   keys-view.sh "Tabs" "Global" ...   render only those `## ` sections (by title)
#
# Meant to run in its own herdr pane; ensure-info.sh opens several, one section each.
set -eo pipefail
cd "$(dirname "$0")"
doc="keys.md"

emit() {
  if [ "$#" -eq 0 ]; then
    cat "$doc"
  else
    python3 - "$doc" "$@" <<'PY'
import sys
doc, want = sys.argv[1], {a.strip() for a in sys.argv[2:]}
emit = False
for ln in open(doc).read().splitlines():
    if ln.startswith("## "):
        emit = ln[3:].strip() in want
    if emit:
        print(ln)
PY
  fi
}

render() {
  if command -v glow >/dev/null 2>&1; then glow -p
  elif command -v bat >/dev/null 2>&1; then bat --style=plain --paging=always -l markdown
  else less -R
  fi
}

emit "$@" | render
