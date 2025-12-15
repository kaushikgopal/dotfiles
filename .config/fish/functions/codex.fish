function codex --description "Codex with olive wrapper"
    set -l filtered_argv (string match -v -- '--yolo' $argv)
    if command -q olive
        echo -e "\033[90mwrapping with 🫒\033[0m"
        olive codex --yolo $filtered_argv
    else
        command codex --yolo $filtered_argv
    end
end
