function __kg_prompt_palette_load --description 'Load prompt colors for Ghostty Dracula themes'
    set -l mode light

    if command -sq defaults
        defaults read -g AppleInterfaceStyle >/dev/null 2>/dev/null
        and set mode dark
    end

    if set -q __kg_prompt_palette_mode
        if test "$__kg_prompt_palette_mode" = "$mode"
            return
        end
    end

    set -g __kg_prompt_palette_mode $mode

    if test "$mode" = dark
        set -g __kg_prompt_cwd '#b7b2cc'
        set -g __kg_prompt_branch '#9580ff'
        set -g __kg_prompt_upstream '#ff80bf'
        set -g __kg_prompt_staged '#8aff80'
        set -g __kg_prompt_unstaged '#ff9580'
        set -g __kg_prompt_misc '#80ffea'
        set -g __kg_prompt_label '#ffff80'
        set -g __kg_prompt_dim '#6e6887'
        set -g __kg_prompt_mode_default '#9580ff'
        set -g __kg_prompt_mode_insert '#8aff80'
        set -g __kg_prompt_mode_replace '#ff9580'
        set -g __kg_prompt_mode_visual '#ff80bf'
    else
        set -g __kg_prompt_cwd '#625f72'
        set -g __kg_prompt_branch '#644ac9'
        set -g __kg_prompt_upstream '#a3144d'
        set -g __kg_prompt_staged '#14710a'
        set -g __kg_prompt_unstaged '#cb3a2a'
        set -g __kg_prompt_misc '#036a96'
        set -g __kg_prompt_label '#846e15'
        set -g __kg_prompt_dim '#8d899f'
        set -g __kg_prompt_mode_default '#644ac9'
        set -g __kg_prompt_mode_insert '#14710a'
        set -g __kg_prompt_mode_replace '#cb3a2a'
        set -g __kg_prompt_mode_visual '#a3144d'
    end
end
