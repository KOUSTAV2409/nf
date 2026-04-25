#!/usr/bin/env bash
# nf — Note Fast
# A minimal note-taking tool for the terminal (Linux & macOS)
# https://github.com/KOUSTAV2409/nf
# MIT License

set -euo pipefail

NF_VERSION="0.2.0"
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

# Interactive fzf menu for managing notes
nf_edit_fzf() {
  while true; do
    clear
    echo -e "${C_BOLD}Edit mode — Select an action${C_RESET}"
    echo "--------------------------------"
    local choice
    choice=$(echo -e "📝 Add new note\n🗑️  Delete note\n👁️  View all notes\n📂 Edit raw file\n❌ Quit" | fzf \
      --prompt="action > " \
      --height=15 \
      --border \
      --no-info \
      --header="Use arrows to select, Enter to confirm") || return 0

    case "$choice" in
      *"Add new note"*)
        echo -n "Enter note: "
        read -r new_note
        [ -n "$new_note" ] && nf_add "$new_note"
        echo -e "\nPress Enter to continue..."
        read -r
        ;;
      *"Delete note"*)
        local to_del
        to_del=$(nf_list_raw | fzf --prompt="delete > " --header="Select note to delete" --height=15)
        if [ -n "$to_del" ]; then
          local to_del_num
          read -r to_del_num _ <<< "$to_del"
          nf_del "$to_del_num"
          echo -e "\nPress Enter to continue..."
          read -r
        fi
        ;;
      *"View all notes"*)
        clear
        nf_list
        echo -e "\nPress Enter to return to menu..."
        read -r
        ;;
      *"Edit raw file"*)
        nf_edit_raw
        ;;
      *"Quit"*)
        return 0
        ;;
    esac
  done
}

# Fallback bash menu for systems without fzf
nf_edit_menu() {
  while true; do
    clear
    echo -e "${C_BOLD}Edit mode — Select an action${C_RESET}"
    echo "--------------------------------"
    echo "1) 📝 Add new note"
    echo "2) 🗑️  Delete note"
    echo "3) 👁️  View all notes"
    echo "4) 📂 Edit raw file"
    echo "5) ❌ Quit"
    echo ""
    echo -n "Choice [1-5]: "
    read -r choice

    case "$choice" in
      1)
        echo -n "Enter note: "
        read -r new_note
        [ -n "$new_note" ] && nf_add "$new_note"
        echo -e "\nPress Enter to continue..."
        read -r
        ;;
      2)
        nf_list
        echo -n "Note number to delete: "
        read -r num
        [ -n "$num" ] && nf_del "$num"
        echo -e "\nPress Enter to continue..."
        read -r
        ;;
      3)
        clear
        nf_list
        echo -e "\nPress Enter to return to menu..."
        read -r
        ;;
      4)
        nf_edit_raw
        ;;
      5|q|Q)
        return 0
        ;;
    esac
  done
}

# Original edit logic with UX improvements
nf_edit_raw() {
  nf_ensure_storage
  touch "$NF_FILE"

  local lockfile="$NF_DIR/.lock"
  if [ -f "$lockfile" ]; then
    echo -e "${C_RED}⚠ Notes are already being edited in another window.${C_RESET}"
    echo "Please close that session first or delete $lockfile if this is an error."
    echo -e "\nPress Enter to continue..."
    read -r
    return 1
  fi

  # Create lock and ensure cleanup
  touch "$lockfile"
  trap 'rm -f "$lockfile"' EXIT INT TERM

  local editor="${EDITOR:-}"
  if [ -z "$editor" ]; then
    if command -v nano &>/dev/null; then editor="nano";
    elif command -v vi &>/dev/null; then editor="vi";
    else
      echo "No editor found. Set \$EDITOR or install nano/vi."
      rm -f "$lockfile"
      return 1
    fi
  fi

  # Optimization: Use -n for vim/nvim and inject a persistent statusline guide
  if [[ "$editor" == *"vim"* ]] || [[ "$editor" == *"nvim"* ]]; then
    "$editor" -n \
      -c "set laststatus=2" \
      -c "set statusline=%#PmenuSel#\ NF\ Guide:\ i=Insert\ \ \ Esc\ :wq=Save/Exit\ \ \ :q!=Quit\ " \
      "$NF_FILE"
  elif [[ "$editor" == *"nano"* ]]; then
    "$editor" "$NF_FILE"
  else
    "$editor" "$NF_FILE"
  fi

  rm -f "$lockfile"
  trap - EXIT INT TERM
}

# Dispatcher for edit mode
nf_edit() {
  if command -v fzf &>/dev/null; then
    nf_edit_fzf
  else
    nf_edit_menu
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
    local _num _date content
    # selected is "num  date  content"
    read -r _num _date content <<< "$selected"
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
A minimal terminal note-taking tool for Linux & macOS.

Usage:
  nf "text"         Save a new note
  nf                Open TUI (requires fzf) or list notes
  nf list           List all notes
  nf search <term>  Search notes (case-insensitive)
  nf del <number>   Delete a note by number
  nf edit           Interactive menu to manage notes
  nf count          Show total number of notes
  nf update         Check for updates and upgrade
  nf help           Show this help
  nf version        Show version

Notes are stored at: $NF_FILE
EOF
}

# Update nf to latest version from web
nf_update() {
  echo "🔄 Updating nf to latest version..."
  if curl -sL https://nf.iamk.xyz/install | bash; then
    # Use $BASH instead of $SHELL to be safe about the current binary
    local new_ver
    new_ver=$(nf version 2>/dev/null | awk '{print $2}' || echo "unknown")
    echo -e "${C_GREEN}✅ Update complete! You're now on: v$new_ver${C_RESET}"
  else
    echo -e "${C_RED}❌ Update failed.${C_RESET} Try: curl -sL https://nf.iamk.xyz/install | bash"
    return 1
  fi
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
    update|--update|-u)
      nf_update
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
