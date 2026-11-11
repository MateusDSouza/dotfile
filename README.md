# dotfiles

My dev setup for macOS, Ubuntu and Windows 11: one command takes a fresh machine to a working one.

## Why everything is green

I was 17, watching *The Matrix* trilogy, when I first thought about studying computer science.
I ended up studying electrical engineering instead, because it was the hardest course at my university,
and years later I taught myself programming.

I kept the green-on-black Matrix look anyway. Those films gave me my first spark of love for computing,
and the theme reminds me why I'm here.

So the terminal (Ghostty, `HaX0R Gr33N`) and VS Code share the same green palette:

- Ghostty: `theme` in `ghostty/.config/ghostty/config`
- VS Code: `workbench.colorCustomizations` and the token colour rules in `vscode/settings.json`,
  built from Ghostty's palette, so no theme extension is needed

To use your own colours, change those two places.

## Install

**macOS / Ubuntu**

```sh
git clone https://github.com/MateusDSouza/dotfiles ~/dotfiles
~/dotfiles/bootstrap.sh
```

**Windows 11** — Windows apps on the host, everything else inside WSL2 Ubuntu:

```powershell
# 1. In an Administrator PowerShell (from a downloaded copy of this repo)
Set-ExecutionPolicy -Scope Process Bypass; .\bootstrap.ps1
```

```sh
# 2. Reboot if asked, open "Ubuntu", then the same as Linux:
git clone https://github.com/MateusDSouza/dotfiles ~/dotfiles
~/dotfiles/bootstrap.sh
```

`bootstrap.sh` first runs `preflight.sh`, which checks that every repository the install downloads from
(apt, Homebrew, GitHub, PyPI, the VS Code Marketplace, Docker, Snap) is reachable. If one isn't, it stops
before installing anything and tells you which. You can also run it on its own with `just preflight`.

The script is safe to re-run. Existing real files that would be replaced by symlinks are first renamed to `*.bak`.

Then, on any OS, set your git identity (kept out of the repo):

```sh
git config -f ~/.gitconfig.local user.name  "Mateus De Souza"
git config -f ~/.gitconfig.local user.email "you@example.com"
```

## What runs where

| | macOS | Ubuntu | Windows 11 |
| --- | --- | --- | --- |
| CLI tools (`Brewfile`) | Homebrew | Homebrew | Homebrew, inside WSL |
| Terminal | Ghostty | Ghostty (snap) | Windows Terminal → WSL |
| VS Code | cask | snap | winget |
| Docker | Docker Desktop | Docker Engine | Docker Desktop (WSL integration) |
| Shell, configs | stow symlinks | stow symlinks | stow symlinks, inside WSL |
| Python 3.14 + tools | uv | uv | uv, inside WSL |

| Piece | File |
| --- | --- |
| CLI tools; macOS apps under `if OS.mac?` | `Brewfile` |
| Python version + global tools | `justfile` (`python`), `python/uv-tools.txt` |
| Ubuntu apps | `justfile` (`apps-linux`) |
| Windows apps, WSL | `bootstrap.ps1` |
| Shell, git, tmux, Ghostty, Starship | `zsh/`, `git/`, `tmux/`, `ghostty/`, `starship/` |
| Network check before install | `preflight.sh` |
| VS Code settings, theme, extensions | `vscode/settings.json`, `vscode/extensions.txt` |
| navi cheatsheets | `navi/cheats/` |

Each config folder mirrors `$HOME`, so `ghostty/.config/ghostty/config` becomes `~/.config/ghostty/config`. Configs are symlinks: edit them in place, commit, done.

## Day to day

```sh
just              # list recipes
just preflight    # check network access to every repository
just install      # everything (idempotent)
just update       # upgrade brew, uv, uv tools, python
just check        # what's missing
just capture      # dump what's on this machine, to diff against the repo
```

Other Python versions: `uv python install 3.12 3.13`; per project: `uv python pin 3.12`.

## Secrets

Never commit them. Machine-specific env vars and tokens go in `~/.zshrc.local`, sourced if it exists.
# dotfile
# dotfile
