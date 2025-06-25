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

### 1. Clone the repo

```bash
git clone https://github.com/byteoverride/goto.git
cd goto
```

```bash
mkdir -p ~/.local/bin
cp goto ~/.local/bin/
chmod +x ~/.local/bin/goto
```

## Add the Shell function to your shell Config
###For bash (~/.bashrc)

```bash
goto() {
    if [ "$1" = "-r" ] || [ "$1" = "-l" ] || [ "$1" = "-h" ] || [ "$1" = "-d" ]; then
        command goto "$@"
    else
        local result
        result=$(command goto "$1" 2>/dev/null)
        if [ -d "$result" ]; then
            cd "$result"
        else
            echo "$result"
            return 1
        fi
    fi
}
_goto_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(cut -d'|' -f1 "$HOME/.config/goto/config" | grep -i "^$cur") )
}
complete -F _goto_complete goto

```

### For Zsh (~/.zshrc)

```bash
goto() {
    if [ "$1" = "-r" ] || [ "$1" = "-l" ] || [ "$1" = "-h" ] || [ "$1" = "-d" ]; then
        command goto "$@"
    else
        local result
        result=$(command goto "$1" 2>/dev/null)
        if [ -d "$result" ]; then
            cd "$result"
        else
            echo "$result"
            return 1
        fi
    fi
}
_goto_complete() {
  local expl
  local shortcuts
  shortcuts=(${(f)"$(cut -d'|' -f1 ~/.config/goto/config 2>/dev/null)"})
  _describe -t shortcuts 'goto shortcuts' shortcuts
}
compdef _goto_complete goto
```
## Usage 
### Register a Directory
```bash
goto -r <shortcut_name> <Directory>

goto -r Tools /home/username/Documents/tools

```
![image](https://github.com/user-attachments/assets/c27d05d7-4ffe-4739-8a70-20129641fe04)

### List Registered Directories 
```bash
goto -l
```
![image](https://github.com/user-attachments/assets/f9f7a172-1dd7-454a-be0e-f2ba831778e6)

### Use the shortcut
```bash
goto <shortcut_name>
goto Tools
```
![image](https://github.com/user-attachments/assets/b487e943-a397-4ffa-aa05-f9b2d06d42dd)





