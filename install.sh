#!/usr/bin/env bash
# Install the herdr-emacs keymap into ~/.config/herdr/config.toml.
# Backs up any existing config first, then reloads the running herdr server.
#
#   ./install.sh           install the keymap
#   ./install.sh --hook    also wire a herdr() shell wrapper so every launch/attach
#                          auto-opens an "info" workspace with the keybindings cheat sheet
#
# The Claude Code *skill* installs separately (no copy needed):
#   claude plugin marketplace add valdezm/herdr-emacs
#   claude plugin install herdr@herdr-emacs
set -euo pipefail
cd "$(dirname "$0")"
repo="$(pwd)"

install_keymap() {
  local dest="$HOME/.config/herdr/config.toml"
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ]; then
    local bak="$dest.bak.$(date +%Y%m%d-%H%M%S)"
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
}

install_hook() {
  chmod +x "$repo/ensure-info.sh" "$repo/keys-view.sh"
  local rc marker
  case "$(basename "${SHELL:-bash}")" in
    zsh) rc="$HOME/.zshrc" ;;
    *)   rc="$HOME/.bashrc" ;;
  esac
  marker="# >>> herdr-emacs cheat-sheet hook >>>"
  if grep -qF "$marker" "$rc" 2>/dev/null; then
    echo "launch hook already present in $rc"
    return
  fi
  {
    echo ""
    echo "$marker"
    echo "# Auto-open an 'info' workspace with the keybindings cheat sheet on herdr launch/attach."
    echo "herdr() {"
    echo "  case \"\${1-}\" in"
    echo "    \"\"|--session|-s|session|--remote) ( \"$repo/ensure-info.sh\" >/dev/null 2>&1 & ) ;;"
    echo "  esac"
    echo "  command herdr \"\$@\""
    echo "}"
    echo "# <<< herdr-emacs cheat-sheet hook <<<"
  } >> "$rc"
  echo "added herdr launch hook -> $rc (open a new shell to activate)"
}

install_keymap
case "${1-}" in
  --hook) install_hook ;;
esac
