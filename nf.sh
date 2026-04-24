#!/usr/bin/env bash
# nf — Note Fast
# A minimal note-taking tool for the terminal (Linux & macOS)
# https://github.com/KOUSTAV2409/nf
# MIT License

set -euo pipefail

NF_VERSION="0.1.0"
NF_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nf"
NF_FILE="$NF_DIR/notes"

# --- color setup ---
# Detect whether the terminal supports color output.
# If stdout is a TTY and tput reports >= 8 colors, enable coloring.
if [ -t 1 ] && command -v tput &>/dev/null && [ "$(tput colors 2>/dev/null)" -ge 8 ]; then
  C_NUM='\033[2m'      # dim for line numbers
  C_DATE='\033[36m'    # cyan for dates
  C_TEXT='\033[0m'     # default for content
  C_RESET='\033[0m'
  C_GREEN='\033[32m'   # green for success messages
  C_RED='\033[31m'     # red for errors
  C_BOLD='\033[1m'     # bold
else
  C_NUM='' C_DATE='' C_TEXT='' C_RESET='' C_GREEN='' C_RED='' C_BOLD=''
fi

# --- ensure storage ---
# Create the storage directory on first use. The user never has to do this.
nf_ensure_storage() {
  mkdir -p "$NF_DIR"
}

# --- core functions ---

# Add a new note with today's date prefix
nf_add() {
  nf_ensure_storage
  local date_prefix
  date_prefix=$(date +%Y-%m-%d)
  echo "$date_prefix $*" >> "$NF_FILE"
  echo -e "${C_GREEN}Note saved.${C_RESET}"
}

