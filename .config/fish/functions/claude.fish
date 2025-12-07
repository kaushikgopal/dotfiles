function claude --description "Claude with olive wrapper"
    if command -q olive
        echo -e "\033[90mwrapping with 🫒\033[0m"
        olive claude --dangerously-skip-permissions $argv
    else
        command claude --dangerously-skip-permissions $argv
    end
end
