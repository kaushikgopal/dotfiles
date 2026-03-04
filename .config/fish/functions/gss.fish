function gss --description 'Compact git status with prompt-style summary'
    command git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
    or begin
        echo "gss: not inside a git repository"
        return 1
    end

    set -l vcs (fish_vcs_prompt '%s' 2>/dev/null)
    if test -n "$vcs"
        echo $vcs
    else
        command git symbolic-ref --quiet --short HEAD 2>/dev/null
        or command git rev-parse --short HEAD 2>/dev/null
    end

    echo -----
    command git -c color.status=always status --short --branch --ahead-behind --show-stash $argv
end
