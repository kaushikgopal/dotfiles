function fish_right_prompt
    # ------------------------------------------
    if not set -q __fish_right_prompt_counter
        set -g __fish_right_prompt_counter 0
    end
    set -g __fish_right_prompt_counter (math "$__fish_right_prompt_counter + 1")

    if not set -q __fish_right_prompt_dt
        set -g __fish_right_prompt_dt (set_color brgrey)(date "+%R")(set_color normal)
    else if test (math "$__fish_right_prompt_counter % 20") -eq 0
        set -g __fish_right_prompt_dt (set_color brgrey)(date "+%R")(set_color normal)
    end

    set -l duration $CMD_DURATION
    if test -n "$duration"; and test $duration -gt 100
        set duration (math $duration / 1000)s
    else
        set duration
    end

    set -q VIRTUAL_ENV_DISABLE_PROMPT
    or set -g VIRTUAL_ENV_DISABLE_PROMPT true
    set -q VIRTUAL_ENV
    and set -l venv (string replace -r '.*/' '' -- "$VIRTUAL_ENV")

    set_color normal
    string join " " -- $venv $duration $__fish_right_prompt_dt
end
