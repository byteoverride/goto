# goto shell integration
# Source this file in your ~/.bashrc or ~/.zshrc

goto() {
    if [ "$1" = "-r" ] || [ "$1" = "-l" ] || [ "$1" = "-h" ] || [ "$1" = "-d" ] || [ "$1" = "-u" ]; then
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

# Bash completion
if [ -n "$BASH_VERSION" ]; then
    _goto_complete() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        if [ -f "$HOME/.config/goto/config" ]; then
            COMPREPLY=( $(cut -d'|' -f1 "$HOME/.config/goto/config" | grep -i "^$cur") )
        fi
    }
    complete -F _goto_complete goto
fi

# Zsh completion
if [ -n "$ZSH_VERSION" ]; then
    _goto_complete() {
        local shortcuts
        if [ -f "$HOME/.config/goto/config" ]; then
            shortcuts=(${(f)"$(cut -d'|' -f1 ~/.config/goto/config 2>/dev/null)"})
            _describe -t shortcuts 'goto shortcuts' shortcuts
        fi
    }
    compdef _goto_complete goto
fi
