# ================================================================
# ~/.config/zsh/prompt.zsh - Configuração do prompt
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
typeset -g _last_cmd_executed=false
typeset -g _prompt_initialized=false
typeset -g _empty_enter_pressed=false
typeset -g _skip_next_duration=false
typeset -g _last_exit_status=0
typeset -g _show_exit_color=false
typeset -g _last_command=""

# ===== INICIALIZAÇÃO =====
_initialize_prompt() {
  if [[ $_prompt_initialized == false ]]; then
    _update_git_info
    _update_nodejs_info
    _update_python_info
    _cache_pwd="$PWD"
    _prompt_initialized=true
  fi
}

# ===== HOOKS DO PROMPT =====

# Carrega o sistema de hooks se ainda não estiver carregado
autoload -Uz add-zle-hook-widget

# Detecta se Enter foi pressionado em linha vazia
_prompt_zle_line_init() {
  # Cursor sólido, sem blink
  printf '\e[2 q'
}

_prompt_zle_line_finish() {
  # CRÍTICO: Esconde cursor IMEDIATAMENTE quando Enter é pressionado
  printf '\e[?25l'
  
  # Detecta se a linha está vazia quando Enter é pressionado
  if [[ -z "$BUFFER" ]]; then
    _empty_enter_pressed=true
    _skip_next_duration=true  # Para input vazio, pula a duração do próximo comando
  else
    _empty_enter_pressed=false
    _skip_next_duration=false
  fi
}

# Usa add-zle-hook-widget para não conflitar com outros hooks
add-zle-hook-widget zle-line-init _prompt_zle_line_init
add-zle-hook-widget zle-line-finish _prompt_zle_line_finish

# CRÍTICO: Captura exit status IMEDIATAMENTE antes de qualquer precmd
autoload -Uz add-zsh-hook

_prompt_capture_exit_status() {
  _last_exit_status=$?
  # echo "[DEBUG CAPTURE] Exit status capturado: $_last_exit_status" >&2
}

add-zsh-hook precmd _prompt_capture_exit_status

# Timer de comando (roda ANTES do comando)
preexec() {
  # Salva o comando que será executado
  _last_command="$1"
  
  _cmd_start=$(($(date +%s%N)/1000000))
  _last_cmd_executed=true
  _empty_enter_pressed=false
  
  # Verifica se o comando é 'clear' - se for, pula duração
  if [[ "$1" =~ ^clear($| ) ]] || [[ "$1" == "clear" ]]; then
    _skip_next_duration=true
  else
    _skip_next_duration=false
  fi
  
  # Mostra cursor antes de executar comando
  printf '\e[?25h'
}

# Atualiza informações após comando - usa nome único para evitar conflitos
_prompt_precmd_handler() {
  # CRÍTICO: Esconde cursor no início do precmd
  printf '\e[?25l'

  # Mostra cor baseada no último comando executado
  _show_exit_color=true

  # Garante inicialização no primeiro prompt
  _initialize_prompt
  
  local needs_update=false
  
  # Calcula duração do comando (apenas se comando foi executado)
  if [[ $_cmd_start -gt 0 ]]; then
    local now=$(($(date +%s%N)/1000000))
    local elapsed=$((now - _cmd_start))
    # Formata duração baseado no tempo decorrido
    if [[ $elapsed -ge 60000 ]]; then
      # >= 1 minuto: mostra minutos e segundos
      local mins=$((elapsed / 60000))
      local secs=$(((elapsed % 60000) / 1000))
      _cmd_duration="${mins}m ${secs}s"
    elif [[ $elapsed -ge 1000 ]]; then
      # >= 1 segundo: mostra segundos e milisegundos
      local secs=$((elapsed / 1000))
      local ms=$((elapsed % 1000))
      _cmd_duration="${secs}s ${ms}ms"
    else
      # < 1 segundo: mostra apenas milisegundos
      _cmd_duration="${elapsed}ms"
    fi
    _cmd_start=0
    needs_update=true
    
  elif [[ $_empty_enter_pressed == true ]]; then
    # Enter vazio - limpa duração E não mostra cor de status
    _cmd_duration=""
    _show_exit_color=false
  else
    # Primeiro prompt ou situação inicial - não mostra cor
    _show_exit_color=false
  fi
  
  # Imprime a duração na tela para persistência (apenas se não for para pular)
  if [[ $_skip_next_duration == false ]] && [[ -n "$_cmd_duration" ]]; then
    echo "\e[33m⏱  $_cmd_duration\e[0m"
  fi
  
  # Se for para pular a próxima, imprime uma linha vazia para "timestamp vazio" e reseta
  if [[ $_skip_next_duration == true ]]; then
    # echo ""  # Linha vazia para representar timestamp vazio
    _skip_next_duration=false
  fi
  
  # Atualiza caches apenas se necessário
  if [[ "$PWD" != "$_cache_pwd" ]] || [[ $needs_update == true ]]; then
    _update_git_info
    _update_nodejs_info
    _update_python_info
    _cache_pwd="$PWD"
  fi
  
  _last_cmd_executed=false
  
  # CRÍTICO: Pequeno delay antes de mostrar cursor (similar ao wezterm.sleep_ms)
  # Isso dá tempo para o prompt renderizar completamente
  sleep 0.005  # 5ms de delay
  
  # Mostra cursor novamente após prompt estar pronto
  printf '\e[?25h'
}

