# ================================================================
# .zsh_keybindings - Configuração de teclas de atalho (Otimizado)
# ================================================================

# ===== KEYBINDINGS BÁSICOS =====

# History Beginning Search
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Garante cursor no final após history search
_history_search_with_end() {
  zle history-beginning-search-backward
  zle end-of-line
}
zle -N _history_search_with_end
bindkey "^[[A" _history_search_with_end
bindkey "^[[B" _history_search_with_end

# Ctrl+U diferente do padrão Zsh
bindkey "^U" backward-kill-line

# Arrow keys com Ctrl e Alt
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Outras teclas
bindkey "^[[3;5~" kill-word
bindkey "^[[Z" reverse-menu-complete

# ===== BASH-LIKE BINDINGS =====

bindkey "^[^" history-expand-line
bindkey "^[#" insert-comment
bindkey "^[*" insert-completions
bindkey "^[\\" delete-horizontal-space
bindkey "^[&" tilde-expand
bindkey "^[=" list-choices

# ===== CONTROL-X BINDINGS =====

bindkey "^X^E" edit-command-line
bindkey "^X^?" backward-kill-line
bindkey "^X(" start-kbd-macro
bindkey "^X)" end-kbd-macro
bindkey "^Xe" call-last-kbd-macro
bindkey "^X!" possible-command-completions
bindkey "^X/" possible-filename-completions
bindkey "^X@" possible-hostname-completions
bindkey "^X~" possible-username-completions
bindkey "^X\$" possible-variable-completions
bindkey "^X?" _complete_debug
bindkey "^Xg" list-expand
bindkey "^X*" expand-word
bindkey "^Xs" spell-correct-word

# ===== ALT + CONTROL =====

bindkey "^[^E" shell-expand-line
bindkey "^[^I" dynamic-complete-history
bindkey "^[^R" revert-line
bindkey "^[^Y" yank-nth-arg
bindkey "^[^]" character-search-backward

# ===== CUSTOM WIDGETS =====

# Magic space - expande histórico apenas quando necessário
magic-space() {
  local expanded=false
  [[ $LBUFFER == *\!* ]] && zle expand-history && expanded=true
  LBUFFER+=" "
  [[ $expanded == true ]] && zle reset-prompt
}
zle -N magic-space
bindkey " " magic-space

# Shell expand line
shell-expand-line() {
  LBUFFER="$(echo "${LBUFFER}${RBUFFER}" | xargs -0 2>/dev/null || echo "${LBUFFER}${RBUFFER}")"
  RBUFFER=""
}
zle -N shell-expand-line

# Character search
character-search() {
  local char
  read -k char
  zle vi-find-next-char -- -s $char
}
zle -N character-search
bindkey "^]" character-search

# Character search backward
character-search-backward() {
  local char
  read -k char
  zle vi-find-prev-char -- -s $char
}
zle -N character-search-backward

# Dynamic complete history
dynamic-complete-history() {
  zle expand-history
  zle menu-complete
}
zle -N dynamic-complete-history

# Yank nth arg
yank-nth-arg() {
  if [[ -z $NUMERIC ]]; then
    zle yank-last-arg
  else
    local n=$NUMERIC
    zle history-search-backward
    local -a words=("${(@s/ /)BUFFER}")
    if (( n <= ${#words} )); then
      zle end-of-history
      LBUFFER+="${words[n]}"
    fi
  fi
}
zle -N yank-nth-arg

# Revert line
revert-line() { zle send-break }
zle -N revert-line

# ===== COMPLETION HELPERS =====

possible-command-completions() { zle complete-word }
zle -N possible-command-completions

possible-filename-completions() { zle menu-complete }
zle -N possible-filename-completions

possible-hostname-completions() { zle _complete_hosts }
zle -N possible-hostname-completions

possible-username-completions() { zle _complete_users }
zle -N possible-username-completions

possible-variable-completions() { zle _complete_vars }
zle -N possible-variable-completions

# ===== RE-READ INIT FILE =====

re-read-init-file() {
  source ~/.zshrc
  zle reset-prompt
}
zle -N re-read-init-file
bindkey "^X^R" re-read-init-file

# ===== DO LOWERCASE VERSION =====

do-lowercase-version() {
  local char=$KEYS[-1]
  [[ $char = [A-Z] ]] && LBUFFER+=${(L)char} || zle self-insert
}
zle -N do-lowercase-version

# Bind todas as letras maiúsculas de uma vez
for key in {A..Z}; do
  bindkey "^X$key" do-lowercase-version
done
