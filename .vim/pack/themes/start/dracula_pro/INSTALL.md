### [Vim](http://www.vim.org/)

#### Install

These are the default instructions using Vim 8's `|packages|` feature.

1. Create theme folder (in case you don't have it yet):

- `\*nix` with vim:
```bash
# vim 8.2+
mkdir -p ~/.vim/pack/themes/start
# vim 8.0
mkdir -p ~/.vim/pack/themes/opt
```

- `\*nix` with neovim:
```bash
nvim +'call mkdir(stdpath("data")."/site/pack/themes/start", "p")' +q
```

- Windows with vim: create directory `$HOME\vimfiles\pack\themes\start` or
  `$HOME\vimfiles\pack\themes\opt`, according to your version.

2. Copy the `vim` folder and rename to "dracula_pro":

- `\*nix` with vim:
```bash
# change according to your version above
cp -r vim ~/.vim/pack/themes/start/dracula_pro
```

- `\*nix` with neovim:
```bash
cp -r vim "$(nvim -es +'put =stdpath("data")' +print +'q!')"/site/pack/themes/start/dracula_pro
```

#### Activate

1. Edit your vimrc file (`:help vimrc`):

- `\*nix` with vim: edit `~/.vimrc` or `~/.vim/vimrc`
- `\*nix` with neovim: edit `~/.config/nvim/init.vim`

- Windows with vim: edit `$HOME\_vimrc` or `$HOME\vimfiles\vimrc`
- Windows with neovim: edit `~/AppData/Local/nvim/init.vim`

with the following content

```
" For packages, versions 8.2 and later will autoload `start` packages
" correctly even in your vimrc.
if v:version < 802
    packadd! dracula
endif
syntax enable
let g:dracula_colorterm = 0
colorscheme dracula_pro
```

P.S.: You need a 256-color or truecolor terminal and you may want one that
supports xterm sequences for :terminal.
