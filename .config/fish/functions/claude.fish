function claude --description "Claude with olive wrapper"
    set -l filtered_argv (string match -v -- '--yolo' --dangerously-skip-permissions $argv)
    if command -q olive
        echo -e "\033[90mwrapping with 🫒\033[0m"
        olive claude --dangerously-skip-permissions $filtered_argv
    else
        command claude --dangerously-skip-permissions $filtered_argv
    end
end
