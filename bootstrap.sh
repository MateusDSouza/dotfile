#!/usr/bin/env bash
# Fresh-machine entry point for macOS and Ubuntu (incl. WSL2 on Windows). Safe to re-run.
#   git clone https://github.com/MateusDSouza/dotfiles ~/dotfiles && ~/dotfiles/bootstrap.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

log "Checking network access to all repositories"
"$DOTFILES/preflight.sh"

case "$(uname -s)" in
  Darwin)
    # Xcode Command Line Tools (git, clang, make)
    if ! xcode-select -p >/dev/null 2>&1; then
      log "Installing Xcode Command Line Tools — accept the dialog, then re-run this script"
      xcode-select --install
      exit 0
    fi
    ;;
  Linux)
    log "Installing Ubuntu base packages (needs sudo)"
    sudo apt-get update
    sudo apt-get install -y build-essential procps curl file git zsh unzip
    ;;
  *)
    echo "Unsupported OS: $(uname -s). On Windows run bootstrap.ps1 first, then this inside WSL." >&2
    exit 1
    ;;
esac

# Homebrew (macOS and Linux)
if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -x "$b" ] && eval "$("$b" shellenv)" && break
done

# just — everything else is a recipe in the justfile
brew list just >/dev/null 2>&1 || brew install just

log "Running full install"
cd "$DOTFILES"
just install

# Make zsh the login shell on Linux (macOS already defaults to zsh)
if [ "$(uname -s)" = Linux ] && [ "$(basename "${SHELL:-}")" != zsh ]; then
  log "Setting zsh as login shell"
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

log "Done. Open a new terminal to load the new shell config."
