function gws-personal
    set -lx GOOGLE_WORKSPACE_CLI_CONFIG_DIR "$HOME/.config/gws/personal"
    set -lx GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE "$HOME/.config/gws/personal/adc-personal.json"
    command gws $argv
end
