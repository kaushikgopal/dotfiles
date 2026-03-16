function __kg_prompt_separator --description 'Render a subtle divider around the editable prompt line'
    __kg_prompt_palette_load

    set -l width $COLUMNS
    if test -z "$width"; or test $width -lt 8
        set width 80
    end
    set width (math "$width - 1")

    set -l divider (string repeat -n $width '─')
    # Keep the divider lighter than prompt text so it reads as structure, not content.
    printf '%s%s%s\n' (set_color $__kg_prompt_separator) $divider (set_color normal)
end
