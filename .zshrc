# zmodload zsh/zprof

# ================================================================
# .zshrc - Configuração principal do Zsh (Otimizado v2)
# ================================================================

# Desabilita verificações desnecessárias
ZSH_DISABLE_COMPFIX=true

# ===== PERFORMANCE =====
setopt NO_BEEP NO_FLOW_CONTROL NO_HIST_VERIFY AUTO_CD
KEYTIMEOUT=1

# ===== XDG BASE DIRECTORY =====
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

# ===== SOURCING DE ARQUIVOS =====
local -a config_files=(
  "${ZDOTDIR}/exports.zsh"
  "${ZDOTDIR}/functions.zsh"
  "${ZDOTDIR}/aliases.zsh"
)

for file in $config_files; do
  [[ -f "$file" ]] && source "$file"
done

# ===== COMPLETION SYSTEM (OTIMIZADO) =====
zmodload zsh/complist

fpath=(${ZDOTDIR}/completions $fpath)
autoload -Uz compinit

local compinit_dump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d "${compinit_dump:h}" ]] || mkdir -p "${compinit_dump:h}"

if [[ -f "$compinit_dump" && -n "$compinit_dump"(#qNmh-24) ]]; then
  compinit -C -d "$compinit_dump"
else
  compinit -i -d "$compinit_dump"
  { zcompile "$compinit_dump" } &!
fi

# ===== COMPLETION STYLES =====
source "${ZDOTDIR}/completion-styles.zsh"

# ===== SHELL OPTIONS =====
bindkey -e
setopt complete_in_word pushdsilent no_auto_remove_slash always_to_end
unsetopt CASE_GLOB
stty stop undef start undef 2>/dev/null

WORDCHARS=''

# ===== HISTORY =====
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=1000
SAVEHIST=1000
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

# ===== TERMINAL KEY MAPPINGS =====
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

if [[ -n "${terminfo[khome]}" ]]; then
  bindkey -s "${terminfo[khome]}" "^A"
  bindkey -s "${terminfo[kend]}" "^E"
  bindkey "${terminfo[kich1]}" overwrite-mode
  bindkey "${terminfo[kbs]}" backward-delete-char
  bindkey "${terminfo[kdch1]}" delete-char
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey "${terminfo[kcub1]}" backward-char
  bindkey "${terminfo[kcuf1]}" forward-char
  bindkey "${terminfo[kcbt]}" reverse-menu-complete
fi

# ===== KEYBINDINGS =====
source "${ZDOTDIR}/keybindings.zsh"

# ===== LAZY LOADING DE PLUGINS =====
autoload -Uz add-zsh-hook

typeset -g _plugins_loaded=false

load_plugins() {
  [[ $_plugins_loaded == true ]] && return
  [[ -f "${ZDOTDIR}/plugins.zsh" ]] && source "${ZDOTDIR}/plugins.zsh"
  _plugins_loaded=true
}

# Carrega plugins na primeira interação
if [[ -o zle ]]; then
  _lazy_load_first_interaction() {
    load_plugins
    zle end-of-line 2>/dev/null
  }
  
  # Usa add-zle-hook-widget se disponível, caso contrário usa zle -N
  autoload -Uz add-zle-hook-widget 2>/dev/null
  if (( $+functions[add-zle-hook-widget] )); then
    add-zle-hook-widget -Uz zle-line-init _lazy_load_first_interaction
    
    # Application mode usando hooks
    if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
      zle_application_mode_start() { echoti smkx }
      zle_application_mode_stop() { echoti rmkx }
      add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
      add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
    fi
  else
    # Fallback para zle -N se add-zle-hook-widget não estiver disponível
    zle -N zle-line-init _lazy_load_first_interaction
  fi
else
  # Fallback se não estiver em modo interativo
  load_plugins
fi

# ===== PROMPT =====
source "${ZDOTDIR}/prompt.zsh"

# zprof
