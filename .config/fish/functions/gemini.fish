function gemini --description "Gemini with olive wrapper"
    if command -q olive
        echo -e "\033[90mwrapping with 🫒\033[0m"
        olive gemini --yolo $argv
    else
        command gemini --yolo $argv
    end
end