# CRÍTICO: Adiciona como PRIMEIRO hook em precmd_functions
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_precmd_handler

# ===== FUNÇÕES DE CACHE =====

_update_git_info() {
  _git_info_cache=""
  
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  
  if [[ -n "$branch" ]]; then
    local git_status=""
    
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
      git_status=" %F{yellow}[*]%f"
    elif [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
      git_status=" %F{yellow}[?]%f"
    fi
    
    _git_info_cache=" %F{magenta} %F{magenta}$branch%f$git_status"
  fi
}

_update_nodejs_info() {
  _nodejs_info_cache=""
  
  if [[ -f "package.json" ]]; then
    local node_version=$(node --version 2>/dev/null)
    if [[ -n "$node_version" ]]; then
      _nodejs_info_cache=" %F{green}⬢ ${node_version#v}%f"
    fi
  fi
}

_update_python_info() {
  _python_info_cache=""
  
  if [[ -f ".python-version" ]] || [[ -f "Pipfile" ]] || [[ -f "pyproject.toml" ]]; then
    local python_version=$(python3 --version 2>/dev/null | cut -d' ' -f2)
    if [[ -n "$python_version" ]]; then
      _python_info_cache=" %F{yellow}🐍 ${python_version}%f"
    fi
  fi
}

# ===== COMPONENTES DO PROMPT =====

_prompt_dir() {
  local dir="${PWD/#$HOME/~}"
  local parts=(${(s:/:)dir})
  
  if [[ ${#parts[@]} -gt 3 ]]; then
    echo "…/${parts[-3]}/${parts[-2]}/${parts[-1]}"
  else
    echo "$dir"
  fi
}

_prompt_char() {
  if [[ $_show_exit_color == true ]]; then
    # Mostra cor baseada no último comando executado
    if [[ $_last_exit_status -eq 0 ]]; then
      echo "%F{green}%B\$%b%f"
    else
      echo "%F{red}%B\$%b%f"
    fi
  else
    # Cor padrão branca antes da execução
    echo "%F{white}%B\$%b%f"
  fi
}

# ===== DEFINIÇÃO DO PROMPT =====

PROMPT='%F{cyan}$(_prompt_dir)%f${_git_info_cache}${_nodejs_info_cache}${_python_info_cache} $(_prompt_char) '

# RPROMPT removido, pois as durações agora são impressas persistentemente na tela
RPROMPT=''

# ===== CONFIGURAÇÕES ANTI-FLICKER =====

# CRÍTICO: Configurações para eliminar movimento de cursor
setopt prompt_cr              # Permite controle manual do CR
setopt prompt_sp              # Preserva output parcial
unsetopt promptsubst 2>/dev/null  # Desabilita temporariamente

# Re-habilita PROMPT_SUBST (necessário para funções)
setopt PROMPT_SUBST

# Desabilita marca de fim de linha
typeset -g PROMPT_EOL_MARK=''

# EXPERIMENTAL: Força redraw completo em vez de incremental
setopt transient_rprompt 2>/dev/null

# Reduz delay de teclado ao mínimo
KEYTIMEOUT=1

# CRÍTICO: Força região de scroll completa (evita movimento parcial)
print -n '\e[r'
