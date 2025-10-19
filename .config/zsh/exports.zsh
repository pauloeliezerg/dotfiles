# ================================================================
# .zsh_exports - Variáveis de ambiente
# ================================================================

# PATH
typeset -U path PATH
path=(
  $HOME/.local/bin
  $HOME/.cargo/bin 
  $path
)
export PATH
