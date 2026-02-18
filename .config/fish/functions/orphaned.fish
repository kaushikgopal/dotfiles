# List or kill orphaned processes (no controlling TTY)
function orphaned
    argparse 'kill' -- $argv
    or return 1

    if test (count $argv) -eq 0
        echo "Usage: orphaned [--kill] <process_name>"
        return 1
    end

    set -l name $argv[1]
    set -l pids
    for pid in (pgrep -if "$name")
        set -l tty (ps -p $pid -o tty= 2>/dev/null)
        if test "$tty" = "??"
            set -a pids $pid
        end
    end

    if test (count $pids) -eq 0
        echo "No orphaned $name processes found."
        return 0
    end

    if set -q _flag_kill
        echo "Killing" (count $pids) "orphaned $name processes..."
        kill $pids
    else
        echo (count $pids) "orphaned $name processes:"
        printf "  %-8s %-14s %-10s %s\n" PID ELAPSED "RSS(KB)" COMMAND
        printf "  %-8s %-14s %-10s %s\n" "--------" "--------------" "----------" "-------"
        for pid in $pids
            set -l info (ps -p $pid -o pid=,etime=,rss=,command= 2>/dev/null | string trim)
            test -z "$info"; and continue
            set -l parts (string split -m 3 " " -- (string replace -ra ' +' ' ' "$info"))
            printf "  %-8s %-14s %-10s %s\n" $parts[1] $parts[2] $parts[3] $parts[4]
        end
        echo
        echo "Run 'orphaned --kill $name' to kill them."
    end
end
