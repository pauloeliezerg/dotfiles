# ================================================================
# .zsh_aliases - Aliases
# ================================================================

# Git dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Aplicações
alias wezterm='flatpak run org.wezfurlong.wezterm'
alias code='codium'

# Comandos modernos
alias ls='exa --icons'
alias cat='bat --style=auto'

# zcompile
alias zrecompile='for file in $HOME/.zshrc $HOME/.zprofile $HOME/.zshenv $HOME/.config/zsh/*.zsh; do [[ -f "$file" ]] && zcompile "$file"; done'
