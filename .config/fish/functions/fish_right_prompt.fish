function fish_right_prompt
    __kg_prompt_palette_load

    set -l clock_color $__kg_prompt_dim

    # ------------------------------------------
    if not set -q __fish_right_prompt_counter
        set -g __fish_right_prompt_counter 0
    end
    set -g __fish_right_prompt_counter (math "$__fish_right_prompt_counter + 1")

    if not set -q __fish_right_prompt_dt
        or not set -q __fish_right_prompt_dt_color
        or test "$__fish_right_prompt_dt_color" != "$clock_color"
        set -g __fish_right_prompt_dt (set_color $clock_color)(date "+%R")(set_color normal)
        set -g __fish_right_prompt_dt_color $clock_color
    else if test (math "$__fish_right_prompt_counter % 20") -eq 0
        set -g __fish_right_prompt_dt (set_color $clock_color)(date "+%R")(set_color normal)
        set -g __fish_right_prompt_dt_color $clock_color
    end

    set -l duration $CMD_DURATION
    if test -n "$duration"; and test $duration -gt 100
        set duration (math $duration / 1000)s
    else
        set duration
    end

    # zmx session indicator — matches green bold "tmux" from tmux theme.conf
    set -q ZMX_SESSION
    and set -l zmx_indicator (set_color --bold green)"zmx"(set_color normal)

    set -q VIRTUAL_ENV_DISABLE_PROMPT
    or set -g VIRTUAL_ENV_DISABLE_PROMPT true
    set -q VIRTUAL_ENV
    and set -l venv (string replace -r '.*/' '' -- "$VIRTUAL_ENV")

    set_color normal
    string join " " -- $zmx_indicator $venv $duration $__fish_right_prompt_dt
end
