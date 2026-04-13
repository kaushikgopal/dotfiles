# zmx session picker — fzf-powered attach/kill for zmx sessions
#
# Ghostty-native alternative to tmux-chooser (prefix + s).
# Sessions only — zmx has no windows/panes concept; Ghostty handles that.
#
# Usage:
#   zml          — pick a session to attach
#   Ctrl-X       — kill selected session (refreshes list)
#   Ctrl-R       — refresh session list
#   Esc / Ctrl-C — cancel

function zml --description "zmx session picker with fzf preview"
    set -l sessions (zmx list 2>/dev/null)

    if test (count $sessions) -eq 0
        echo "No zmx sessions running. Create one with: zmn <name>"
        return 1
    end

    set -l session (printf '%s\n' $sessions | fzf \
        --height 50% \
        --reverse \
        --border-label ' zmx sessions ' \
        --prompt '  ' \
        --header '  enter: attach  ctrl-x: kill  ctrl-r: refresh' \
        --preview 'zmx history {} 2>/dev/null || echo "(no scrollback)"' \
        --preview-window 'right:55%:wrap' \
        --bind "ctrl-x:execute-silent(zmx kill {})+reload(zmx list 2>/dev/null)" \
        --bind "ctrl-r:reload(zmx list 2>/dev/null)" \
    )

    if test -n "$session"
        zmx attach $session
    end
end
