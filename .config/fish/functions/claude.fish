# Bypass gohan wrapper; use native binary with work Bedrock credentials from env
# Pass --personal to use personal account instead of work
function claude
    if contains -- --personal $argv
        set -l filtered
        for arg in $argv
            if test "$arg" != --personal
                set -a filtered $arg
            end
        end
        env -u CLAUDE_CODE_USE_BEDROCK \
            -u ANTHROPIC_BEDROCK_BASE_URL \
            -u GATEWAY_BEDROCK_API_KEY \
            -u CLAUDE_CODE_SKIP_BEDROCK_AUTH \
            -u CLAUDE_CODE_ATTRIBUTION_HEADER \
            -u CLAUDE_CODE_ENTRYPOINT \
            -u ANTHROPIC_DEFAULT_OPUS_MODEL \
            CLAUDE_CONFIG_DIR=~/.claude-personal \
            /opt/homebrew/bin/claude $filtered
    else
        /opt/homebrew/bin/claude $argv
    end
end
