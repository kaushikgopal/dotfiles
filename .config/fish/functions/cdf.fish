function cdf --description 'Change to the current Finder directory'
    set -l finder_dir (osascript -e 'tell application "Finder" to if (count of windows) > 0 then get POSIX path of (target of front window as alias)')
    if test -d $finder_dir
        cd $finder_dir
    else
        echo "No Finder window found or directory does not exist."
    end
end
