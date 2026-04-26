#compdef nf
# shellcheck shell=bash
# shellcheck disable=SC2034
# Zsh completion for nf

_nf() {
  local -a commands
  commands=(
    'list:List all notes'
    'search:Search through notes'
    'find:Alias for search'
    'del:Delete a note by number'
    'delete:Alias for del'
    'rm:Alias for del'
    'edit:Interactive menu to manage notes'
    'count:Show total number of notes'
    'update:Check for updates and upgrade'
    'help:Show help'
    'version:Show version'
  )

  if (( CURRENT == 2 )); then
    _describe -t commands 'nf commands' commands
  fi
}

_nf "$@"
