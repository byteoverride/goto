# goto shell integration
# Source this file in your ~/.bashrc or ~/.zshrc:
#   source /path/to/goto.sh

GOTO_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/goto/config"

goto() {
    case "$1" in
        -*)  command goto "$@" ;;
        "")  command goto ;;
        *)
            local result rc
            result=$(command goto "$@" 2>&1)
            rc=$?
            if [ $rc -eq 0 ] && [ -d "$result" ]; then
                cd "$result" || return 1
            else
                printf '%s\n' "$result" >&2
                return $rc
            fi
            ;;
    esac
}

# Bash completion
if [ -n "$BASH_VERSION" ]; then
    _goto_complete() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        [ -f "$GOTO_CONFIG_FILE" ] || return

        case "$cur" in
            */*)
                local name="${cur%%/*}"
                local subpath="${cur#*/}"
                local base
                base=$(grep "^${name}|" "$GOTO_CONFIG_FILE" | head -1 | cut -d'|' -f2-)
                if [ -n "$base" ] && [ -d "$base" ]; then
                    local prefix="${name}/"
                    local fullpath="${base}/${subpath}"
                    local dirpath
                    dirpath=$(dirname "$fullpath")/
                    COMPREPLY=()
                    local dir
                    for dir in "${base}/${subpath}"*/; do
                        [ -d "$dir" ] || continue
                        local relative="${dir#"${base}/"}"
                        relative="${relative%/}"
                        COMPREPLY+=("${prefix}${relative}")
                    done
                fi
                ;;
            *)
                COMPREPLY=( $(cut -d'|' -f1 "$GOTO_CONFIG_FILE" | grep -i "^$cur") )
                ;;
        esac
    }
    complete -o nospace -F _goto_complete goto
fi

# Zsh completion
if [ -n "$ZSH_VERSION" ]; then
    _goto_complete() {
        [ -f "$GOTO_CONFIG_FILE" ] || return

        local input="${words[2]}"
        case "$input" in
            */*)
                local name="${input%%/*}"
                local subpath="${input#*/}"
                local base
                base=$(grep "^${name}|" "$GOTO_CONFIG_FILE" | head -1 | cut -d'|' -f2-)
                if [ -n "$base" ] && [ -d "$base" ]; then
                    local -a subdirs
                    local dir
                    for dir in "${base}/${subpath}"*/; do
                        [ -d "$dir" ] || continue
                        local relative="${dir#"${base}/"}"
                        relative="${relative%/}"
                        subdirs+=("${name}/${relative}")
                    done
                    compadd -S '/' -q -- "${subdirs[@]}"
                fi
                ;;
            *)
                local -a shortcuts
                shortcuts=(${(f)"$(cut -d'|' -f1 "$GOTO_CONFIG_FILE" 2>/dev/null)"})
                _describe -t shortcuts 'goto shortcuts' shortcuts
                ;;
        esac
    }
    compdef _goto_complete goto
fi
