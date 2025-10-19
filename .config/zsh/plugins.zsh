# ================================================================
# .zsh_plugins - Configuração de plugins
# ================================================================

# ===== CONFIGURAÇÕES DE PERFORMANCE =====

# Limitar tamanho do buffer para highlighting
export ZSH_HIGHLIGHT_MAXLENGTH=256

# Configurações do autosuggest
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# ===== ZSH-SYNTAX-HIGHLIGHTING =====

if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  # Carrega apenas o highlighter 'main'
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
  
  # Estilos mínimos
  typeset -gA ZSH_HIGHLIGHT_STYLES
  
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ===== ZSH-AUTOSUGGESTIONS =====

if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  
  # Bind após tudo carregar
  _zsh_autosuggest_start
fi

# ===== THROTTLE DE RE-RENDERS =====

typeset -g _LAST_PRECMD_TIME=0

_throttled_precmd() {
  local current_time=$EPOCHSECONDS
  local time_diff=$((current_time - _LAST_PRECMD_TIME))
  
  # Executa no máximo 1x por segundo
  if (( time_diff >= 1 )); then
    _LAST_PRECMD_TIME=$current_time
  fi
}

add-zsh-hook precmd _throttled_precmd
