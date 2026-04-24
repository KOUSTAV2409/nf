# nf — Note Fast

A minimal terminal note-taking tool for Linux and macOS.

Capture a command or thought in one line. Find it later in seconds.
No cloud. No account. No setup. Just your terminal.

---

## Demo

```bash
$ nf "fuser -k 3000/tcp — kills process on port 3000"
Note saved.

$ nf "ss -tulpn | grep LISTEN — shows all listening ports"
Note saved.

$ nf list
 1  2025-04-25  fuser -k 3000/tcp — kills process on port 3000
 2  2025-04-25  ss -tulpn | grep LISTEN — shows all listening ports

$ nf search port
 1  2025-04-25  fuser -k 3000/tcp — kills process on port 3000
 2  2025-04-25  ss -tulpn | grep LISTEN — shows all listening ports
```

---

## Install

**One-liner:**

```bash
curl -sL https://nf.iamk.xyz/install | bash
```

**Manual:**

```bash
git clone https://github.com/KOUSTAV2409/nf.git
cd nf
chmod +x nf.sh
sudo ln -s "$(pwd)/nf.sh" /usr/local/bin/nf
```

---

## Usage

| Command | Description |
|---|---|
| `nf "text"` | Save a new note |
| `nf` | Open TUI (requires fzf) or list notes |
| `nf list` | List all notes |
| `nf search <term>` | Search notes (case-insensitive) |
| `nf del <number>` | Delete a note by number |
| `nf edit` | Open notes in `$EDITOR` |
| `nf count` | Show total number of notes |
| `nf help` | Show help |
| `nf version` | Show version |

---

## TUI Mode

If [fzf](https://github.com/junegunn/fzf) is installed, running `nf` with no arguments opens an interactive fuzzy finder.

- **Enter** — copy selected note to clipboard
- **Ctrl-D** — delete selected note
- **Esc** — quit

fzf is optional. Without it, `nf` falls back to `nf list`.

```bash
# Install fzf
sudo apt install fzf        # Ubuntu/Debian
sudo pacman -S fzf           # Arch
sudo dnf install fzf         # Fedora
brew install fzf             # macOS (Homebrew)
```

---

## Notes are stored at

```
~/.local/share/nf/notes
```

It's a plain text file — one note per line, date-prefixed. You can read it with `cat`, search it with `grep`, back it up with `cp`, edit it with any text editor. No lock-in.

```
2025-04-25 fuser -k 3000/tcp — kills process on port 3000
2025-04-25 ss -tulpn | grep LISTEN — shows all listening ports
```

---

## Why nf?

- **Fast.** One command to save. One command to search. Under 3 seconds.
- **Local.** No cloud, no account, no internet required.
- **Plain text.** Your notes are a single readable file. grep it, cat it, back it up.
- **No setup.** Install and use immediately. No config, no init, no database.
- **Open source.** MIT licensed. Fork it, extend it, make it yours.

---

## Uninstall

```bash
curl -sL https://nf.iamk.xyz/uninstall | bash
```

Or manually:

```bash
sudo rm /usr/local/bin/nf
rm -rf ~/.local/share/nf  # optional: delete your notes
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

[MIT](LICENSE)
