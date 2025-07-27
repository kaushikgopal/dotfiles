function fish_mode_prompt
    switch $fish_bind_mode
        case default
            set_color --bold blue
            echo ' : '  # Normal mode
        case insert
            set_color --bold green
            echo ' > '  # Insert mode
        case replace_one
            set_color --bold red
            echo ' < '  # Replace mode
        case visual
            set_color --bold magenta
            echo ' V '  # Visual mode
        case '*'
            set_color normal
            echo ''
    end
    set_color normal
end