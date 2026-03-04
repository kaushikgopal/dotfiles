status is-interactive; or return

function post-exec --on-event fish_postexec --description "print new line after every fish command"
    echo
end
