function gss --description 'Compact git status with prompt-style summary'
    command git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
    or begin
        echo "gss: not inside a git repository"
        return 1
    end

    set -l staged 0
    set -l unstaged 0
    set -l untracked 0
    set -l stash 0
    set -l branch ""
    set -l ahead 0
    set -l behind 0

    for line in (command git status --porcelain=v2 --branch --show-stash $argv)
        set -l parts (string split ' ' -- $line)

        switch $parts[1]
            case '#'
                switch "$parts[2]"
                    case 'branch.head'
                        set branch (string replace '# branch.head ' '' -- $line)
                    case 'branch.ab'
                        set ahead (string replace '+' '' -- $parts[3])
                        set behind (string replace '-' '' -- $parts[4])
                    case 'stash'
                        set stash $parts[3]
                end
            case '?'
                set untracked (math "$untracked + 1")
            case '1' '2' 'u'
                set -l xy $parts[2]
                set -l x (string sub -s 1 -l 1 -- $xy)
                set -l y (string sub -s 2 -l 1 -- $xy)

                if test "$x" != "."
                    set staged (math "$staged + 1")
                end

                if test "$y" != "."
                    set unstaged (math "$unstaged + 1")
                end
        end
    end

    set -l upstream ""
    if test $ahead -gt 0 -a $behind -gt 0
        set upstream "ahead:$ahead behind:$behind"
    else if test $ahead -gt 0
        set upstream "ahead:$ahead"
    else if test $behind -gt 0
        set upstream "behind:$behind"
    end

    set -l branch_label "branch:$branch"
    if test -n "$upstream"
        set branch_label "$branch_label $upstream"
    end
    if test $stash -gt 0
        set branch_label "$branch_label stash:$stash"
    end

    echo (set_color brblue)$branch_label(set_color normal)
    echo (set_color brblack)"staged:"(set_color normal)$staged" "(set_color brblack)"unstaged:"(set_color normal)$unstaged" "(set_color brblack)"untracked:"(set_color normal)$untracked
    command git -c color.status=always status --short --branch --ahead-behind --show-stash $argv
end
