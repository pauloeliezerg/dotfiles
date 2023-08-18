autoload -Uz vcs_info

precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b  '

setopt PROMPT_SUBST
PROMPT='%F{cyan}[%n@%m %~]%f%F{magenta} ${vcs_info_msg_0_}%f%F{yellow}$%f %b'
RPROMPT='%F{blue}%*'

alias config="git --git-dir=$HOME/dotfiles --work-tree=$HOME"
