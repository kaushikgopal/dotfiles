# Wrap lazygit with tmux activity monitoring suppressed.
# TUI apps like lazygit redraw constantly, which tmux interprets as output and
# flags the window as having "activity" — this is noise, not signal.
function lg --description "lazygit with tmux activity monitoring suppressed"
    if set -q TMUX
        tmux set-window-option monitor-activity off
    end
    lazygit $argv
    if set -q TMUX
        # Restore the global default (on) for this window when lazygit exits.
        tmux set-window-option monitor-activity on
    end
end
