# Bash completion for nf
_nf_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local commands="list search find del delete rm edit count update help version"
  
  if [[ ${COMP_CWORD} -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "${commands}" -- "${cur}") )
  fi
}
complete -F _nf_completions nf
