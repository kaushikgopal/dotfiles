"===============================
" Kaushik Gopal's vimrc
" https://kau.sh
"===============================

" =========================================================
" General settings
" =========================================================

" change leader to a comma because the backslash is too far away
" that means all \x commands turn into ;x
" the mapleader has to be set before plugin manager starts loading all
" the plugins.
" let mapleader=";"

set nobackup         " turn backup off
set title            " change the terminal's title
set directory=/tmp// " change location of swap files


set ignorecase smartcase " ignore case letters when search
                         " make searches case-sensitive only if they contain
                         " upper-case characters
" =========================================================
" memory, cpu
" =========================================================

set history=100     " sets how many lines of history neovim has to remember
set lazyredraw      " faster scrolling
set synmaxcol=240   " syntax highlight only for N colums

" =========================================================
" Colorscheme Theme
" =========================================================
packadd! dracula_pro
syntax enable
let g:dracula_colorterm = 0
colorscheme dracula_pro_van_helsing

" =========================================================
" UI
" =========================================================

set mouse=a         " enable mouse support for vim
set nowrap          " wrap lines visually ; set wrap
"set nowrapscan     " don't continue the search after the end of a buffer
set visualbell      " stop vim from beeping at you when you make a mistake
syntax enable       " enable syntax highlighting
set number rnu      " show relative line numbers
set cursorline      " highlight current line
set showmatch       " highlight matching parenthesis
set scroll=20       " set the number of lines to scroll
set colorcolumn=100 " line length marker at 80 columns

"set splitright " open vertical split to the right
"set splitbelow " open horizontal split to the bottom

"Always show at least two lines above/below the cursor
if !&scrolloff
    set scrolloff=2
endif
if !&sidescrolloff
    set sidescrolloff=2
endif

" enable folding manually with 'marker' option
" use default 'foldmarker' (three consecutive open/closed curly braces)
set foldmethod=marker
set foldlevelstart=10 " no folds closed when buffer opens
" folding (for my memory)
" set foldmethod=syntax
" set foldlevelstart=1

" remove whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" =========================================================
" Tabs, indent
" =========================================================
set smartindent " autoindent new lines
set expandtab   " use spaces instead of tabs

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" =========================================================
" Statusline
" =========================================================
" lightline
" disable mode information under status line
" set noshowmode

" disable tmux on vim
"autocmd VimEnter,VimLeave * silent !tmux set status

" =========================================================
" Netrw : Vim's file browser
" =========================================================

"let g:netrw_altv=1  " open vertical split
let g:netrw_banner = 0
"let g:netrw_browse_split = 2
let g:netrw_list_hide= '.*\.swp$' " don't display .swp files
let g:netrw_liststyle = 3 " use tree style by default
"let g:netrw_winsize = 25 " set width to 25% of page

"===============================
" BASIC EDITING CONFIGURATION
"===============================

"set wildignore=*.swp,*.bak,*.pyc,*.class,*.jar,*.gif,*.png,*.jpg,*/build/* " ignore following files
"set smartcase
"set complete+=kspell  	    " turn on word completion dictionary https://robots.thoughtbot.com/vim-spell-checking
"set matchpairs+=<:>         " enable % matching for angle brackets

"set backspace=indent,eol,start  " allow backspacing over everything in insert mode
"set smartindent     " indent when starting new lines etc.
"set nowrap            " wrap lines visually ; set wrap
"set nowrapscan      " don't  continue the search after the end of a buffer
"set undolevels=1000      " use many muchos levels of undo

"set list "display tabs and trailing spaces
"if &listchars ==# 'eol:$' "Makes :set list (visible whitespace) prettier.
"  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
"endif

"set incsearch   "find the next match as we type the search
"set hlsearch    "highlight searches by default

" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") && &filetype != "gitcommit" |
   \   exe "normal g`\"" |
   \ endif

" ===================================
" autocmd (file settings/defaults)
" ===================================

augroup vimrcEx
    " Clear all autocmds in the group
    autocmd!

    " change markdown options
    autocmd BufNewFile,BufReadPost *.md set filetype=markdown
    " Limit column width for all markdown files
    autocmd BufNewFile,BufReadPost *.md,*.txt,*.markdown setlocal textwidth=80

    autocmd BufNewFile,BufReadPost *.fish set syntax=sh




    " Limit git commit message to 50 chars subject and 72 chars body
    autocmd FileType gitcommit
        \  hi def link gitcommitOverflow Error
        \| autocmd CursorMoved,CursorMovedI *
            \  let &l:textwidth = line('.') == 1 ? 50 : 72

augroup END


" =======================================================================
" TwiddleCase : Visually select the desired text
"                press the tilde character ~
"                to cycle through lower, upper & title
" =======================================================================

function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction
vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv

" =========================================================
" Keymapping / Keyboard shortcuts
" =========================================================

