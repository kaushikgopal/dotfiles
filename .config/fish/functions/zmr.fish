# Restore a recent claude or codex session into a new zmx session.
#
# Scans ~/.claude/sessions/ and ~/.codex/sessions/ for recent sessions,
# presents them in fzf, then runs the selected one inside zmx so you can
# attach with `zml`.
#
# Usage:
#   zmr          — pick a session to restore
#   Esc/Ctrl-C   — cancel

function zmr --description "restore a recent claude/codex session into zmx"
    set -l entries

    # Claude sessions — read newest 10 (files named by PID, sorted by mtime)
    for f in (ls -t ~/.claude/sessions/*.json 2>/dev/null | head -10)
        set -l session_id (grep -o '"sessionId":"[^"]*"' $f | cut -d'"' -f4)
        set -l cwd        (grep -o '"cwd":"[^"]*"' $f      | cut -d'"' -f4)
        set -l ts_ms      (grep -o '"startedAt":[0-9]*' $f | cut -d: -f2)
        test -n "$session_id" -a -n "$cwd" -a -n "$ts_ms"; or continue
        set -l ts_sec (math --scale=0 "$ts_ms / 1000")
        set -l date_str (date -r $ts_sec "+%Y-%m-%d %H:%M" 2>/dev/null)
        set -a entries (printf 'claude|%s|%s|%s' $cwd $date_str $session_id)
    end

    # Codex sessions — find newest 10 across YYYY/MM/DD subdirectories
    for f in (ls -t (find ~/.codex/sessions -name "*.jsonl" 2>/dev/null) 2>/dev/null | head -10)
        set -l uuid (string sub -s -36 (basename $f .jsonl))
        string match -qr '^[0-9a-f-]{36}$' $uuid; or continue
        set -l cwd (head -1 $f | grep -o '"cwd":"[^"]*"' | cut -d'"' -f4)
        test -n "$cwd"; or continue
        set -l date_str (stat -f "%Sm" -t "%Y-%m-%d %H:%M" $f 2>/dev/null)
        set -a entries (printf 'codex|%s|%s|%s' $cwd $date_str $uuid)
    end

    if test (count $entries) -eq 0
        echo "No recent claude or codex sessions found."
        return 1
    end

    # fzf: show tool | cwd | date, hide uuid (4th field)
    set -l selected (printf '%s\n' $entries | fzf \
        --delimiter '|' \
        --with-nth 1,2,3 \
        --height 50% \
        --reverse \
        --prompt '  ' \
        --header '  enter: restore into zmx  esc: cancel' \
    )
    test -n "$selected"; or return 0

    set -l parts   (string split '|' -- $selected)
    set -l tool    $parts[1]
    set -l cwd     $parts[2]
    set -l uuid    $parts[4]
    set -l name    (basename $cwd)

    # Build the resume command; exec replaces bash so zmx attach lands in the tool
    switch $tool
        case claude
            set -l resume "cd $cwd && exec claude --resume $uuid || exec fish"
        case codex
            set -l resume "cd $cwd && exec codex resume $uuid || exec fish"
    end

    # Avoid clobbering an existing live session with the same name
    if zmx list --short 2>/dev/null | string match -q -- $name
        echo "Session '$name' already exists — use 'zml' to attach."
        return 1
    end

    zmx run $name bash -c $resume
    echo "Session '$name' created — run 'zml' to attach."
end
