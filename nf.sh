#!/usr/bin/env bash
# nf — Note Fast
# A minimal note-taking tool for the terminal (Linux & macOS)
# https://github.com/KOUSTAV2409/nf
# MIT License

set -euo pipefail

NF_VERSION="0.3.4"
NF_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nf"
# Override with NF_NOTES_FILE to store notes elsewhere (plain text file).
NF_FILE="${NF_NOTES_FILE:-$NF_DIR/notes}"

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
  C_DIM='\033[2m'      # dim text
else
  C_NUM='' C_DATE='' C_TEXT='' C_RESET='' C_GREEN='' C_RED='' C_BOLD='' C_DIM=''
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

# Print notes as a numbered list. Pass "raw" for plain output (fzf).
nf_list_print() {
  local mode="${1:-color}"

  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    if [ "$mode" = "color" ]; then
      echo 'No notes yet. Add one with: nf "your note"'
    fi
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
    if [ "$mode" = "raw" ]; then
      printf "%${width}d  %s  %s\n" "$line_num" "$date" "$content"
    else
      printf "${C_NUM}%${width}d${C_RESET}  ${C_DATE}%s${C_RESET}  ${C_TEXT}%s${C_RESET}\n" \
        "$line_num" "$date" "$content"
    fi
  done < "$NF_FILE"
}

nf_list() {
  nf_list_print color
}

nf_list_raw() {
  nf_list_print raw
}

