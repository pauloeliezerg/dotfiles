# ================================================================
# prompt.zsh - Configuração do prompt (Otimizado v2)
# ================================================================

setopt PROMPT_SUBST
autoload -U colors && colors

# ===== VARIÁVEIS DE CACHE =====
typeset -g _cmd_start=0
typeset -g _cmd_duration=""
typeset -g _git_info_cache=""
typeset -g _nodejs_info_cache=""
typeset -g _python_info_cache=""
typeset -g _cache_pwd=""
typeset -g _skip_next_duration=false
typeset -g _last_exit_status=0
typeset -g _show_exit_color=false

# ===== HOOKS DO PROMPT =====
autoload -Uz add-zle-hook-widget add-zsh-hook

# Gerencia cursor
if (( $+functions[add-zle-hook-widget] )); then
  _prompt_zle_line_finish() {
    [[ -z "$BUFFER" ]] && _skip_next_duration=true || _skip_next_duration=false
  }
  add-zle-hook-widget zle-line-finish _prompt_zle_line_finish
fi

# Timer e captura de exit status
preexec() {
  _cmd_start=$(($(date +%s%N)/1000000))
  [[ "$1" =~ ^clear($| ) ]] && _skip_next_duration=true || _skip_next_duration=false
}

_prompt_precmd_handler() {
  _last_exit_status=$?
  _show_exit_color=true
  
  local needs_update=false
  
  # Calcula duração
  if [[ $_cmd_start -gt 0 ]]; then
    local now=$(($(date +%s%N)/1000000))
    local elapsed=$((now - _cmd_start))
    
    if (( elapsed >= 60000 )); then
      local mins=$((elapsed / 60000))
      local secs=$(((elapsed % 60000) / 1000))
      _cmd_duration="${mins}m ${secs}s"
    elif (( elapsed >= 1000 )); then
      local secs=$((elapsed / 1000))
      local ms=$((elapsed % 1000))
      _cmd_duration="${secs}s ${ms}ms"
    else
      _cmd_duration="${elapsed}ms"
    fi
    
    _cmd_start=0
    needs_update=true
  elif [[ $_skip_next_duration == true ]]; then
    _cmd_duration=""
    _show_exit_color=false
  else
    _show_exit_color=false
  fi
  
  # Imprime duração se necessário
  [[ $_skip_next_duration == false && -n "$_cmd_duration" ]] && echo "\e[33m⏱  $_cmd_duration\e[0m"
  [[ $_skip_next_duration == true ]] && _skip_next_duration=false
  
  # Atualiza caches apenas se necessário
  if [[ "$PWD" != "$_cache_pwd" || $needs_update == true ]]; then
    _update_git_info
    _update_nodejs_info
    _update_python_info
    _cache_pwd="$PWD"
  fi
}

add-zsh-hook precmd _prompt_precmd_handler

# ===== FUNÇÕES DE CACHE =====

_update_git_info() {
  _git_info_cache=""
  
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return
  
  # Usa git status --porcelain para ser mais eficiente
  local status_output=$(git status --porcelain 2>/dev/null)
  local git_status=""
  
  if [[ -n "$status_output" ]]; then
    if [[ "$status_output" =~ ^[MADRCU\ ][MADRCU\ ] ]]; then
      git_status=" %F{yellow}[*]%f"
    elif [[ "$status_output" =~ ^\?\? ]]; then
      git_status=" %F{yellow}[?]%f"
    fi
  fi
  
  _git_info_cache=" %F{magenta} %F{magenta}$branch%f$git_status"
}

_update_nodejs_info() {
  _nodejs_info_cache=""
  [[ ! -f "package.json" ]] && return
  
  local node_version=$(node --version 2>/dev/null)
  [[ -n "$node_version" ]] && _nodejs_info_cache=" %F{green}⬢ ${node_version#v}%f"
}

_update_python_info() {
  _python_info_cache=""
  [[ ! -f ".python-version" && ! -f "Pipfile" && ! -f "pyproject.toml" ]] && return
  
  local python_version=$(python3 --version 2>/dev/null | cut -d' ' -f2)
  [[ -n "$python_version" ]] && _python_info_cache=" %F{yellow}🐍 ${python_version}%f"
}

# ===== COMPONENTES DO PROMPT =====

_prompt_dir() {
  local dir="${PWD/#$HOME/~}"
  local -a parts=(${(s:/:)dir})
  
  (( ${#parts[@]} > 3 )) && echo "…/${parts[-3]}/${parts[-2]}/${parts[-1]}" || echo "$dir"
}

_prompt_char() {
  if [[ $_show_exit_color == true ]]; then
    (( _last_exit_status == 0 )) && echo "%F{green}%B\$%b%f" || echo "%F{red}%B\$%b%f"
  else
    echo "%F{white}%B\$%b%f"
  fi
}

# ===== DEFINIÇÃO DO PROMPT =====

PROMPT='%F{cyan}$(_prompt_dir)%f${_git_info_cache}${_nodejs_info_cache}${_python_info_cache} $(_prompt_char) '
RPROMPT=''

# ===== CONFIGURAÇÕES ANTI-FLICKER =====

setopt prompt_cr prompt_sp
typeset -g PROMPT_EOL_MARK=''
setopt transient_rprompt 2>/dev/null
KEYTIMEOUT=1
