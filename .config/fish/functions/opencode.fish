# Use default opencode profile; pass --personal for personal account
function opencode
    if contains -- --personal $argv
        set -l filtered
        for arg in $argv
            if test "$arg" != --personal
                set -a filtered $arg
            end
        end
        env OPENCODE_CONFIG=~/.config/opencode/opencode-personal.json \
            XDG_DATA_HOME=~/.local/share/opencode-personal \
            XDG_STATE_HOME=~/.local/state/opencode-personal \
            command opencode $filtered
    else
        command opencode $argv
    end
end
