function codex --description "Codex with olive wrapper"
    if command -q olive
        echo -e "\033[90mwrapping with 🫒\033[0m"
        olive codex --yolo $argv
    else
        command codex --yolo $argv
    end
end
