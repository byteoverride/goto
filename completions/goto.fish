# goto - Fish shell integration and completion
# Source this file in ~/.config/fish/config.fish:
#   source /path/to/goto.fish

function goto --description "Directory shortcut manager"
    if test (count $argv) -eq 0
        command goto
        return
    end

    switch $argv[1]
        case '-*'
            command goto $argv
        case '*'
            set -l result (command goto $argv 2>&1)
            set -l rc $status
            if test $rc -eq 0; and test -d "$result"
                cd "$result"
            else
                echo $result >&2
                return $rc
            end
    end
end

set -l __goto_config_file (set -q XDG_CONFIG_HOME; and echo "$XDG_CONFIG_HOME"; or echo "$HOME/.config")"/goto/config"

complete -c goto -f
complete -c goto -n "not __fish_seen_subcommand_from -r -d -u -R -l -c -h -V --help --version --list --cleanup --export --import" \
    -a "(test -f '$__goto_config_file'; and cut -d'|' -f1 '$__goto_config_file')"
complete -c goto -s r -d "Register shortcut (default: current dir)"
complete -c goto -s d -d "Delete a shortcut"
complete -c goto -s u -d "Delete a shortcut (alias)"
complete -c goto -s R -d "Rename a shortcut"
complete -c goto -s l -l list -d "List all shortcuts"
complete -c goto -s c -l cleanup -d "Remove broken shortcuts"
complete -c goto -s h -l help -d "Show help"
complete -c goto -s V -l version -d "Show version"
complete -c goto -l export -d "Export shortcuts to stdout"
complete -c goto -l import -d "Import shortcuts from file"
