# ~/.zshrc — symlinked from ~/dotfiles/zsh/.zshrc
export DOTFILES="$HOME/dotfiles"
# Linux terminals start non-login shells, so .zprofile may not have run
command -v brew >/dev/null || source ~/.zprofile
BREW="$(brew --prefix)"

# ── PATH ────────────────────────────────────────────────────
# ~/.local/bin: uv-managed python + uv tools (replaces pyenv). ~/go/bin: go install
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
export SBX_NO_TELEMETRY=1

# ── History ─────────────────────────────────────────────────
HISTFILE=~/.zsh_history HISTSIZE=100000 SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE

# ── Completion ──────────────────────────────────────────────
FPATH="$BREW/share/zsh/site-functions:$FPATH"
autoload -Uz compinit && compinit -C
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
source <(kubectl completion zsh)
compdef __start_kubectl k
eval "$(uv generate-shell-completion zsh)"

# ── Tools ───────────────────────────────────────────────────
source <(fzf --zsh)                                  # Ctrl-R history, Ctrl-T files
export NAVI_PATH="$DOTFILES/navi/cheats"
eval "$(navi widget zsh)"                            # Ctrl-G
eval "$(starship init zsh)"
source "$BREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# nvm (Node) — only loads if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ── Kubernetes ──────────────────────────────────────────────
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias krm='kubectl delete'
alias ka='kubectl apply -f'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kgns='kubectl get namespaces'
alias kx='kubectx'
alias kn='kubens'

# ── Docker ──────────────────────────────────────────────────
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dex='docker exec -it'
alias dstop='docker stop $(docker ps -a -q)'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'

# ── Other ───────────────────────────────────────────────────
alias tf='terraform'
alias j='just'

# Machine-specific or secret stuff — never committed
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

source "$BREW/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# SDKMAN (Java/Scala) — must stay at the end of the file
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
