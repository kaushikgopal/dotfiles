# Define the SDKMAN directory using Homebrew
export SDKMAN_DIR=(brew --prefix sdkman-cli)/libexec

# Add SDKMAN candidates to PATH
for candidate in (find -L "$SDKMAN_DIR/candidates" -type d -path '*/current/bin')
    fish_add_path $candidate
end

# Fish-compatible 'sdk' function
function sdk --description "Run SDKMAN commands"
    set --local sdk_bash_cmd "source $SDKMAN_DIR/bin/sdkman-init.sh; sdk $argv"

    # Check for special 'use' command case
    if test (count $argv) -gt 0; and test (string match --regex '^use' $argv)
        # Set environment variables to look for
        set --local env_vars PATH JAVA_HOME
        set --local output (bash -c "$sdk_bash_cmd; SDK_STATUS=\$?; env | grep -E '^($(string join '|' $env_vars))='; exit \$SDK_STATUS")
        # Used to access the exit code of sdk instead of grep
        set --local sdk_status $status
        if test $sdk_status -eq 0
            for line in $output
                # Ignore output by sdk
                if not string match --quiet '*=*' $line
                    continue
                end

                set --local key (echo $line | cut --delimiter '=' --fields 1)
                set --local value (echo $line | cut --delimiter '=' --fields 2-)

                # Ignore environment variables we're not looking for
                if not contains $key $env_vars
                    continue
                end

                set --export $key $value
            end
            printf '\n%s\n' (set_color green)"Using $argv[2] version $argv[3] in this shell."(set_color normal)
        else
            printf '\n%s\n' (set_color --bold red)'Stop! Candidate version is not installed.'(set_color normal)
            printf '\n%s\n' (set_color --bold yellow)'Tip: Run the following to install this version'(set_color normal)
            printf '\n%s\n' (set_color --bold yellow)"\$ sdk install $argv[2] $argv[3]"(set_color normal)
        end

        return $std_status
    else
        bash -c $sdk_bash_cmd
    end
end
