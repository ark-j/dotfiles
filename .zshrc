# exports
export PATH="$PATH:$HOME/go/bin"
export STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"
export EDITOR="nvim"
export FREETYPE_PROPERTIES="cff:no-stem-darkening=0 autofitter:no-stem-darkening=0"
export CURSOR_THEME=capitaine-cursors-light
export XCURSOR_PATH=/usr/share/icons
export XCURSOR_SIZE=24
export QT_QPA_PLATFORM=wayland

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit snippet OMZP::docker-compose
zinit snippet OMZP::firewalld
zinit snippet OMZP::git-commit
zinit snippet OMZP::pip
zinit snippet OMZP::pipenv
zinit snippet OMZP::python
zinit snippet OMZP::rust
zinit snippet OMZP::yarn
zinit snippet OMZP::golang
zinit snippet OMZP::npm
zinit snippet OMZP::ansible
zinit snippet OMZP::nats
zinit snippet OMZP::colorize

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases
alias kc="kubectl"
alias kd="kind"
alias zshconfig="nvim ~/.zshrc"
alias sudo="sudo "
alias ls="lsd"
alias ll="ls -lah"
alias la="ls -ah"
alias lg="lazygit"
alias nv="nvim"
alias gitconfig="nvim ~/.gitconfig"
alias aquired-ports="sudo lsof -i -P -n"
alias list-uncommented="grep -v -e '^#' -e '^$' $1"
alias fzfp='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias batconfig="nvim ~/.config/bat/config"
alias update="sudo pacman -Su && paru -Syu -a --skipreview --removemake --cleanafter --nokeepsrc"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(starship init zsh)"
