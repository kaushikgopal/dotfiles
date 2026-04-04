function __fzf_search_content --description "Live ripgrep search, insert +LINE file at cursor"
    set -l result (
        fzf --ansi --disabled \
            --bind "change:reload:rg --color=always --line-number --no-heading --smart-case {q} || true" \
            --delimiter : \
            --preview 'bat --color=always --highlight-line {2} {1}' \
            --preview-window '+{2}-5:right:60%:wrap' \
            --height 60% --layout=reverse --border \
            --prompt 'rg> '
    )
    if test -n "$result"
        set -l parts (string split : $result)
        set -l file $parts[1]
        set -l line $parts[2]
        commandline -it -- "+$line $file"
    end
    commandline -f repaint
end
