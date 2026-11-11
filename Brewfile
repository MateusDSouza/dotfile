# Brewfile — CLI tools for macOS and Linux (Ubuntu / WSL). Apps are macOS-only casks below;
# on Ubuntu they come from `just apps-linux`, on Windows from bootstrap.ps1.
# Apply:   brew bundle --file=Brewfile
# Check:   brew bundle check --file=Brewfile

tap "hashicorp/tap"

# ── Core CLI ────────────────────────────────────────────────
brew "git"
brew "git-lfs"
brew "stow"            # symlinks the config folders into $HOME
brew "just"
brew "tmux"
brew "fzf"
brew "navi"
brew "jq"
brew "yq"
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"
brew "gh"

# ── Shell niceties (used by .zshrc) ─────────────────────────
brew "starship"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# ── Python ──────────────────────────────────────────────────
brew "uv"              # Python versions + global tools are handled by `just python`

# ── Languages ───────────────────────────────────────────────
brew "go"
# C: clang/make come from Xcode CLT on macOS, build-essential on Ubuntu (bootstrap.sh)

# ── Kubernetes & infra ──────────────────────────────────────
brew "kubernetes-cli"  # kubectl
brew "k9s"
brew "kubectx"         # kubectx + kubens
brew "helm"
brew "kind"
brew "cloud-provider-kind"
brew "hashicorp/tap/terraform"

# ── AI tools ────────────────────────────────────────────────
brew "opencode"

# ── Apps (macOS only) ───────────────────────────────────────
if OS.mac?
  brew "zsh"
  cask "ghostty"
  cask "visual-studio-code"
  cask "docker-desktop"  # ships the docker CLI; don't also install the `docker` formula
  cask "font-jetbrains-mono-nerd-font"
end

# VS Code extensions live in vscode/extensions.txt (shared with Windows)
