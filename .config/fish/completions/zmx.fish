complete -c zmx -f

complete -c zmx -n "__fish_is_nth_token 1" -a 'a attach' -d 'Attach to session, creating if needed'
complete -c zmx -n "__fish_is_nth_token 1" -a 'r run' -d 'Send command without attaching'
complete -c zmx -n "__fish_is_nth_token 1" -a 'd detach' -d 'Detach all clients from current session'
complete -c zmx -n "__fish_is_nth_token 1" -a 'l list' -d 'List active sessions'
complete -c zmx -n "__fish_is_nth_token 1" -a 'c completions' -d 'Shell completion scripts'
complete -c zmx -n "__fish_is_nth_token 1" -a 'k kill' -d 'Kill a session'
complete -c zmx -n "__fish_is_nth_token 1" -a 'hi history' -d 'Output session scrollback'
complete -c zmx -n "__fish_is_nth_token 1" -a 'v version' -d 'Show version'
complete -c zmx -s v -l version -d 'Show version'
complete -c zmx -n "__fish_is_nth_token 1" -a 'w wait' -d 'Wait for session tasks to complete'
complete -c zmx -n "__fish_is_nth_token 1" -a 'h help' -d 'Show help message'
complete -c zmx -s h -d 'Show help message'

complete -c zmx -n "__fish_is_nth_token 2; and __fish_seen_subcommand_from a attach r run k kill hi history w wait" -a '(zmx list --short 2>/dev/null)' -d 'Session name'

complete -c zmx -n "__fish_is_nth_token 2; and __fish_seen_subcommand_from c completions" -a 'bash zsh fish' -d Shell

complete -c zmx -n "__fish_seen_subcommand_from l list" -l short -d 'Short output'
complete -c zmx -n "__fish_seen_subcommand_from hi history" -l vt -d 'History format for escape sequences'
complete -c zmx -n "__fish_seen_subcommand_from hi history" -l html -d 'History format for escape sequences'
