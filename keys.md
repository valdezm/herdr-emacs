# herdr-emacs keybindings

Prefix is **`C-x`** (`ctrl+x`). Press the prefix, then the key.

## Panes (emacs window commands)

| key              | action                          |
|------------------|---------------------------------|
| `C-x o`          | move between panes (other-window) |
| `C-x Tab`        | last-used pane (MRU, like VS Code `Ctrl+Tab`) |
| `C-x C-b/C-n/C-p/C-f` | focus pane left / down / up / right |
| `C-x 2`          | split below                     |
| `C-x 3`          | split right                     |
| `C-x 1`          | maximize current pane           |
| `C-x 0`          | close pane                      |
| `C-x S-Tab`      | cycle pane backward             |
| `C-x S-p`        | rename pane                     |
| `C-x r`          | resize mode                     |
| `C-x e`          | edit scrollback                 |

## Tabs

| key         | action                |
|-------------|-----------------------|
| `C-x c`     | new tab               |
| `C-x p`     | previous tab          |
| `C-x n`     | next tab              |
| `C-x k`     | close tab (kill)      |
| `C-x S-t`   | rename tab            |

## Workspaces

| key            | action                |
|----------------|-----------------------|
| `C-x ↑`        | previous workspace    |
| `C-x ↓`        | next workspace        |
| `C-x w`        | workspace picker      |
| `C-x S-1..9`   | jump to workspace N   |
| `C-x S-n`      | new workspace         |
| `C-x S-d`      | close workspace       |
| `C-x S-w`      | rename workspace      |
| `C-x S-g`      | new worktree          |

## Agents

| key            | action            |
|----------------|-------------------|
| `C-x ←`        | previous agent    |
| `C-x →`        | next agent        |
| `C-x M-1..9`   | jump to agent N   |

## Global

| key         | action                          |
|-------------|---------------------------------|
| `C-x b`     | goto / session navigator        |
| `C-x t`     | toggle sidebar                  |
| `C-x s`     | settings                        |
| `C-x ?`     | help (built-in keybind overlay) |
| `C-x q`     | detach                          |
| `C-x S-r`   | reload config                   |
| `C-x S-o`   | notifications                   |

## Copy mode (hardcoded in herdr, not emacs)

`h/j/k/l` move · `w/b/e` by word · `{ }` by paragraph · `v`/`space` select · `y`/`enter` copy · `q`/`esc` exit

## Gotcha

`C-x` is both the herdr prefix and your editor's command key. To send a **literal** `ctrl+x`
into a program in a pane (e.g. quit nano), press `ctrl+x ctrl+x`.
