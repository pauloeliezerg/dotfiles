# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e

# delete, alt + delete, home and end keys remap
bindkey "^[[3~" delete-char
bindkey "^[[3;3~" delete-word
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line

# plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# history-substring-search key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# aliases
alias config='/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME'

# starship
eval "$(starship init zsh)"

