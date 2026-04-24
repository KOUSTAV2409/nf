# Contributing to nf

Thanks for your interest in contributing to nf! Here's how to get started.

---

## Local Development

```bash
# Clone the repo
git clone https://github.com/KOUSTAV2409/nf.git
cd nf

# Make the script executable
chmod +x nf.sh

# Run it locally
./nf.sh "test note"
./nf.sh list
./nf.sh search test
./nf.sh del 1
```

Notes are stored at `~/.local/share/nf/notes` by default. You can set `XDG_DATA_HOME` to test with a different location:

```bash
XDG_DATA_HOME=/tmp/nf_test ./nf.sh "test note"
```

---

## Code Style

- **Pure Bash.** No Python, Go, Rust, or Node. No compiled dependencies.
- **Single file.** `nf.sh` is the entire tool. Keep it that way.
- **`set -euo pipefail`** at the top. Always.
- **Functions** for each command (e.g., `nf_add`, `nf_list`, `nf_search`).
- **Comments** for non-obvious logic. Don't over-comment obvious code.
- **ShellCheck clean.** Run `shellcheck nf.sh` before submitting.

---

## Submitting a Pull Request

1. Fork the repo and create a feature branch.
2. Make your changes in the branch.
3. Test your changes locally (see above).
4. Run `shellcheck nf.sh` and fix any warnings.
5. Open a PR with a clear description of what you changed and why.

---

## What's Welcome

- Bug fixes
- New subcommands that fit the tool's philosophy (fast, minimal, no deps)
- Improved error messages
- Distro packaging (`.deb`, `.rpm`, AUR, etc.)
- Documentation improvements
- Shell completion scripts

---

## What to Avoid

- Adding non-Bash dependencies (Python, Node, Go, Rust, etc.)
- Breaking the single-file design of `nf.sh`
- Adding config files or init steps
- Adding network calls, telemetry, or cloud sync
- Adding categories, tags, or complex metadata — notes are freeform text
- Adding a database — storage is a plain text file

---

## Reporting Issues

Use the [issue templates](https://github.com/KOUSTAV2409/nf/issues/new/choose) to report bugs or request features.

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
