# goto - Directory Shortcut Manager

[![CI](https://github.com/byteoverride/goto/actions/workflows/ci.yml/badge.svg)](https://github.com/byteoverride/goto/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](CHANGELOG.md)

A lightweight, POSIX-compatible directory bookmark manager for Bash, Zsh, and Fish.

Register named shortcuts to directories and jump to them instantly — with tab completion and subpath navigation.

```
$ goto -r work ~/Projects/myapp
[ok] Registered: 'work' -> /home/user/Projects/myapp

$ goto work
/home/user/Projects/myapp $

$ goto work/src/components
/home/user/Projects/myapp/src/components $
```

## Features

- **Bookmark any directory** — register with `goto -r name` or `goto -r name /path`
- **Subpath navigation** — `goto project/src/lib` jumps into subdirectories
- **Tab completion** — shortcut names and subpaths complete in all shells
- **Cleanup** — remove broken shortcuts pointing to deleted directories
- **Import/export** — back up or transfer shortcuts between machines
- **Zero dependencies** — pure POSIX shell, no Python/Ruby/Rust needed
- **XDG compliant** — respects `$XDG_CONFIG_HOME`
- **Shell support** — Bash, Zsh, and Fish

## Installation

### User-local install (recommended for personal use)

```sh
git clone https://github.com/byteoverride/goto.git
cd goto
./install.sh
```

Then add to your shell config:

```sh
# Bash (~/.bashrc) or Zsh (~/.zshrc)
source ~/.local/bin/goto.sh
```

Fish integration is installed automatically if Fish is detected.

### System-wide install

```sh
sudo make install PREFIX=/usr
```

Then add to your shell config:

```sh
# Bash (~/.bashrc) or Zsh (~/.zshrc)
source /usr/share/goto/goto.sh
```

Fish completions are loaded automatically from the system path.

### Arch Linux (AUR)

```sh
yay -S goto-dir
```

### Uninstall

```sh
# User-local
rm ~/.local/bin/goto ~/.local/bin/goto.sh

# System-wide
sudo make uninstall PREFIX=/usr
```

## Usage

### Register a shortcut

```sh
# Save current directory
goto -r work

# Save a specific path
goto -r docs ~/Documents

# Relative paths are resolved automatically
goto -r parent ..
```

### Jump to a shortcut

```sh
goto work
goto docs
```

### Navigate into subdirectories

```sh
goto work/src/components
goto docs/api/v2
```

### List all shortcuts

```sh
goto -l
```

Output shows valid shortcuts and marks missing paths:

```
Registered shortcuts:

  work            -> /home/user/Projects/myapp
  docs            -> /home/user/Documents
  old-project     -> /home/user/Projects/deleted (missing)
```

### Delete a shortcut

```sh
goto -d work
```

### Rename a shortcut

```sh
goto -R work office
```

### Clean up broken shortcuts

```sh
goto -c
```

### Import and export

```sh
# Back up shortcuts
goto --export > ~/goto-backup.txt

# Restore on another machine
goto --import ~/goto-backup.txt
```

## Configuration

Shortcuts are stored in a plain-text file:

```
~/.config/goto/config
```

Or `$XDG_CONFIG_HOME/goto/config` if `XDG_CONFIG_HOME` is set.

Format is one shortcut per line, pipe-delimited:

```
work|/home/user/Projects/myapp
docs|/home/user/Documents
```

You can edit this file directly if needed.

## How It Works

`goto` is split into two parts:

1. **`goto` (binary)** — a POSIX shell script that manages the config file and resolves shortcuts. It outputs the resolved path to stdout.

2. **`goto.sh` (shell integration)** — a shell function that wraps the binary, captures its output, and calls `cd`. This is why you need to `source` it — shell functions can change the current directory, standalone scripts cannot.

## Comparison with Similar Tools

| Feature | goto | autojump | z / zoxide | fasd |
|---------|------|----------|------------|------|
| Explicit bookmarks | Yes | No | No | No |
| Learning/frecency | No | Yes | Yes | Yes |
| Zero dependencies | Yes | Python | Rust (zoxide) | POSIX |
| Subpath navigation | Yes | No | No | No |
| Import/export | Yes | No | No | No |
| Config is plain text | Yes | No | No | No |

`goto` takes a different approach: explicit bookmarks instead of implicit learning. You control exactly which directories have shortcuts and what they're called. No database, no training period, no surprises.

## Development

```sh
# Run tests
make test

# Run shellcheck
make lint

# Test the install process
make install DESTDIR=/tmp/goto-test PREFIX=/usr
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

[MIT](LICENSE) - Psalms Christopher Matovu
