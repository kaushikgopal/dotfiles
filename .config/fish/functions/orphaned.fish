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
        set -l tty (ps -p $pid -o tty= 2>/dev/null | string trim)
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
        procs --load-config ~/.config/procs/config.kg.toml --or $pids
        echo
        echo "Run 'orphaned --kill $name' to kill them."
    end
end
