#!/bin/sh
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"


# history
HISTFILE=~/.zsh_history

# source
plug "$HOME/.config/zsh/aliases.zsh"
plug "$HOME/.config/zsh/exports.zsh"
# plug "$HOME/.config/zsh/functions.zsh"

# plugins
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/vim"
plug "zap-zsh/zap-prompt"
# plug "zap-zsh/atmachine" 
plug "zap-zsh/fzf"
plug "zap-zsh/exa"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-history-substring-search"

# keybinds
bindkey '^ ' autosuggest-accept

export PATH="$HOME/.local/bin":$PATH

# alias
  alias j='z'
  alias f='zi'
  alias g='lazygit'
  alias zsh-update-plugins="find "$ZDOTDIR/plugins" -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull -q"
  alias nvimrc='nvim ~/.config/nvim/'
  alias nman='bob'
  alias sshk="kitty +kitten ssh"
  # alias lvim="env TERM=wezterm lvim"
  # alias nvim="env TERM=wezterm nvim"

  # Remarkable
  alias remarkable_ssh='ssh root@10.11.99.1'
  alias restream='restream -p'

  # Colorize grep output (good for log files)
  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'

  # confirm before overwriting something
  alias cp="cp -i"
  alias mv='mv -i'
  alias rm='rm -i'

# exports
  HISTSIZE=1000000
  SAVEHIST=1000000
  export EDITOR="nvim"
  export TERMINAL="st"
  # export BROWSER="firefox"
  export PATH="$HOME/.local/bin":$PATH
  export PATH="$HOME/.docker/bin":$PATH
  # export PATH="$HOME/.local/nvim-macos-arm64/bin":$PATH
  export MANPAGER='nvim +Man!'
  export MANWIDTH=999
  export PATH=$HOME/.cargo/bin:$PATH
  export PATH=$HOME/.local/share/go/bin:$PATH
  export GOPATH=$HOME/.local/share/go
  export PATH=$HOME/.fnm:$PATH
  export PATH="$HOME/.local/share/neovim/bin":$PATH
  #export PATH="$HOME/.local/share/bob/nvim-bin":$PATH
  #export XDG_CURRENT_DESKTOP="Wayland"
  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_ENV_HINTS=1
  #export PATH="$PATH:./node_modules/.bin"
  eval "$(fnm env)"
  eval "$(zoxide init zsh)"
