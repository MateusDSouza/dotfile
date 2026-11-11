# Run `just` to list recipes. Works on macOS and Ubuntu (incl. WSL2).

set shell := ["bash", "-euo", "pipefail", "-c"]

python_version := "3.14"
vscode_user := if os() == "macos" { env_var("HOME") / "Library/Application Support/Code/User" } else { env_var("HOME") / ".config/Code/User" }

default:
    @just --list

# Everything, in order. Idempotent.
install: brew link python apps-linux vscode
    @echo "✔ install complete"

# Install/upgrade the CLI tools (and macOS apps) in the Brewfile
brew:
    #!/usr/bin/env bash
    set -euo pipefail
    # Homebrew refuses to load formulae from third-party taps until they're trusted
    for t in $(sed -nE 's/^tap "([^"]+)".*/\1/p' Brewfile); do
      brew tap "$t"
      if brew trust --help >/dev/null 2>&1; then brew trust --tap "$t"; fi
    done
    brew bundle --file=Brewfile

# Verify every repository the install downloads from is reachable
preflight:
    ./preflight.sh

# Ubuntu desktop apps: Ghostty, VS Code, Docker Engine. Skipped on macOS and WSL.
apps-linux:
    #!/usr/bin/env bash
    set -euo pipefail
    [ "$(uname -s)" = Linux ] || exit 0
    if grep -qi microsoft /proc/version; then echo "WSL: apps come from Windows (bootstrap.ps1)"; exit 0; fi
    command -v ghostty >/dev/null || sudo snap install ghostty --classic
    command -v code    >/dev/null || sudo snap install code --classic
    if ! command -v docker >/dev/null; then
      curl -fsSL https://get.docker.com | sudo sh
      sudo usermod -aG docker "$USER"   # takes effect after you log out and back in
    fi
    echo "✔ linux apps ready"

# Symlink configs into $HOME (backs up existing real files to *.bak first)
link:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in .zshrc .zprofile .gitconfig .gitignore_global .tmux.conf .config/ghostty/config .config/starship.toml; do
      target="$HOME/$f"
      if [ -e "$target" ] && [ ! -L "$target" ]; then mv "$target" "$target.bak"; echo "backed up $target"; fi
    done
    mkdir -p "$HOME/.config"
    stow --restow --target="$HOME" zsh git tmux ghostty starship
    echo "✔ configs linked"

# Remove the symlinks
unlink:
    stow --delete --target="$HOME" zsh git tmux ghostty starship

# Python: global default interpreter + global CLI tools via uv
python:
    #!/usr/bin/env bash
    set -euo pipefail
    # --default also installs `python` and `python3` shims (still flagged experimental in some uv versions)
    uv python install {{python_version}} --default || uv python install {{python_version}} --default --preview
    uv python pin --global {{python_version}}
    while read -r tool extra; do
      [[ -z "$tool" || "$tool" == \#* ]] && continue
      uv tool install --upgrade "$tool" $extra
    done < python/uv-tools.txt
    uv tool update-shell >/dev/null || true
    echo "✔ python {{python_version}} + tools ready (other versions: uv python install 3.12 3.13)"

# VS Code: link settings + install extensions from vscode/extensions.txt
vscode:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v code >/dev/null; then echo "code CLI not found, skipping"; exit 0; fi
    # In WSL, settings live on the Windows side (bootstrap.ps1); `code` here installs into the WSL server
    if ! grep -qi microsoft /proc/version 2>/dev/null; then
      mkdir -p "{{vscode_user}}"
      ln -sfn "{{justfile_directory()}}/vscode/settings.json" "{{vscode_user}}/settings.json"
    fi
    grep -v '^\s*\(#\|$\)' vscode/extensions.txt | xargs -n1 code --force --install-extension
    echo "✔ vscode ready"

# Upgrade everything
update:
    brew update && brew upgrade && brew bundle --file=Brewfile
    uv self update || true
    uv tool upgrade --all
    uv python upgrade {{python_version}} || true

# Snapshot what's on THIS machine, to diff against the repo
capture:
    brew bundle dump --file=Brewfile.current --force --describe
    code --list-extensions > vscode/extensions.current.txt || true
    uv tool list > python/uv-tools.current.txt
    @echo "Compare: diff Brewfile Brewfile.current"

# Report anything missing
check:
    brew bundle check --file=Brewfile --verbose || true
    @for c in uv python3 kubectl k9s kubectx kind cloud-provider-kind docker go just navi fzf tmux code; do command -v $c >/dev/null && echo "✔ $c" || echo "✘ $c"; done
