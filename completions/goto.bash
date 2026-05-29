# goto - Bash completion
# Installed to /usr/share/bash-completion/completions/goto by make install

_goto_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local config="${XDG_CONFIG_HOME:-$HOME/.config}/goto/config"
    [ -f "$config" ] || return

    case "$cur" in
        */*)
            local name="${cur%%/*}"
            local subpath="${cur#*/}"
            local base
            base=$(grep "^${name}|" "$config" | head -1 | cut -d'|' -f2-)
            if [ -n "$base" ] && [ -d "$base" ]; then
                local prefix="${name}/"
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
            COMPREPLY=( $(cut -d'|' -f1 "$config" | grep -i "^$cur") )
            ;;
    esac
}
complete -o nospace -F _goto_complete goto
