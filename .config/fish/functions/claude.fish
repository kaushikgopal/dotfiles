function claude --description "Claude with olive wrapper"
    set -l filtered_argv (string match -v -- '--yolo' --dangerously-skip-permissions $argv)
    if command -q olive
        echo (set_color brblack)"wrapping with 🫒"(set_color normal)
        olive claude --dangerously-skip-permissions $filtered_argv
    else
        command claude --dangerously-skip-permissions $filtered_argv
    end
end
