# ================================================================
# .zshrc - Configuração principal do Zsh
# ================================================================

zmodload zsh/zprof

# Desabilita verificações desnecessárias
skip_global_compinit=1
ZSH_DISABLE_COMPFIX=true

# ===== PERFORMANCE =====
setopt NO_BEEP
setopt NO_FLOW_CONTROL
setopt NO_HIST_VERIFY
KEYTIMEOUT=1

# ===== XDG BASE DIRECTORY =====
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

# ===== SOURCING DE ARQUIVOS =====
[ -f "${ZDOTDIR}/exports.zsh" ] && source "${ZDOTDIR}/exports.zsh"
[ -f "${ZDOTDIR}/functions.zsh" ] && source "${ZDOTDIR}/functions.zsh"
[ -f "${ZDOTDIR}/aliases.zsh" ] && source "${ZDOTDIR}/aliases.zsh"

# ===== LAZY LOADING DE PLUGINS =====
autoload -Uz add-zsh-hook

_plugins_loaded=false
_plugins_loading=false

load_plugins() {
  if [[ $_plugins_loading == true ]]; then
    return
  fi
  
  if [[ $_plugins_loaded == false ]]; then
    _plugins_loading=true
    [ -f "${ZDOTDIR}/plugins.zsh" ] && source "${ZDOTDIR}/plugins.zsh"
    _plugins_loaded=true
    _plugins_loading=false
  fi
}

_lazy_load_first_interaction() {
  load_plugins
  zle -D zle-line-init
}

if [[ -o zle ]]; then
  zle -N zle-line-init _lazy_load_first_interaction
fi

_first_precmd=true
_fallback_load_plugins() {
  if [[ $_first_precmd == true ]]; then
    _first_precmd=false
    load_plugins
    add-zsh-hook -d precmd _fallback_load_plugins
  fi
}
add-zsh-hook precmd _fallback_load_plugins

# ===== COMPLETION OTIMIZADO =====
fpath=(${ZDOTDIR}/completions $fpath)
autoload -Uz compinit

_COMPINIT_LOADED=false

lazy_compinit() {
  if [[ $_COMPINIT_LOADED == false ]]; then
    local compinit_dump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
    
    # Cria diretório de cache se não existir
    [[ -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" ]] || mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
    
    if [[ -f "$compinit_dump" && -n "$compinit_dump"(#qNmh-24) ]]; then
      compinit -C -d "$compinit_dump"
    else
      compinit -d "$compinit_dump"
    fi
    _COMPINIT_LOADED=true
  fi
}

_first_completion=true
_load_compinit_on_tab() {
  if [[ $_first_completion == true ]]; then
    lazy_compinit
    _first_completion=false
  fi
  zle expand-or-complete
}
zle -N complete-with-lazy-compinit _load_compinit_on_tab
bindkey '^I' complete-with-lazy-compinit

# ===== COMPLETION STYLES =====
zstyle :compinstall filename "$HOME/.zshrc"
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' accept-exact '*(N)'

# ===== SHELL OPTIONS =====
bindkey -e
setopt noflowcontrol
setopt pushdsilent
setopt no_auto_remove_slash
setopt no_list_ambiguous
unsetopt CASE_GLOB
unsetopt menu_complete

stty stop undef 2>/dev/null
stty start undef 2>/dev/null

# ===== KEYBINDINGS =====
source "${ZDOTDIR}/keybindings.zsh"

# ===== HISTORY =====
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=1000
SAVEHIST=1000

# Cria diretório de dados se não existir
[[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zsh" ]] || mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

export WORDCHARS=''

# ===== TERMINAL KEY MAPPINGS =====
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  function zle_application_mode_start { echoti smkx }
  function zle_application_mode_stop { echoti rmkx }
  add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
  add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# ===== PROMPT =====
source "${ZDOTDIR}/prompt.zsh"

# ===== CLEANUP =====
add-zsh-hook -D precmd '*zsh_autosuggest*'
add-zsh-hook -D precmd '*highlight*'

zprof
