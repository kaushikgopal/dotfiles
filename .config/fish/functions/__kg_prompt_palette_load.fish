function __kg_prompt_palette_load --description 'Map the active fish theme file to prompt roles'
    # fish stores the chosen theme name in `--theme=...` markers, but prompt code
    # still needs concrete colors for prompt-only roles like git state and vi mode.
    # Read those values from the active `.theme` file so the theme file stays the
    # single source of truth for both fish-native colors and prompt accents.

    set -l theme_name dracpro
    for token in $fish_color_cwd $fish_color_normal $fish_pager_color_prefix
        if string match -q -- '--theme=*' $token
            set theme_name (string replace -r '^--theme=' '' -- $token)
            break
        end
    end

    set -l color_theme unknown
    if set -q fish_terminal_color_theme[1]
        set color_theme $fish_terminal_color_theme[1]
    end

    if set -q __kg_prompt_theme_name __kg_prompt_theme_variant __kg_prompt_cwd __kg_prompt_branch
        and test "$__kg_prompt_theme_name" = "$theme_name"
        and test "$__kg_prompt_theme_variant" = "$color_theme"
        return
    end

    set -l theme_path "$HOME/.config/fish/themes/$theme_name.theme"
    if set -q XDG_CONFIG_HOME[1]
        set theme_path "$XDG_CONFIG_HOME/fish/themes/$theme_name.theme"
    end

    set -l cwd_color brblue
    set -l user_color brgreen
    set -l host_color brblue
    set -l host_remote_color bryellow
    set -l status_color red
    set -l branch_color magenta
    set -l upstream_color magenta
    set -l staged_color green
    set -l unstaged_color red
    set -l misc_color cyan
    set -l label_color yellow
    set -l dim_color brblack
    set -l autosuggestion_color brblack
    set -l separator_color 454158
    if test "$color_theme" = light
        set separator_color cfcfde
    end

    if test -r "$theme_path"
        set -l active_section
        while read -l line
            set line (string trim -- $line)
            if test -z "$line"
                continue
            end

            if string match -q '#*' -- $line
                continue
            end

            if string match -rq '^\[(light|dark|unknown)\]$' -- $line
                set active_section (string replace -r '^\[(.*)\]$' '$1' -- $line)
                continue
            end

            if test "$active_section" != "$color_theme"
                continue
            end

            set -l tokens (string split ' ' -- (string replace -ra '\s+' ' ' -- $line))
            set -l var_name $tokens[1]
            set -l color_value
            for token in $tokens[2..]
                if not string match -q -- '--*' $token
                    set color_value $token
                    break
                end
            end

            test -n "$color_value"; or continue

            switch $var_name
                case fish_color_cwd
                    set cwd_color $color_value
                case fish_color_user
                    set user_color $color_value
                case fish_color_host
                    set host_color $color_value
                case fish_color_host_remote
                    set host_remote_color $color_value
                case fish_color_status
                    set status_color $color_value
                    set unstaged_color $color_value
                case fish_pager_color_prefix
                    set branch_color $color_value
                case fish_color_keyword
                    set upstream_color $color_value
                case fish_color_end
                    set staged_color $color_value
                case fish_color_redirection
                    set misc_color $color_value
                case fish_color_quote
                    set label_color $color_value
                case fish_color_autosuggestion
                    set autosuggestion_color $color_value
                case fish_color_gray
                    set dim_color $color_value
                case fish_color_comment
                    if test "$dim_color" = brblack
                        set dim_color $color_value
                    end
            end
        end < "$theme_path"
    end

    set -g __kg_prompt_theme_name $theme_name
    set -g __kg_prompt_theme_variant $color_theme
    set -g __kg_prompt_cwd $cwd_color
    set -g __kg_prompt_user $user_color
    set -g __kg_prompt_host $host_color
    set -g __kg_prompt_host_remote $host_remote_color
    set -g __kg_prompt_status $status_color
    set -g __kg_prompt_branch $branch_color
    set -g __kg_prompt_upstream $upstream_color
    set -g __kg_prompt_staged $staged_color
    set -g __kg_prompt_unstaged $unstaged_color
    set -g __kg_prompt_misc $misc_color
    set -g __kg_prompt_label $label_color
    set -g __kg_prompt_dim $dim_color
    set -g __kg_prompt_autosuggestion $autosuggestion_color
    set -g __kg_prompt_separator $separator_color

    set -g __kg_prompt_mode_default $branch_color
    set -g __kg_prompt_mode_insert $staged_color
    set -g __kg_prompt_mode_replace $unstaged_color
    set -g __kg_prompt_mode_visual $upstream_color
end