" Remap Space to something more useful (command entry)
noremap <Space> :
" clear search highlighting
nnoremap <silent> <CR> :nohl<CR><CR>
" in terminal mode (escape takes you back to normal mode)
:tnoremap <Esc> <C-\><C-n>
" U instead of control + r to redo a change
" nnoremap U <c-r>
" + instead of control + a to increase a number
noremap + <c-a>
" - instead of control + x to decrease a number
noremap - <c-x>
" 0 toggles between acting like ^ and 0 on second press
"nnoremap <expr> <silent> 0 col('.') == match(getline('.'),'\S')+0 ? '0' : '^'
nnoremap 0 ^

" Replace L -> $ (end of line)
"noremap L $
" toggle spell check
nnoremap <leader>s :set spell!<cr>

" clipboard adjustments
"xnoremap <leader>p "_dP
"nnoremap <leader>y "+y
"vnoremap <leader>y "+y
"nnoremap <leader>Y gg"+yG
"nnoremap <leader>d "_d
"vnoremap <leader>d "_d

" pad current line with empty line above/below/around
"inoremap <silent> <leader>o <C-\><C-O>:call append(line('.')-1, '')<CR><Esc>
"nnoremap <silent> <leader>o :call append(line('.')-1, '')<CR><Esc>
"inoremap <silent> <leader>O <C-\><C-O>:call append('.', '')<CR><Esc>
"nnoremap <silent> <leader>O :call append('.', '')<CR><Esc>
"inoremap <silent> <leader><CR> <C-\><C-O>:call append(line('.')-1, '')<CR><C-\><C-O>:call append('.', '')<CR><Esc>
"nnoremap <silent> <leader><CR> :call append(line('.')-1, '')<CR>:call append('.', '')<CR><Esc>

"========================
" Telescope related mappings
"========================
""
"" " cd into the directory passed through arg
"" au VimEnter * if isdirectory(argv(0)) | exec 'Telescope find_files cwd=' . argv(0) | endif
""
"lua <<EOF
"require("telescope").setup {
""    defaults = {
""        vimgrep_arguments = {
""            'rg',
""            '--color=never',
""            '--no-heading',
""            '--with-filename',
""            '--line-number',
""            '--column',
""            '-u', -- thats the new thing
""            '--smart-case'
""         }
""    },
""    pickers = {
""        find_files = {
""            -- remove ./ from fd results
""            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
""        },
""    }
""}
"EOF
""
" Using Lua functions
"nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
"nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
"nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
"nnoremap <leader>ft <cmd>lua require('telescope.builtin').help_tags()<cr>

"========================
" Spell checks
"========================

hi clear SpellBad
hi SpellBad cterm=underline,bold ctermfg=red
hi SpellBad gui=undercurl " Set style for gVim
" Don't mark URL-like things as spelling errors
" syn match UrlNoSpell '\w\+:\/\/[^[:space:]]\+' contains=@NoSpell

"========================
" show search results in center of screen
" https://www.reddit.com/r/vim/comments/oyqkkd/your_most_frequently_used_mapping/h7ung6k/?utm_source=share&utm_medium=ios_app&utm_name=iossmf&context=3
"========================

noremap <expr> <SID>(search-forward) 'Nn'[v:searchforward]
noremap <expr> <SID>(search-backward) 'nN'[v:searchforward]
nmap n <SID>(search-forward)zzzv
xmap n <SID>(search-forward)zzzv
nmap N <SID>(search-backward)zzzv
xmap N <SID>(search-backward)zzzv

"=========================
" Quick renaming of a file
"=========================
""
"function! RenameFile()
""    let old_name = expand('%')
""    let new_name = input('New file name: ', expand('%'), 'file')
""    if new_name != '' && new_name != old_name
""        exec ':saveas ' . new_name
""        exec ':silent !rm ' . old_name
""        redraw!
""    endif
"endfunction
""
" mnemonic is "edit filename"
"map <leader>e :call RenameFile()<cr>

"========================
" Markdown helpers
"========================

autocmd FileType markdown vmap <leader>l <Esc>`<i[<Esc>`>la]()<Esc>i
autocmd FileType markdown nmap <leader>l <Esc>bi[<Esc>ea]()<Esc>i
autocmd FileType markdown nmap <leader>L <Esc>bi[<Esc>$a]()<Esc>i

"========================
" Goyo (cleaner Markdown)
" for writing
"========================

function! s:goyo_enter()
    "colorscheme typewriter
    set noshowmode
    set noshowcmd
    "set scrolloff=999
    set wrap
    Limelight
endfunction

function! s:goyo_leave()
    set showmode
    set showcmd
    "set scrolloff=5
    Limelight!
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

"mnemonic is "write"
noremap <LocalLeader>w :Goyo<CR>

" ==========================
" Multipurpose tab key
" Indent if we're at the beginning of a line. Else, do completion.
" ==========================
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col
        return "\<tab>"
    endif

    let char = getline('.')[col - 1]
    if char =~ '\k'
        " There's an identifier before the cursor, so complete the identifier.
        return "\<c-p>"
    else
        return "\<tab>"
    endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-n>

" ==========================
" Plugins
" ==========================

"let g:g:smoothie_enabled=0
set rtp+=~/.vim/plugins/vim-smoothie

