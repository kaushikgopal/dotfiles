# Default commands
: ${MAGIC_ENTER_GIT_COMMAND:="git-number"}  # run when in a git repository
: ${MAGIC_ENTER_OTHER_COMMAND:="l"}        # run anywhere else

magic-enter() {
  # Only run MAGIC_ENTER commands when in PS1 and command line is empty
  # http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#User_002dDefined-Widgets
  if [[ -n "$BUFFER" || "$CONTEXT" != start ]]; then
    return
  fi


  is_git_repository=$(git rev-parse --is-inside-work-tree)
  in_repo_root_folder=$(git rev-parse --show-toplevel)
  repo_has_changes=$(git status -s --ignore-submodules=dirty)

  # is_git_repository="true" && echo "is_git_repo: true" || echo "is_git_repo: false"
  # in_repo_root_folder="$PWD" && echo "in_repo_root_folder: true" || echo "in_repo_root_folder: false"
  # [[ -n "$repo_has_changes" ]] && echo "repo_has_changes: true" || echo "repo_has_changes: false"

  if [ "$is_git_repository" = true ] && [ "$in_repo_root_folder" = $PWD ] && [ ! -z "$repo_has_changes" ]; then
    BUFFER="$MAGIC_ENTER_GIT_COMMAND"
  else
    BUFFER="$MAGIC_ENTER_OTHER_COMMAND"
  fi
}

# Wrapper for the accept-line zle widget (run when pressing Enter)

# If the wrapper already exists don't redefine it
(( ! ${+functions[_magic-enter_accept-line]} )) || return 0

case "$widgets[accept-line]" in
  # Override the current accept-line widget, calling the old one
  user:*) zle -N _magic-enter_orig_accept-line "${widgets[accept-line]#user:}"
    function _magic-enter_accept-line() {
      magic-enter
      zle _magic-enter_orig_accept-line -- "$@"
    } ;;
  # If no user widget defined, call the original accept-line widget
  builtin) function _magic-enter_accept-line() {
      magic-enter
      zle .accept-line
    } ;;
esac

zle -N accept-line _magic-enter_accept-line
