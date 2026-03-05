function __kg_git_status_collect --description 'Collect git status metadata for prompt and gss'
    if test (count $argv) -eq 0
        if set -q __kg_git_non_repo_pwd; and test "$__kg_git_non_repo_pwd" = "$PWD"
            set -g __kg_git_in_repo 0
            return 1
        end
    end

    set -l lines (command git status --porcelain=v2 --branch --show-stash --ahead-behind $argv 2>/dev/null)
    set -l status_code $status
    if test $status_code -ne 0
        set -g __kg_git_in_repo 0
        if test (count $argv) -eq 0
            set -g __kg_git_non_repo_pwd $PWD
        end
        return 1
    end

    set -g __kg_git_in_repo 1
    set -e __kg_git_non_repo_pwd

    set -g __kg_git_branch ""
    set -g __kg_git_has_upstream 0
    set -g __kg_git_ahead 0
    set -g __kg_git_behind 0
    set -g __kg_git_staged 0
    set -g __kg_git_unstaged 0
    set -g __kg_git_untracked 0
    set -g __kg_git_conflicted 0
    set -g __kg_git_stash 0

    for line in $lines
        if string match -q -- '# branch.head *' "$line"
            set -g __kg_git_branch (string replace '# branch.head ' '' -- $line)
            continue
        end

        if string match -q -- '# branch.upstream *' "$line"
            set -g __kg_git_has_upstream 1
            continue
        end

        if string match -q -- '# branch.ab *' "$line"
            set -l parts (string split ' ' -- $line)
            set -g __kg_git_ahead (string replace '+' '' -- $parts[3])
            set -g __kg_git_behind (string replace '-' '' -- $parts[4])
            continue
        end

        if string match -q -- '# stash *' "$line"
            set -g __kg_git_stash (string replace '# stash ' '' -- $line)
            continue
        end

        set -l tag (string sub -s 1 -l 1 -- $line)
        switch $tag
            case '?'
                set -g __kg_git_untracked (math "$__kg_git_untracked + 1")
            case '1' '2' 'u'
                set -l parts (string split ' ' -- $line)
                set -l xy $parts[2]
                set -l x (string sub -s 1 -l 1 -- $xy)
                set -l y (string sub -s 2 -l 1 -- $xy)

                if test "$x" != "."
                    set -g __kg_git_staged (math "$__kg_git_staged + 1")
                end
                if test "$y" != "."
                    set -g __kg_git_unstaged (math "$__kg_git_unstaged + 1")
                end
                if test "$tag" = 'u'
                    set -g __kg_git_conflicted (math "$__kg_git_conflicted + 1")
                end
        end
    end

    if test -z "$__kg_git_branch"
        set -g __kg_git_branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
        or set -g __kg_git_branch (command git rev-parse --short HEAD 2>/dev/null)
    end

    return 0
end
