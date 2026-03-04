function gss --description 'Compact git status with prompt-style summary'
    command git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
    or begin
        echo "gss: not inside a git repository"
        return 1
    end

    set -l branch ""
    set -l has_upstream 0
    set -l ahead 0
    set -l behind 0
    set -l staged 0
    set -l unstaged 0
    set -l untracked 0
    set -l conflicted 0
    set -l stash 0

    for line in (command git status --porcelain=v2 --branch --show-stash --ahead-behind $argv)
        if string match -q -- '# branch.head *' "$line"
            set branch (string replace '# branch.head ' '' -- $line)
            continue
        end

        if string match -q -- '# branch.upstream *' "$line"
            set has_upstream 1
            continue
        end

        if string match -q -- '# branch.ab *' "$line"
            set -l parts (string split ' ' -- $line)
            set ahead (string replace '+' '' -- $parts[3])
            set behind (string replace '-' '' -- $parts[4])
            continue
        end

        if string match -q -- '# stash *' "$line"
            set stash (string replace '# stash ' '' -- $line)
            continue
        end

        set -l tag (string sub -s 1 -l 1 -- $line)
        switch $tag
            case '?'
                set untracked (math "$untracked + 1")
            case '1' '2' 'u'
                set -l parts (string split ' ' -- $line)
                set -l xy $parts[2]
                set -l x (string sub -s 1 -l 1 -- $xy)
                set -l y (string sub -s 2 -l 1 -- $xy)

                if test "$x" != "."
                    set staged (math "$staged + 1")
                end
                if test "$y" != "."
                    set unstaged (math "$unstaged + 1")
                end
                if test "$tag" = 'u'
                    set conflicted (math "$conflicted + 1")
                end
        end
    end

    if test -z "$branch"
        set branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
        or set branch (command git rev-parse --short HEAD 2>/dev/null)
    end

    set -l normal (set_color normal)
    set -l c_branch (set_color brgreen)
    set -l c_dirty (set_color brred)
    set -l c_index (set_color brgreen)
    set -l c_upstream (set_color brmagenta)
    set -l c_misc (set_color brblue)
    set -l c_counts (set_color brblack)

    set -l summary_parts "$c_branch$branch$normal"
    if test $has_upstream -eq 1
        if test $ahead -gt 0
            set -a summary_parts "$c_upstream↑$ahead$normal"
        end
        if test $behind -gt 0
            set -a summary_parts "$c_upstream↓$behind$normal"
        end
        if test $ahead -eq 0 -a $behind -eq 0
            set -a summary_parts "$c_upstream=$normal"
        end
    end
    if test $staged -gt 0
        set -a summary_parts "$c_index+$staged$normal"
    end
    if test $unstaged -gt 0
        set -a summary_parts "$c_dirty*$unstaged$normal"
    end
    if test $untracked -gt 0
        set -a summary_parts "$c_misc?$untracked$normal"
    end
    if test $stash -gt 0
        set -a summary_parts "$c_misc\$$stash$normal"
    end
    if test $conflicted -gt 0
        set -a summary_parts "$c_dirty✗$conflicted$normal"
    end

    echo (string join ' ' -- $summary_parts)
    echo "$c_counts"(string join ' ' -- "staged:$staged" "unstaged:$unstaged" "untracked:$untracked" "stash:$stash" "conflicts:$conflicted")"$normal"

    echo -----
    command git -c color.status=always status --short --branch --ahead-behind --show-stash $argv
end
