function gws-work
    set -lx GOOGLE_WORKSPACE_CLI_CONFIG_DIR "$HOME/.config/gws/work"
    command gws $argv
end