# Print all notes as a numbered list with color formatting
nf_list() {
  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    echo 'No notes yet. Add one with: nf "your note"'
    return
  fi

  local total line_num date content
  total=$(wc -l < "$NF_FILE")
  # Calculate width needed for the largest line number
  local width=${#total}

  line_num=0
  while IFS= read -r line; do
    line_num=$((line_num + 1))
    # Split the line into date (first field) and content (rest)
    date="${line%% *}"
    content="${line#* }"
    printf "${C_NUM}%${width}d${C_RESET}  ${C_DATE}%s${C_RESET}  ${C_TEXT}%s${C_RESET}\n" \
      "$line_num" "$date" "$content"
  done < "$NF_FILE"
}

# Raw list output for fzf (numbered, no color)
nf_list_raw() {
  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    return
  fi

  local total line_num date content
  total=$(wc -l < "$NF_FILE")
  local width=${#total}

  line_num=0
  while IFS= read -r line; do
    line_num=$((line_num + 1))
    date="${line%% *}"
    content="${line#* }"
    printf "%${width}d  %s  %s\n" "$line_num" "$date" "$content"
  done < "$NF_FILE"
}

# Case-insensitive search through notes
nf_search() {
  if [ -z "${1:-}" ]; then
    echo "Usage: nf search <term>"
    return 1
  fi

  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    echo "No notes matching \"$1\"."
    return
  fi

  local term="$1"
  local total line_num date content found=0
  total=$(wc -l < "$NF_FILE")
  local width=${#total}

  line_num=0
  while IFS= read -r line; do
    line_num=$((line_num + 1))
    # Case-insensitive match using bash pattern (convert both to lowercase)
    if echo "$line" | grep -qi "$term"; then
      date="${line%% *}"
      content="${line#* }"
      printf "${C_NUM}%${width}d${C_RESET}  ${C_DATE}%s${C_RESET}  ${C_TEXT}%s${C_RESET}\n" \
        "$line_num" "$date" "$content"
      found=1
    fi
  done < "$NF_FILE"

  if [ "$found" -eq 0 ]; then
    echo "No notes matching \"$term\"."
  fi
}

# Delete a note by its line number
nf_del() {
  if [ -z "${1:-}" ]; then
    echo "Usage: nf del <number>"
    return 1
  fi

  local num="$1"

  # Validate that the argument is a positive integer
  if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -eq 0 ]; then
    echo "Note $num not found."
    return 1
  fi

  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    echo "Note $num not found."
    return 1
  fi

  local total
  total=$(wc -l < "$NF_FILE")

  if [ "$num" -gt "$total" ]; then
    echo "Note $num not found."
    return 1
  fi

  # Show what's being deleted
  local note_content
  note_content=$(sed -n "${num}p" "$NF_FILE")
  local content="${note_content#* }"
  echo "Deleting: \"$content\""

  # Delete the line using sed (in-place)
  # BSD sed (macOS) requires an empty backup extension; GNU sed does not
  if [[ "$OSTYPE" == darwin* ]]; then
    sed -i '' "${num}d" "$NF_FILE"
  else
    sed -i "${num}d" "$NF_FILE"
  fi
  echo "Deleted note $num."
}

# Open the notes file in the user's preferred editor
nf_edit() {
  nf_ensure_storage
  # Create the file if it doesn't exist so the editor doesn't complain
  touch "$NF_FILE"

  if [ -n "${EDITOR:-}" ]; then
    "$EDITOR" "$NF_FILE"
  elif command -v nano &>/dev/null; then
    nano "$NF_FILE"
  elif command -v vi &>/dev/null; then
    vi "$NF_FILE"
  else
    echo "No editor found. Set \$EDITOR or install nano/vi."
    return 1
  fi
}

# Print the total number of notes
nf_count() {
  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    echo "0"
    return
  fi
  wc -l < "$NF_FILE"
}

# TUI mode using fzf for interactive note browsing
nf_tui() {
  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    echo 'No notes yet. Add one with: nf "your note"'
    return
  fi

  local selected
  selected=$(nf_list_raw | fzf \
    --ansi \
    --prompt="notes > " \
    --header="enter: copy to clipboard | ctrl-d: delete | esc: quit" \
    --preview='echo {}' \
    --preview-window=up:3:wrap \
    --bind="ctrl-d:execute(nf del {1})+reload(cat $NF_FILE)" \
    --height=80% \
  ) || true  # Don't exit on esc/ctrl-c

  # On selection, copy the note content (without number and date) to clipboard
  if [ -n "$selected" ]; then
    local content
    content=$(echo "$selected" | sed 's/^[[:space:]]*[0-9]*[[:space:]]*[0-9-]*[[:space:]]*//')
    if command -v pbcopy &>/dev/null; then
      echo -n "$content" | pbcopy
      echo "Copied to clipboard."
    elif command -v xclip &>/dev/null; then
      echo -n "$content" | xclip -selection clipboard
      echo "Copied to clipboard."
    elif command -v xsel &>/dev/null; then
      echo -n "$content" | xsel --clipboard --input
      echo "Copied to clipboard."
    elif command -v wl-copy &>/dev/null; then
      echo -n "$content" | wl-copy
      echo "Copied to clipboard."
    else
      echo "$content"
    fi
  fi
}

# --- help text ---
nf_help() {
  cat <<EOF
nf — Note Fast (v$NF_VERSION)
A minimal terminal note-taking tool for Linux.

Usage:
  nf "text"         Save a new note
  nf                Open TUI (requires fzf) or list notes
  nf list           List all notes
  nf search <term>  Search notes (case-insensitive)
  nf del <number>   Delete a note by number
  nf edit           Open notes in \$EDITOR
  nf count          Show total number of notes
  nf help           Show this help
  nf version        Show version

Notes are stored at: $NF_FILE
EOF
}

# --- main command dispatcher ---
main() {
  case "${1:-}" in
    "")
      # No arguments: TUI if fzf is available, otherwise list
      if command -v fzf &>/dev/null; then
        nf_tui
      else
        nf_list
      fi
      ;;
    list)
      nf_list
      ;;
    search)
      nf_search "${2:-}"
      ;;
    del|delete|rm)
      nf_del "${2:-}"
      ;;
    edit)
      nf_edit
      ;;
    count)
      nf_count
      ;;
    help|--help|-h)
      nf_help
      ;;
    version|--version|-v)
      echo "nf $NF_VERSION"
      ;;
    *)
      # Anything else is treated as a note to add
      nf_add "$@"
      ;;
  esac
}

main "$@"
