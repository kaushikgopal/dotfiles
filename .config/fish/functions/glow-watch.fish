# Keep Markdown previews live without entering Glow's pager, which blocks
# file-change refreshes until the pager exits. Watchexec owns stdin so keys
# pressed after Glow exits are handled instead of echoing raw escape bytes.
function glow-watch --description "Preview Markdown with Glow and refresh on save"
    if test (count $argv) -eq 0
        echo "glow-watch: expected a Markdown file"
        return 2
    end

    set -l file $argv[1]
    set -e argv[1]

    if not test -f "$file"
        echo "glow-watch: file not found: $file"
        return 1
    end

    if not command -q watchexec
        echo "glow-watch: watchexec is not installed; run brew bundle"
        return 127
    end

    if not command -q glow
        echo "glow-watch: glow is not installed; run brew bundle"
        return 127
    end

    command watchexec --interactive --quiet --clear --restart --shell=none --watch "$file" -- glow $argv -- "$file"
end
