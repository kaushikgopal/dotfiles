function fish_mode_prompt
    __kg_prompt_palette_load

    switch $fish_bind_mode
        case default
            set_color --bold $__kg_prompt_mode_default
            echo ' : '  # Normal mode
        case insert
            set_color --bold $__kg_prompt_mode_insert
            echo ' > '  # Insert mode
        case replace_one
            set_color --bold $__kg_prompt_mode_replace
            echo ' < '  # Replace mode
        case visual
            set_color --bold $__kg_prompt_mode_visual
            echo ' V '  # Visual mode
        case '*'
            set_color normal
            echo ''
    end
    set_color normal
end
