function __kg_git_prompt_segment --description 'Render compact git status segment for fish prompt'
    __kg_prompt_palette_load

    __kg_git_status_collect
    or return

    if test "$__kg_git_in_repo" -ne 1
        return
    end

    set -l normal (set_color normal)
    set -l c_branch (set_color $__kg_prompt_branch)
    set -l c_upstream (set_color $__kg_prompt_upstream)
    set -l c_staged (set_color $__kg_prompt_staged)
    set -l c_unstaged (set_color $__kg_prompt_unstaged)
    set -l c_misc (set_color $__kg_prompt_misc)

    set -l parts "$c_branch$__kg_git_branch$normal"

    if test "$__kg_git_has_upstream" -eq 1
        if test "$__kg_git_ahead" -eq 0 -a "$__kg_git_behind" -eq 0
            set -a parts "$c_upstream=$normal"
        else
            if test "$__kg_git_ahead" -gt 0
                set -a parts "$c_upstream↑$__kg_git_ahead$normal"
            end
            if test "$__kg_git_behind" -gt 0
                set -a parts "$c_upstream↓$__kg_git_behind$normal"
            end
        end
    end

    if test "$__kg_git_staged" -gt 0
        set -a parts "$c_staged+$__kg_git_staged$normal"
    end
    if test "$__kg_git_unstaged" -gt 0
        set -a parts "$c_unstaged~$__kg_git_unstaged$normal"
    end
    if test "$__kg_git_untracked" -gt 0
        set -a parts "$c_misc?$__kg_git_untracked$normal"
    end
    if test "$__kg_git_stash" -gt 0
        set -a parts "$c_misc\$$__kg_git_stash$normal"
    end
    if test "$__kg_git_conflicted" -gt 0
        set -a parts "$c_unstaged!$__kg_git_conflicted$normal"
    end

    echo " "(string join ' ' -- $parts)
end
