# Restore terminal state after a TUI exits without cleaning up modes such as
# bracketed paste, mouse reporting, focus reporting, or the alternate screen.
function fixterm
    stty sane
    printf '\e[?25h\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[?2004l\e[?1049l'
    clear
    commandline -f repaint
end