# Case-insensitive search through notes
nf_search() {
  local cmd_name="${1:-search}"
  local term="${2:-}"
  if [ -z "$term" ]; then
    echo "Usage: nf $cmd_name <term>"
    return 1
  fi

  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    echo "No notes matching \"$term\"."
    return
  fi

  local total line_num date content found=0
  total=$(wc -l < "$NF_FILE")
  local width=${#total}

  line_num=0
  while IFS= read -r line; do
    line_num=$((line_num + 1))
    # Case-insensitive match using bash pattern (convert both to lowercase)
    if echo "$line" | grep -qiF -- "$term"; then
      date="${line%% *}"
      content="${line#* }"
      content=$(echo "$content" | GREP_COLORS='ms=01;33' grep -iF --color=always -- "$term" || echo "$content")
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

# Export one note by list number to note-<n>.txt (content only, no date prefix).
nf_export_one() {
  local num="$1"
  local total note_line content outfile

  if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -eq 0 ]; then
    echo "Note $num not found."
    return 1
  fi

  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    echo "Note $num not found."
    return 1
  fi

  total=$(wc -l < "$NF_FILE")
  if [ "$num" -gt "$total" ]; then
    echo "Note $num not found."
    return 1
  fi

  note_line=$(sed -n "${num}p" "$NF_FILE")
  content="${note_line#* }"
  outfile="note-${num}.txt"

  printf '%s\n' "$content" > "$outfile"
  echo -e "${C_GREEN}Exported note $num to ${outfile}${C_RESET}"
}

# Export the full notebook (every line, as stored) to notes-YYYY-MM-DD.txt.
nf_export_all() {
  if [ ! -f "$NF_FILE" ] || [ ! -s "$NF_FILE" ]; then
    echo "No notes to export."
    return 1
  fi

  local outfile
  outfile="notes-$(date +%Y-%m-%d).txt"
  cp "$NF_FILE" "$outfile"
  echo -e "${C_GREEN}Exported all notes to ${outfile}${C_RESET}"
}

# Export one or more notes by number, or everything with "all".
nf_export() {
  if [ $# -eq 0 ]; then
    echo "Usage: nf export <number> [number...] | nf export all"
    return 1
  fi

  if [ "$1" = "all" ]; then
    if [ $# -gt 1 ]; then
      echo "Usage: nf export all"
      return 1
    fi
    nf_export_all
    return
  fi

  local num failed=0
  for num in "$@"; do
    if ! nf_export_one "$num"; then
      failed=1
    fi
  done
  return "$failed"
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
    local locking_pid
    locking_pid=$(cat "$lockfile" 2>/dev/null || echo "")
    # Check if the process that created the lock is still alive
    if [ -n "$locking_pid" ] && kill -0 "$locking_pid" 2>/dev/null; then
      echo -e "${C_RED}⚠ Notes are already being edited by process $locking_pid.${C_RESET}"
      echo "Please close that session first."
      echo -e "\nPress Enter to continue..."
      read -r
      return 1
    else
      # Stale lock detected (process is dead) - remove it
      rm -f "$lockfile"
    fi
  fi

  # Create lock with current PID
  echo "$$" > "$lockfile"

  # Store lockfile path globally for the trap to prevent unbound variable errors at exit
  _NF_CURRENT_LOCKFILE="$lockfile"
  trap 'rm -f "$_NF_CURRENT_LOCKFILE"' EXIT INT TERM

  local editor="${EDITOR:-}"
  if [ -z "$editor" ] || ! command -v "$editor" &>/dev/null; then
    if command -v nano &>/dev/null; then editor="nano";
    elif command -v vi &>/dev/null; then editor="vi";
    elif command -v vim &>/dev/null; then editor="vim";
    elif command -v nvim &>/dev/null; then editor="nvim";
    else
      echo "No editor found. Set \$EDITOR or install nano/vi."
      rm -f "$lockfile"
      return 1
    fi
  fi

  # Optimization: Use -n for vim/nvim and inject modern shortcuts + persistent guide
  if [[ "$editor" == *"vim"* ]] || [[ "$editor" == *"nvim"* ]]; then
    # Disable terminal flow control so Ctrl+S works for saving
    stty -ixon 2>/dev/null || true
    
    "$editor" -n \
      -c "set laststatus=2" \
      -c "set statusline=%#PmenuSel#\ NF\ Guide:\ i=Write\ \ \ Ctrl+S=Save\ \ \ Ctrl+D=Delete\ Line\ \ \ Ctrl+Q=Quit\ " \
      -c "noremap <C-s> :w<CR>" \
      -c "inoremap <C-s> <Esc>:w<CR>a" \
      -c "noremap <C-q> :q<CR>" \
      -c "inoremap <C-q> <Esc>:q<CR>" \
      -c "noremap <C-d> dd" \
      -c "inoremap <C-d> <Esc>dda" \
      "$NF_FILE"
    
    # Re-enable flow control
    stty ixon 2>/dev/null || true
  elif [[ "$editor" == *"nano"* ]]; then
    "$editor" "$NF_FILE"
  else
    # For other editors, show helpful message
    echo -e "${C_GREEN}Opening editor...${C_RESET}"
    echo -e "${C_DIM}Tip: Save and close when done. Your changes will be saved automatically.${C_RESET}"
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
    --bind="ctrl-d:execute(nf del {1})+reload(cat \"$NF_FILE\")" \
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
  nf find <term>    Alias for search
  nf del <number>   Delete a note by number
  nf export <n> [n...] Export note(s) to note-<n>.txt
  nf export all       Export entire notebook to notes-YYYY-MM-DD.txt
  nf edit           Interactive menu to manage notes
  nf count          Show total number of notes
  nf update         Check for updates and upgrade
  nf help           Show this help
  nf version        Show version

  Notes are stored at: $NF_FILE
  Override path:       NF_NOTES_FILE=/path/to/notes
EOF
}

# Check for updates subtly (reads cached status and triggers background check)
nf_check_for_updates() {
  local update_file="$NF_DIR/.update_available"
  if [ -f "$update_file" ]; then
    cat "$update_file"
  fi
  # Trigger background check
  (main check-update &>/dev/null &)
}

# Run the actual background check to fetch remote version and update cache
nf_check_for_updates_bg() {
  nf_ensure_storage
  local check_file="$NF_DIR/.last_check"
  local update_file="$NF_DIR/.update_available"
  local now
  now=$(date +%s)
  
  # Only check once every 24 hours (86400 seconds)
  if [ -f "$check_file" ]; then
    local last_check
    last_check=$(cat "$check_file")
    if [ "$((now - last_check))" -lt 86400 ]; then
      return
    fi
  fi
  
  echo "$now" > "$check_file"
  
  local remote_ver
  remote_ver=$(curl -sL --connect-timeout 2 "https://raw.githubusercontent.com/KOUSTAV2409/nf/main/nf.sh" | grep "NF_VERSION=" | head -1 | cut -d'"' -f2 || echo "")
  
  if [ -n "$remote_ver" ] && [ "$remote_ver" != "$NF_VERSION" ]; then
    # Write update message with ANSI color codes to cache file
    local c_dim='\033[2m'
    local c_reset='\033[0m'
    local c_yellow='\033[33m'
    
    local is_brew=false
    local binary_path
    binary_path=$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")
    if [[ "$binary_path" == *"/Cellar/"* ]] || [[ "$binary_path" == *"/homebrew/"* ]] || [[ "$binary_path" == *"/Homebrew/"* ]]; then
      is_brew=true
    fi
    
    if [ "$is_brew" = true ]; then
      echo -e "${c_yellow}💡${c_reset} ${c_dim}A new version of nf (v$remote_ver) is available. Run '${c_reset}brew upgrade KOUSTAV2409/tap/nf${c_dim}' to upgrade.${c_reset}" > "$update_file"
    else
      echo -e "${c_yellow}💡${c_reset} ${c_dim}A new version of nf (v$remote_ver) is available. Run '${c_reset}nf update${c_dim}' to upgrade.${c_reset}" > "$update_file"
    fi
  else
    # Clear the file if up-to-date
    rm -f "$update_file"
  fi
}

# Update nf to latest version from web
nf_update() {
  local binary_path
  binary_path=$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")
  if [[ "$binary_path" == *"/Cellar/"* ]] || [[ "$binary_path" == *"/homebrew/"* ]] || [[ "$binary_path" == *"/Homebrew/"* ]]; then
    echo -e "${C_RED}⚠ nf was installed via Homebrew.${C_RESET}"
    echo "Please upgrade it using Homebrew:"
    echo "  brew upgrade KOUSTAV2409/tap/nf"
    return 1
  fi

  echo "🔄 Updating nf to latest version..."
  if curl -sL https://nf.iamk.xyz/install | bash; then
    echo -e "${C_GREEN}✅ Update complete!${C_RESET}\n"
    
    # Show what's new
    echo -e "${C_BOLD}What's New:${C_RESET}"
    curl -sL --connect-timeout 5 "https://raw.githubusercontent.com/KOUSTAV2409/nf/main/WHATSNEW.txt" || echo "Check github.com/KOUSTAV2409/nf for details."
    echo ""
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
      nf_check_for_updates
      ;;
    list)
      nf_list
      nf_check_for_updates
      ;;
    search|find)
      nf_search "$1" "${2:-}"
      ;;
    del|delete|rm)
      nf_del "${2:-}"
      ;;
    export)
      shift
      nf_export "$@"
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
    check-update|--check-update)
      nf_check_for_updates_bg
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
