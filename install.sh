#!/usr/bin/env bash
# Install the herdr-emacs keymap into ~/.config/herdr/config.toml.
# Backs up any existing config first, then reloads the running herdr server.
#
#   ./install.sh                  install the keymap
#   ./install.sh --hook           also wire a herdr() shell wrapper so every launch/attach
#                                 auto-opens an "info" workspace with the keybindings cheat sheet
#   ./install.sh --renderers      also install glow (rendered markdown) + bat (syntax) to ~/.local/bin
#   ./install.sh --hook --renderers   both
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
    echo "# Passes the session being opened so the cheat sheet lands in THAT session, not default."
    echo "herdr() {"
    echo "  local s=\"\" a1=\"\${1-}\" a2=\"\${2-}\" a3=\"\${3-}\""
    echo "  case \"\$a1\" in"
    echo "    \"\") ;;"
    echo "    --session) s=\"\$a2\" ;;"
    echo "    session) if [ \"\$a2\" = attach ]; then s=\"\$a3\"; else command herdr \"\$@\"; return; fi ;;"
    echo "    --remote) ;;"
    echo "    *) command herdr \"\$@\"; return ;;"
    echo "  esac"
    echo "  ( \"$repo/ensure-info.sh\" \"\$s\" >/dev/null 2>&1 & )"
    echo "  command herdr \"\$@\""
    echo "}"
    echo "# <<< herdr-emacs cheat-sheet hook <<<"
  } >> "$rc"
  echo "added herdr launch hook -> $rc (open a new shell to activate)"
}

install_keymap
for arg in "$@"; do
  case "$arg" in
    --hook) install_hook ;;
    --renderers) bash "$repo/install-renderers.sh" ;;
  esac
done
