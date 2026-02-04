# 🧭 goto — A Friendly Directory Shortcut Manager for Bash & Zsh

`goto` is a lightweight, interactive, and POSIX-compatible shell tool that lets you register directory shortcuts and jump to them with ease.

> 💡 No aliases. No clutter. Just clean shortcut navigation for your terminal life.

---

## ✨ Features

- 📁 Register named shortcuts to any directory
- 💨 Instantly jump to a shortcut (`goto name`)
- 🧠 Autocomplete shortcut names in Bash or Zsh
- 🛡️ No sudo, system files, or environment hacks
- 📦 Portable: Works in Bash, Zsh, and Dash

---

## 🔧 Installation

### 1. Clone & Install

```bash
git clone https://github.com/byteoverride/goto.git
cd goto
./install.sh
```

### 2. Update Shell Config

Add the following to your `~/.bashrc` or `~/.zshrc`:

```bash
source ~/.local/bin/goto.sh
```

Restart your shell or run `source ~/.bashrc` (or `~/.zshrc`).

---

## Usage 

### Register a Directory
```bash
# Register current directory as 'work'
goto -r work .

# Register specific path
goto -r tools /home/username/Documents/tools
```
> **Note:** `goto` automatically resolves paths to their absolute location, so you can safely register relative paths like `.` or `..`.

### List Registered Directories 
```bash
goto -l
```

### Use the shortcut
```bash
goto work
```

### Remove a shortcut
```bash
goto -d work
# OR
goto -u work
```





