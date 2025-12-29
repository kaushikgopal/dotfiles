function gemini --description "Gemini with olive wrapper"
    if command -q olive
        echo (set_color brblack)"wrapping with 🫒"(set_color normal)
        olive gemini --yolo $argv
    else
        command gemini --yolo $argv
    end
end
