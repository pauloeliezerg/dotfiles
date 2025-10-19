# zmodload zsh/zprof

# ================================================================
# .zshrc - Configuração principal do Zsh (Otimizado)
# ================================================================

# Desabilita verificações desnecessárias
skip_global_compinit=1
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
# Carrega apenas o módulo complist (necessário para menu select)
zmodload zsh/complist

# Prepara fpath e autoload
fpath=(${ZDOTDIR}/completions $fpath)
autoload -Uz compinit

# Caminho do cache
local compinit_dump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d "${compinit_dump:h}" ]] || mkdir -p "${compinit_dump:h}"

# Carrega compinit de forma otimizada mas síncrona
# Isso garante que tudo funcione corretamente
if [[ -f "$compinit_dump" && -n "$compinit_dump"(#qNmh-24) ]]; then
  # Usa cache se tem menos de 24h (rápido)
  compinit -C -d "$compinit_dump"
else
  # Regenera cache (mais lento, mas só acontece 1x por dia)
  compinit -i -d "$compinit_dump"
  # Compila em background para próximas sessões serem ainda mais rápidas
  { zcompile "$compinit_dump" } &!
fi

# ===== COMPLETION STYLES =====
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*' rehash true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# ===== SHELL OPTIONS =====
bindkey -e
setopt complete_in_word pushdsilent no_auto_remove_slash always_to_end
unsetopt CASE_GLOB
stty stop undef start undef 2>/dev/null

# ===== HISTORY =====
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=1000
SAVEHIST=1000
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

export WORDCHARS=''

# ===== TERMINAL KEY MAPPINGS =====
if [[ -n "${terminfo[khome]}" ]]; then
  # Setup básico de teclas
  [[ -n "${terminfo[khome]}" ]] && bindkey -s "${terminfo[khome]}" "^A"
  [[ -n "${terminfo[kend]}" ]] && bindkey -s "${terminfo[kend]}" "^E"
  [[ -n "${terminfo[kich1]}" ]] && bindkey "${terminfo[kich1]}" overwrite-mode
  [[ -n "${terminfo[kbs]}" ]] && bindkey "${terminfo[kbs]}" backward-delete-char
  [[ -n "${terminfo[kdch1]}" ]] && bindkey "${terminfo[kdch1]}" delete-char
  [[ -n "${terminfo[kcub1]}" ]] && bindkey "${terminfo[kcub1]}" backward-char
  [[ -n "${terminfo[kcuf1]}" ]] && bindkey "${terminfo[kcuf1]}" forward-char
  [[ -n "${terminfo[kpp]}" ]] && bindkey "${terminfo[kpp]}" beginning-of-buffer-or-history
  [[ -n "${terminfo[knp]}" ]] && bindkey "${terminfo[knp]}" end-of-buffer-or-history
  [[ -n "${terminfo[kcbt]}" ]] && bindkey "${terminfo[kcbt]}" reverse-menu-complete

  # Up/Down com busca inteligente
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  
  [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
  [[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search

  # Application mode
  if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget 2>/dev/null
    if (( $+functions[add-zle-hook-widget] )); then
      function zle_application_mode_start { echoti smkx }
      function zle_application_mode_stop { echoti rmkx }
      add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
      add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
    fi
  fi
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
    zle end-of-line
    zle -D zle-line-init
  }
  zle -N zle-line-init _lazy_load_first_interaction
fi

# Fallback: carrega no primeiro precmd
_fallback_load_plugins() {
  load_plugins
  add-zsh-hook -d precmd _fallback_load_plugins
}
add-zsh-hook precmd _fallback_load_plugins

# ===== PROMPT =====
source "${ZDOTDIR}/prompt.zsh"

# ===== CLEANUP =====
add-zsh-hook -D precmd '*zsh_autosuggest*'
add-zsh-hook -D precmd '*highlight*'

# Descomente a linha abaixo para fazer profiling
# zprof
