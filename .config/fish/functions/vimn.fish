function vimn --description 'Create and open markdown note'
    # Parse arguments
    set -l options 't'
    argparse $options -- $argv

    # Declare dir variable before the if block
    set -l dir

    # Set directory based on flag
    if set -q _flag_t
        set dir /tmp
    else
        set dir $HOME/notes/obsd
    end

    # Generate filename with timestamp
    set -l filename (date +"%Y%m%d-%H%M%S").md
    set -l filepath $dir/$filename

    # Create the file with frontmatter
    echo '---' > $filepath
    echo 'tags:' >> $filepath
    echo '  - cli' >> $filepath
    echo '---' >> $filepath
    echo '' >> $filepath

    # Open in vim at the last line
    vim + $filepath
end
