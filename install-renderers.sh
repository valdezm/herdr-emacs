#!/usr/bin/env bash
# Install the terminal renderers used by the cheat-sheet panes and the herdr-file-viewer
# plugin — glow (rendered markdown) and bat (syntax highlighting) — into ~/.local/bin.
# No sudo. Linux x86_64/aarch64 via GitHub release binaries; macOS via Homebrew.
#
# Without these, the panes/viewer fall back to plain text (raw markdown, no colors).
set -eo pipefail
mkdir -p "$HOME/.local/bin"

os="$(uname -s)"; arch="$(uname -m)"

if [ "$os" = "Darwin" ]; then
  if command -v brew >/dev/null 2>&1; then
    brew install glow bat
  else
    echo "Install Homebrew, then: brew install glow bat"; exit 1
  fi
  exit 0
fi

# Linux: download prebuilt binaries from the latest GitHub releases (no sudo).
case "$arch" in
  x86_64)  glow_pat="Linux_x86_64.tar.gz";  bat_pat="x86_64-unknown-linux-gnu.tar.gz" ;;
  aarch64) glow_pat="Linux_arm64.tar.gz";   bat_pat="aarch64-unknown-linux-gnu.tar.gz" ;;
  *) echo "unsupported arch: $arch — install glow & bat manually"; exit 1 ;;
esac

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

# repo, asset-name-substring, command-name
fetch() {
  local repo="$1" pat="$2" bin="$3"
  if command -v "$bin" >/dev/null 2>&1; then echo "✓ $bin already installed ($(command -v "$bin"))"; return; fi
  local url
  url="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | PAT="$pat" python3 -c 'import sys,json,os
pat=os.environ["PAT"]
print(next(a["browser_download_url"] for a in json.load(sys.stdin)["assets"] if pat in a["name"]))')"
  echo "↓ $bin: $url"
  curl -fsSL "$url" -o "$tmp/$bin.tgz"
  tar xzf "$tmp/$bin.tgz" -C "$tmp"
  local found; found="$(find "$tmp" -type f -name "$bin" | head -1)"
  install -m755 "$found" "$HOME/.local/bin/$bin"
  echo "✓ installed $bin -> ~/.local/bin/$bin"
}

fetch charmbracelet/glow "$glow_pat" glow
fetch sharkdp/bat        "$bat_pat"  bat

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "NOTE: add ~/.local/bin to PATH";; esac
echo "done. Re-create the info workspace (or reopen the file viewer) to see rendered output."
