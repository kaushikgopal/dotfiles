function fish_prompt
    __kg_prompt_palette_load

    set -l last_status $status
    set -l normal (set_color normal)
    set -l usercolor (set_color $__kg_prompt_user)

    # ------------------------------------------
    # [prompt status & character]

    # Initialize prompt_status as empty.
    set -l prompt_status

    # If the last command failed (status not 0), show the error status in color.
    if test $last_status -ne 0
        set prompt_status (set_color $__kg_prompt_status)" $last_status$normal"
    end

    # Set the default prompt delimiter with color.
    # set -l delim (set_color brblack)" ⏹" $normal
    set -l delim "" $normal

    # # If running as root, use a plain "#" as the delimiter (no color).
    # if fish_is_root_user
    #     set delim "#"
    # end

    # ------------------------------------------
    # [directory]

    # cwd = current working directory color
    # set -l cwd (set_color $fish_color_cwd)
    # if command -sq cksum
    #     # randomized cwd color
    #     # We hash the physical PWD and turn that into a color. That means directories (usually) get different colors,
    #     # but every directory always gets the same color. It's deterministic.
    #     # We use cksum because 1. it's fast, 2. it's in POSIX, so it should be available everywhere.
    #     set -l shas (pwd -P | cksum | string split -f1 ' ' | math --base=hex | string sub -s 3 | string pad -c 0 -w 6 | string match -ra ..)
    #     set -l col 0x$shas[1..3]

    #     # If the (simplified idea of) luminance is below 120 (out of 255), add some more.
    #     # (this runs at most twice because we add 60)
    #     while test (math 0.2126 x $col[1] + 0.7152 x $col[2] + 0.0722 x $col[3]) -lt 120
    #         set col[1] (math --base=hex "min(255, $col[1] + 60)")
    #         set col[2] (math --base=hex "min(255, $col[2] + 60)")
    #         set col[3] (math --base=hex "min(255, $col[3] + 60)")
    #     end
    #     set -l col (string replace 0x '' $col | string pad -c 0 -w 2 | string join "")
    #     set cwd (set_color -b brblack $col)
    # end
    # set -l pwd (set_color -b brblack black)" "(prompt_pwd)" "(set_color normal)
    set -l pwd (set_color $__kg_prompt_cwd)" "(prompt_pwd)" "(set_color normal)

    # ------------------------------------------
    # [git branch]

    set -l vcs (__kg_git_prompt_segment)



    # ------------------------------------------
    # [prompt_host]

    # Only show host if in SSH or container.
    # Cache the decision, but build the colored string fresh so theme changes apply.
    if not set -q __kg_prompt_show_host
        set -g __kg_prompt_show_host 0
        if set -q SSH_TTY
            or begin
                command -sq systemd-detect-virt
                and systemd-detect-virt -q
            end
            set -g __kg_prompt_show_host 1
        end
    end

    set -l prompt_host ""
    if test $__kg_prompt_show_host -eq 1
        set -l hostcolor $__kg_prompt_host
        if set -q SSH_TTY
            set hostcolor $__kg_prompt_host_remote
        end
        set prompt_host $usercolor$USER$normal@(set_color $hostcolor)$hostname$normal":"
    end

    # ------------------------------------------
    # assemble prompt

    string join "" -- $prompt_host $pwd $vcs $normal $prompt_status $delim

    # show prompt on new line
    echo  -n -e -s " "
end
