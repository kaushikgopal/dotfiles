function gss --description 'Compact git status with prompt-style summary'
    __kg_prompt_palette_load

    command git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
    or begin
        echo "gss: not inside a git repository"
        return 1
    end

    __kg_git_status_collect $argv
    or begin
        echo "gss: failed to read git status"
        return 1
    end

    set -l normal (set_color normal)
    set -l c_label (set_color $__kg_prompt_label)
    set -l c_branch (set_color $__kg_prompt_branch)
    set -l c_upstream (set_color $__kg_prompt_upstream)
    set -l c_staged (set_color $__kg_prompt_staged)
    set -l c_unstaged (set_color $__kg_prompt_unstaged)
    set -l c_misc (set_color $__kg_prompt_misc)
    set -l c_dim (set_color $__kg_prompt_dim)
    set -l label_width 8
    set -l label_branch (printf "%*s" $label_width "branch:")
    set -l label_changes (printf "%*s" $label_width "changes:")

    set -l repo_parts "$c_label$label_branch$normal" "$c_branch$__kg_git_branch$normal"
    if test $__kg_git_has_upstream -eq 1
        if test $__kg_git_ahead -eq 0 -a $__kg_git_behind -eq 0
            set -a repo_parts "$c_upstream=$normal"
        else
            if test $__kg_git_ahead -gt 0
                set -a repo_parts "$c_upstream↑$__kg_git_ahead$normal"
            end
            if test $__kg_git_behind -gt 0
                set -a repo_parts "$c_upstream↓$__kg_git_behind$normal"
            end
        end
    end
    if test $__kg_git_stash -gt 0
        set -a repo_parts "$c_misc\$$__kg_git_stash$normal"
    end

    set -l change_parts "$c_label$label_changes$normal" "$c_staged+$__kg_git_staged$normal" "$c_unstaged~$__kg_git_unstaged$normal" "$c_misc?$__kg_git_untracked$normal"
    if test $__kg_git_conflicted -gt 0
        set -a change_parts "$c_unstaged!$__kg_git_conflicted$normal"
    end

    echo (string join ' ' -- $repo_parts)
    echo " "(string join ' ' -- $change_parts)
    echo " $c_dim----------------------------------------$normal"

    if test $__kg_git_staged -eq 0 -a $__kg_git_unstaged -eq 0 -a $__kg_git_untracked -eq 0 -a $__kg_git_conflicted -eq 0
        echo " $c_dim"working tree clean"$normal"
    else
        command git -c color.status=always status --short --no-branch $argv | string replace -r '^' ' '
    end
end
