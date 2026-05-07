#!/usr/bin/env bash

set -euo pipefail

# switching section
YELLOW='\033[1;33m'
# info
GRAY='\033[1;30m'
# making change
PURPLE='\033[1;35m'
# No Color
NC='\033[0m'

function load_homebrew_shellenv {
    if command -v brew >/dev/null 2>&1; then
        return
    fi

    # Fresh Homebrew installs are not visible to non-login bootstrap shells until
    # we load shellenv explicitly.
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

function install_command_line_tools_if_missing {
    if xcode-select -p >/dev/null 2>&1; then
        echo -e "${GRAY}---- Xcode command line tools are already installed.${NC}"
        return
    fi

    echo -e "${YELLOW}---- installing Xcode command tools (without all of Xcode)${NC}"
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    if ! sudo softwareupdate --install -a --verbose; then
        rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        return 1
    fi
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
}

function setup_aikado_agents {
    if [ -d "$AIKADO_DIR" ]; then
        echo -e "${GRAY}••••••• setting up agents from $AIKADO_DIR ${NC}"
        make -C "$AIKADO_DIR" setup-user
    else
        echo -e "${GRAY}••••••• aikado not found at $AIKADO_DIR ${NC}"
        echo -e "${GRAY}••••••• run: AIKADO_DIR=/path/to/aikado ./.setup.sh ${NC}"
    fi
}

##############################################################
# Setup the dotfiles symlinks
##############################################################

# capture the current directory
current_dir=$(pwd)

# move into the home directory first
pushd $HOME

mkdir -p .config
mkdir -p .config/karabiner  # see https://github.com/kaushikgopal/karabiner-kt.git for karabiner.json
mkdir -p .local
mkdir -p .local/bin

# List of files to symlink (one per line for easy maintenance)
files_to_link=(
    .bashrc
    .brewfile
    .brew.sh
    .npm-global-packages
    .npm.sh
    .config/.ripgreprc
    .config/fish
    .config/ghostty
    .config/git
    .config/lazygit
    .config/serie
    .config/procs
    .config/zed
    .config/yazi
    .editorconfig
    .firebender
    .hushlogin
    .ideavimrc
    .profile
    .vim
    .vimrc
)

for file in "${files_to_link[@]}"; do
    echo -e "${GRAY}••••••• symlinking $current_dir/$file -> $HOME/$file ${NC}"
    rm -rf "$HOME/$file"
    ln -sfn "$current_dir/$file" "$HOME/$file"
done

##############################################################
# Agents now live in aikado
##############################################################

AIKADO_DIR="${AIKADO_DIR:-$HOME/dev/per/aikado}"
echo -e "${GRAY}••••••• agent setup path: $AIKADO_DIR ${NC}"

# symlink each script in bin/ to ~/.local/bin/
for script in "$current_dir"/bin/*; do
    [ -f "$script" ] || continue
    name=$(basename "$script")
    echo -e "${GRAY}••••••• symlinking $script -> $HOME/.local/bin/$name ${NC}"
    ln -sfn "$script" "$HOME/.local/bin/$name"
done

popd

# Keep the full bootstrap path active for new machines. The sections below are
# guarded so reruns do not reinstall or delete machine-specific state by default.
# exit 0

##############################################################
# Basics (git & dotfiles)
##############################################################

echo -e "${YELLOW}---- Asking for an admin password upfront${NC}"
sudo -v

install_command_line_tools_if_missing
setup_aikado_agents

if [[ "${RUN_SOFTWARE_UPDATE:-0}" == "1" ]]; then
    echo -e "\n\n\n${YELLOW}---- installing available Apple Software Updates${NC}"
    sudo softwareupdate --install -a --verbose
else
    echo -e "${GRAY}---- skipping Apple Software Updates. Set RUN_SOFTWARE_UPDATE=1 to run them.${NC}"
fi

echo -e "${YELLOW}---- setting up homebrew${NC}"

load_homebrew_shellenv
if ! command -v brew &>/dev/null; then
    echo -e "\n\n\n${YELLOW}---- Homebrew not found. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_homebrew_shellenv
else
    echo -e "${GRAY}---- Homebrew is already installed.${NC}"
fi

echo -e "${GRAY}---- Turning homebrew analytics off.${NC}"
brew analytics off

BREW_INSTALL_ONLY=1 source "$HOME/.brew.sh"

echo -e "${YELLOW}---- setting up github${NC}"

echo -e "\n\n\n${YELLOW}---- Setting up git${NC}"
if gh auth status >/dev/null 2>&1; then
    echo -e "${GRAY}---- logged in to github${NC}"
else
    echo -e "${PURPLE}---- you need to setup github, follow the prompts now ${NC}"
    gh auth login
fi

# we are expecting you set this up independently
#
# echo -e "${YELLOW}---- setting up dotfiles${NC}"
# cd $HOME

# if git rev-parse --git-dir >/dev/null 2>&1; then
#     echo -e "${GRAY}---- looks like dotfile repo is setup${NC}"
# else
#     echo -e "${PURPLE}---- setting up home to point to dotfiles${NC}"
#     git init -b master
#     git remote add origin https://github.com/kaushikgopal/dotfiles.git
#     git fetch origin
#     git reset --hard origin/master
# fi

git config --global credential.helper osxkeychain

function delete_if_exists {
    if [ -f "$1" ]; then
        # echo -e "$1 exists."
        echo -e "${PURPLE}---- $1 present, so deleting${NC}"
        sudo rm "$1"
        # else
        # echo -e "$1 does not exist."
    fi
}

function clone_if_absent {
    if [ ! -d "$1" ]; then
        echo -e "${PURPLE}---- $1 not present, so cloning${NC}"
        git clone $2 $1
    else
        echo -e "${GRAY}---- $1 already present. pulling latest version${NC}"
        cd $1
        git pull
        cd ..
    fi
}

if [[ "${REMOVE_LEGACY_GIT_PATHS:-0}" == "1" ]]; then
    echo -e "${GRAY}---- deleting legacy Git installer paths if present${NC}"
    delete_if_exists /etc/paths.d/git
    delete_if_exists /etc/manpaths.d/git
else
    echo -e "${GRAY}---- leaving legacy Git installer paths alone. Set REMOVE_LEGACY_GIT_PATHS=1 to remove them.${NC}"
fi

# ##############################################################
# # zsh shell
# ##############################################################
# #echo -e "\n\n\n${YELLOW}---- Setting up zsh shell through brew${NC}"
# #brew install zsh
#
# curl https://lab.al0.de/a0n/oh-my-zsh/-/raw/master/plugins/adb/_adb >$(brew --prefix)/share/zsh/site-functions/_adb
# chmod +x $(brew --prefix)/share/zsh/site-functions/_adb
#
# Allow GUI-launched apps to see the same config root. This can fail over
# headless SSH sessions, so it should not block the rest of bootstrap.
if ! launchctl setenv XDG_CONFIG_HOME ~/.config; then
    echo -e "${GRAY}---- launchctl setenv failed; continuing because shell config already exports XDG_CONFIG_HOME${NC}"
fi

# ##############################################################
# # Nu shell
# ##############################################################
#
# if [[ "nu" == $(basename "${SHELL}") ]]; then
#     echo -e "${GRAY}---- default shell is nu shell${NC}"
# else
#     echo -e "${GRAY}---- default shell is NOT nu shell${NC}"
#     sudo chsh -s $(brew --prefix)/bin/nu $(whoami)
# fi
#

##############################################################
# Fish shell
##############################################################

echo -e "\n\n\n${YELLOW}---- Setting up Fish${NC}"

echo -e "${GRAY}---- creating ~/.cache for fish shell init caches${NC}"
mkdir -p ~/.cache
if grep -Fxq "$(brew --prefix)/bin/fish" /etc/shells; then
    echo -e "${GRAY}---- fish declaration present${NC}"
else
    echo "$(brew --prefix)/bin/fish" | sudo tee -a /etc/shells
fi

if [[ "fish" == $(basename "${SHELL}") ]]; then
    echo -e "${GRAY}---- default shell is fish${NC}"
else
    echo -e "${GRAY}---- default shell is NOT fish${NC}"
    sudo chsh -s $(brew --prefix)/bin/fish $(whoami)
fi

# echo -e "${GRAY}---- symlink fish_history ${NC}"
# trash ~/.local/share/fish/fish_history
# ln -s $XDG_DATA_HOME/fish/fish_history ~/.local/share/fish/

fish_config theme choose "dracpro"
fish_config theme save

##############################################################
# DEV
##############################################################

#echo -e "\n\n\n${YELLOW}---- Setting up VSCode${NC}"
#echo -e "${PURPLE}---- remove existing settings if it exists${NC}"
#trash ~/Library/Application\ Support/Code/User/settings.json
#echo -e "${PURPLE}---- symlink .config version${NC}"
#ln -s  $XDG_CONFIG_HOME/vscode-settings.json  ~/Library/Application\ Support/Code/User/settings.json

#echo -e "\n\n\n${YELLOW}---- Setting up (neo)vim${NC}"
#mkdir -p $HOME/.vim/pack/kg/start
#cd $HOME/.vim/pack/kg/start

# clone_if_absent surround https://github.com/tpope/vim-surround.git
# clone_if_absent vim-polyglot https://github.com/sheerun/vim-polyglot
# clone_if_absent vim-smoothie https://github.com/psliwka/vim-smoothie.git
# clone_if_absent vim-vinegar https://github.com/tpope/vim-vinegar
# clone_if_absent targets https://github.com/wellle/targets.vim.git

#clone_if_absent plenary https://github.com/nvim-lua/plenary.nvim
#clone_if_absent telescope https://github.com/nvim-telescope/telescope.nvim
#clone_if_absent telescope-fzy-native https://github.com/nvim-telescope/telescope-fzy-native.nvim
#
#clone_if_absent vim-table-mode https://github.com/dhruvasagar/vim-table-mode.git
# # clone_if_absent vim-livedown https://github.com/shime/vim-livedown.git
# #clone_if_absent vimwiki "https://github.com/vimwiki/vimwiki --branch dev"
# #clone_if_absent taskwiki https://github.com/tools-life/taskwiki
#
# #clone_if_absent vim-monokai-pro https://github.com/phanviet/vim-monokai-pro.git
#clone_if_absent vim-colors-xcode https://github.com/arzg/vim-colors-xcode.git
# #clone_if_absent vim-airline https://github.com/vim-airline/vim-airline.git
# #clone_if_absent vim-airline-themes https://github.com/vim-airline/vim-airline-themes.git
# #clone_if_absent nord-vim https://github.com/arcticicestudio/nord-vim.git

# # clone_if_absent limelight https://github.com/junegunn/limelight.vim.git
# # clone_if_absent goyo https://github.com/junegunn/goyo.vim.git

# mkdir -p $HOME/_src
# cd $HOME/_src
#clone_if_absent gruvbox-idea https://github.com/kaushikgopal/gruvbox-idea.git
#clone_if_absent monokaush https://github.com/kaushikgopal/monokaush.git
#clone_if_absent xcode-11-theme https://github.com/kaushikgopal/xcode-11-theme.git
#clone_if_absent nord-iterm2 https://github.com/kaushikgopal/nord-iterm2.git
# clone_if_absent nord-terminal-app https://github.com/kaushikgopal/nord-terminal-app.git
# clone_if_absent nord-jetbrains https://github.com/kaushikgopal/nord-jetbrains.git

echo -e "${GRAY}---- moving home${NC}"
cd ~

# echo -e "\n\n\n${YELLOW}---- Install rbenv/ruby${NC}"
# installs the same ruby version as homebrew just installed via vim
# rbenv install -s $(brew info ruby | awk 'NR==1{print $3}')
# rbenv global $(brew info ruby | awk 'NR==1{print $3}')
# now pin ruby to this version, so it doesn't change on you with brew update
# brew pin ruby
# install bundler and gem stuff
# do this on a new terminal
# gem install bundler

#echo -e "\n\n\n${YELLOW}---- setup for go development${NC}"
#mkdir -p $HOME/_src/go
#mkdir -p $HOME/_src/go/src

# echo -e "\n\n\n${YELLOW}---- setup for python development${NC}"
# python setup
# pyenv install --list
# pyenv install 3.10.1
#ln -s -f /usr/local/bin/python3 /usr/local/bin/python

##############################################################
# MISC.
##############################################################

# if [ ! -f /usr/local/bin/pdflatex ]; then
#     echo -e "\n\n\n${PURPLE}---- enable quick look plugins${NC}"
#     sudo ln -s /Library/Tex/Distributions/.DefaultTeX/Contents/Programs/x86_64/pdflatex /usr/local/bin/
# fi

# echo -e "\n\n\n${YELLOW}---- Install TaskWarrior dependencies${NC}"
# needed for shift-recurrence pirate
# pip3 install --user git+git://github.com/GothenburgBitFactory/tasklib@develop

# fzf shell integration is generated and sourced by fish config.fish.
# source $HOME/.macos.sh
# source $HOME/.cleanup.sh


# # SDK man for .kt dev & kscript
# curl -s "https://get.sdkman.io" | bash
# sdk install kotlin

unset -f load_homebrew_shellenv
unset -f install_command_line_tools_if_missing
unset -f setup_aikado_agents
unset -f delete_if_exists
unset -f clone_if_absent
