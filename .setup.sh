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

##############################################################
# Setup the dotfiles symlinks
##############################################################

# capture the current directory
current_dir=$(pwd)

# move into the home directory first
pushd $HOME

mkdir -p .config
mkdir -p .config/karabiner  # see https://github.com/kaushikgopal/karabiner-kt.git for karabiner.json

# List of files to symlink (one per line for easy maintenance)
files_to_link=(
    .ai
    .bashrc
    .brewfile
    .brew.sh
    .claude
    .config/.ripgreprc
    .config/fish
    .config/ghostty
    .config/git
    .config/serie
    .config/zed
    .editorconfig
    .firebender
    .hushlogin
    .ideavimrc
    .profile
    .vim
    .vimrc
    bin
    AGENTS.md
)

for file in "${files_to_link[@]}"; do
    echo -e "${GRAY}••••••• symlinking $current_dir/$file -> $HOME/$file ${NC}"
    rm -rf "$HOME/$file"
    ln -sfn "$current_dir/$file" "$HOME/$file"
done

popd

# exit the script (temporarily)
exit 0

##############################################################
# Basics (git & dotfiles)
##############################################################

echo -e "\n\n\n${PURPLE}---- Check for Apple Software Updates then restart your computer. \n Have you done this (no seriously!)${NC}"

echo -e "\n\n\n${YELLOW}---- installing Xcode command tools (without all of Xcode)${NC}"
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
softwareupdate --install -a --verbose
rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# install xcode
# xcode-select --install

echo -e "${YELLOW}---- setting up homebrew${NC}"

if ! command -v brew &>/dev/null; then
    echo -e "\n\n\n${YELLOW}---- Homebrew not found. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GRAY}---- Homebrew is already installed.${NC}"
fi

echo -e "${GRAY}---- Turning homebrew analytics off.${NC}"
brew analytics off

echo -e "${YELLOW}---- setting up github${NC}"
brew install git
brew install gh

echo -e "\n\n\n${YELLOW}---- Setting up git${NC}"
gh auth status &>tmp_gh_login.txt
if grep -om1 "Logged in" tmp_gh_login.txt; then
    rm -f tmp_gh_login.txt
    echo -e "${GRAY}---- logged in to github${NC}"
else
    rm -f tmp_gh_login.txt
    echo -e "${PURPLE}---- you need to setup github, follow the prompts now ${NC}"
    gh auth login
fi

echo -e "${YELLOW}---- setting up dotfiles${NC}"
cd $HOME

if git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${GRAY}---- looks like dotfile repo is setup${NC}"
else
    echo -e "${PURPLE}---- setting up home to point to dotfiles${NC}"
    git init -b master
    git remote add origin https://github.com/kaushikgopal/dotfiles.git
    git fetch origin
    git reset --hard origin/master
fi

git config --global credential.helper osxkeychain

echo -e "${YELLOW}---- Asking for an admin password upfront${NC}"
sudo -v

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

# echo -e "${GRAY}---- delete native git if it exists${NC}"
# # sudo rm -rf /usr/bin/git
# delete_if_exists /etc/paths.d/git
# delete_if_exists /etc/manpaths.d/git
# # sudo pkgutil --forget --pkgs=GitOSX\.Installer\.git[A-Za-z0-9]*\.[a-z]*.pkg

##############################################################
# zsh shell
##############################################################
#echo -e "\n\n\n${YELLOW}---- Setting up zsh shell through brew${NC}"
#brew install zsh

curl https://lab.al0.de/a0n/oh-my-zsh/-/raw/master/plugins/adb/_adb >$(brew --prefix)/share/zsh/site-functions/_adb
chmod +x $(brew --prefix)/share/zsh/site-functions/_adb

# allow different shells to recognize this environment variable for macos
launchctl setenv XDG_CONFIG_HOME ~/.config

##############################################################
# Nu shell
##############################################################

if [[ "nu" == $(basename "${SHELL}") ]]; then
    echo -e "${GRAY}---- default shell is nu shell${NC}"
else
    echo -e "${GRAY}---- default shell is NOT nu shell${NC}"
    sudo chsh -s $(brew --prefix)/bin/nu $(whoami)
fi


##############################################################
# Fish shell
##############################################################

echo -e "\n\n\n${YELLOW}---- Setting up Fish${NC}"
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

echo -e "${GRAY}---- symlink fish_history ${NC}"
trash ~/.local/share/fish/fish_history
ln -s $XDG_DATA_HOME/fish/fish_history ~/.local/share/fish/

fish_config theme choose "Dracula Official"
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

if [ ! -f /usr/local/bin/pdflatex ]; then
    echo -e "\n\n\n${PURPLE}---- enable quick look plugins${NC}"
    sudo ln -s /Library/Tex/Distributions/.DefaultTeX/Contents/Programs/x86_64/pdflatex /usr/local/bin/
fi

# echo -e "\n\n\n${YELLOW}---- Install TaskWarrior dependencies${NC}"
# needed for shift-recurrence pirate
# pip3 install --user git+git://github.com/GothenburgBitFactory/tasklib@develop

source $HOME/.brew.sh
$(brew --prefix)/opt/fzf/install
# source $HOME/.macos.sh
# source $HOME/.cleanup.sh

# if (( $# > 0 ))
# then
#     # atleast one argument supplied
#     echo -e "${GRAY}---- ignoring OS updates${NC}"
#     echo -e "${GRAY}---- ignoring Mac specific changes${NC}"
# else
#     source $HOME/.config/macos.sh
#
#     echo -e "\n\n\n${YELLOW}---- running macOS system update now${NC}"
#     touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
#     softwareupdate --install -a --verbose
#     rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
xcode-select --install
#sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcode-select --switch /Library/Developer/CommandLineTools/
# fi

# SDK man for .kt dev & kscript
curl -s "https://get.sdkman.io" | bash
sdk install kotlin

mkdir -p ~/.warp/themes
pushd ~/.warp/themes
git clone https://github.com/juliabresolin/warp-theme-dark-modern
popd

unset delete_if_exists
unset clone_if_absent
