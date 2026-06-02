# Bash completion for nf
_nf_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local commands="list search find del delete rm edit count update help version"
  
  if [[ ${COMP_CWORD} -eq 1 ]]; then
    mapfile -t COMPREPLY < <(compgen -W "${commands}" -- "${cur}")
  fi
}
complete -F _nf_completions nf

# Subtle background update check on shell startup
if [ -t 1 ]; then
  NF_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nf"
  if [ -f "$NF_DIR/.update_available" ]; then
    cat "$NF_DIR/.update_available"
  fi
  # Trigger background check
  (nf check-update &>/dev/null &)
fi
