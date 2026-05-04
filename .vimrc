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

set incsearch   "find the next match as we type the search
set hlsearch    "highlight searches by default

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


" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") && &filetype != "gitcommit" |
   \   exe "normal g`\"" |
   \ endif


" =========================================================
" memory, cpu
" =========================================================

set history=100     " sets how many lines of history neovim has to remember
set lazyredraw      " faster scrolling
set synmaxcol=240   " syntax highlight only for N colums

" =========================================================
" Colorscheme Theme
" =========================================================
set termguicolors     " enable true color (24-bit RGB) support
syntax enable

packadd! dracula_pro
let g:dracula_colorterm = 0
" set background=dark
" colorscheme dracula_pro

" Glow's Markdown renderer uses simple terminal styles instead of a Vim
" colorscheme. Keep the approximation narrow: Markdown syntax gets Glow-like
" colors, and Markdown windows get a quieter document background without
" changing the rest of the editor.
function! s:GlowHi(group, fg, bg, attr) abort
    execute 'highlight ' . a:group
        \ . ' guifg=' . (empty(a:fg) ? 'NONE' : a:fg)
        \ . ' guibg=' . (empty(a:bg) ? 'NONE' : a:bg)
        \ . ' gui=' . (empty(a:attr) ? 'NONE' : a:attr)
endfunction

function! s:ApplyGlowMarkdownHighlights() abort
    if &background ==# 'light'
        let l:document_fg = '#1c1c1c'
        let l:document_bg = '#fffdf5'
        let l:muted = '#6c6c6c'
        let l:dim = '#b2b2b2'
        let l:heading = '#005fff'
        let l:link = '#00af87'
        let l:link_text = '#00875f'
        let l:inline_code_bg = '#e4e4e4'
        let l:code_block_bg = '#eeeeee'
    else
        let l:document_fg = '#d0d0d0'
        let l:document_bg = '#1b1b1b'
        let l:muted = '#808080'
        let l:dim = '#585858'
        let l:heading = '#00afff'
        let l:link = '#008787'
        let l:link_text = '#00af5f'
        let l:inline_code_bg = '#303030'
        let l:code_block_bg = '#373737'
    endif

    call s:GlowHi('GlowMarkdownNormal', l:document_fg, l:document_bg, 'NONE')
    call s:GlowHi('GlowMarkdownMuted', l:muted, 'NONE', 'NONE')
    call s:GlowHi('GlowMarkdownLineNr', l:dim, l:document_bg, 'NONE')
    call s:GlowHi('GlowMarkdownCursorLine', 'NONE', l:inline_code_bg, 'NONE')
    call s:GlowHi('GlowMarkdownCursorLineNr', l:heading, l:document_bg, 'bold')
    call s:GlowHi('GlowMarkdownColorColumn', 'NONE', l:inline_code_bg, 'NONE')
    call s:GlowHi('GlowMarkdownHeading', l:heading, 'NONE', 'bold')
    call s:GlowHi('GlowMarkdownH1', '#ffff87', '#5f5fff', 'bold')
    call s:GlowHi('GlowMarkdownCode', '#ff5f5f', l:inline_code_bg, 'NONE')
    call s:GlowHi('GlowMarkdownCodeBlock', l:muted, l:code_block_bg, 'NONE')
    call s:GlowHi('GlowMarkdownQuote', l:muted, 'NONE', 'NONE')
    call s:GlowHi('GlowMarkdownLink', l:link, 'NONE', 'underline')
    call s:GlowHi('GlowMarkdownLinkText', l:link_text, 'NONE', 'bold')
    call s:GlowHi('GlowMarkdownListMarker', l:link_text, 'NONE', 'bold')
    call s:GlowHi('GlowMarkdownRule', l:dim, 'NONE', 'NONE')
    call s:GlowHi('GlowMarkdownEmphasis', 'NONE', 'NONE', 'italic')
    call s:GlowHi('GlowMarkdownStrong', 'NONE', 'NONE', 'bold')
    call s:GlowHi('GlowMarkdownStrongEmphasis', 'NONE', 'NONE', 'bold,italic')
    call s:GlowHi('GlowMarkdownStrike', l:muted, 'NONE', 'strikethrough')

    highlight! link markdownH1 GlowMarkdownH1
    highlight! link markdownH2 GlowMarkdownHeading
    highlight! link markdownH3 GlowMarkdownHeading
    highlight! link markdownH4 GlowMarkdownHeading
    highlight! link markdownH5 GlowMarkdownHeading
    highlight! link markdownH6 GlowMarkdownHeading
    highlight! link markdownH1Delimiter GlowMarkdownH1
    highlight! link markdownH2Delimiter GlowMarkdownHeading
    highlight! link markdownH3Delimiter GlowMarkdownHeading
    highlight! link markdownH4Delimiter GlowMarkdownHeading
    highlight! link markdownH5Delimiter GlowMarkdownHeading
    highlight! link markdownH6Delimiter GlowMarkdownHeading
    highlight! link markdownHeadingDelimiter GlowMarkdownHeading
    highlight! link markdownHeadingRule GlowMarkdownRule
    highlight! link markdownBlockquote GlowMarkdownQuote
    highlight! link markdownCode GlowMarkdownCode
    highlight! link markdownCodeBlock GlowMarkdownCodeBlock
    highlight! link markdownCodeDelimiter GlowMarkdownCodeBlock
    highlight! link markdownLinkText GlowMarkdownLinkText
    highlight! link markdownLinkTextDelimiter GlowMarkdownMuted
    highlight! link markdownLinkDelimiter GlowMarkdownMuted
    highlight! link markdownUrl GlowMarkdownLink
    highlight! link markdownUrlDelimiter GlowMarkdownMuted
    highlight! link markdownUrlTitle GlowMarkdownMuted
    highlight! link markdownListMarker GlowMarkdownListMarker
    highlight! link markdownOrderedListMarker GlowMarkdownListMarker
    highlight! link markdownRule GlowMarkdownRule
    highlight! link markdownBold GlowMarkdownStrong
    highlight! link markdownBoldDelimiter GlowMarkdownMuted
    highlight! link markdownItalic GlowMarkdownEmphasis
    highlight! link markdownItalicDelimiter GlowMarkdownMuted
    highlight! link markdownBoldItalic GlowMarkdownStrongEmphasis
    highlight! link markdownBoldItalicDelimiter GlowMarkdownMuted
    highlight! link markdownStrike GlowMarkdownStrike
    highlight! link markdownStrikeDelimiter GlowMarkdownMuted
endfunction

function! s:SyncGlowMarkdownWindowTheme() abort
    if &filetype ==# 'markdown'
        if exists('&winhighlight')
            let &l:winhighlight = join([
                \ 'Normal:GlowMarkdownNormal',
                \ 'NormalNC:GlowMarkdownNormal',
                \ 'EndOfBuffer:GlowMarkdownNormal',
                \ 'SignColumn:GlowMarkdownNormal',
                \ 'LineNr:GlowMarkdownLineNr',
                \ 'CursorLine:GlowMarkdownCursorLine',
                \ 'CursorLineNr:GlowMarkdownCursorLineNr',
                \ 'ColorColumn:GlowMarkdownColorColumn',
                \ 'Folded:GlowMarkdownCodeBlock',
                \ 'NonText:GlowMarkdownMuted',
                \ 'SpecialKey:GlowMarkdownMuted',
                \ ], ',')
        elseif exists('&wincolor')
            let &l:wincolor = 'GlowMarkdownNormal'
        endif
    else
        if exists('&winhighlight') && &l:winhighlight =~# 'GlowMarkdown'
            setlocal winhighlight=
        endif
        if exists('&wincolor') && &l:wincolor ==# 'GlowMarkdownNormal'
            setlocal wincolor=
        endif
    endif
endfunction

augroup vimrcGlowMarkdown
    autocmd!
    autocmd ColorScheme * call <SID>ApplyGlowMarkdownHighlights()
        \ | call <SID>SyncGlowMarkdownWindowTheme()
    autocmd FileType markdown call <SID>SyncGlowMarkdownWindowTheme()
    autocmd BufEnter,WinEnter * call <SID>SyncGlowMarkdownWindowTheme()
augroup END

" Auto-switch dark/light theme based on macOS appearance.
function! SyncAppearance() abort
    let l:mode = system("defaults read -g AppleInterfaceStyle 2>/dev/null")
    if l:mode =~# 'Dark'
        set background=dark
        colorscheme dracula_pro
    else
        colorscheme dracula_pro_alucard
    endif
endfunction

call SyncAppearance()

augroup vimrcAppearance
    autocmd!
    autocmd FocusGained * call SyncAppearance()
augroup END


" =========================================================
" UI
" =========================================================

set mouse=a         " enable mouse support for vim
set nowrap          " wrap lines visually ; set wrap
"set nowrapscan     " don't continue the search after the end of a buffer
set visualbell      " stop vim from beeping at you when you make a mistake
syntax enable       " enable syntax highlighting
set number rnu       " rnu = show relative line numbers " nu = regular line numbers
set cursorline      " highlight current line
set showmatch       " highlight matching parenthesis
"set scroll=10       " set the number of lines to scroll
set colorcolumn=80  " line length marker at 80 columns

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
" Cursor settings
" =========================================================
" force the cursor mode (for shells like nushell which allow customization)
" https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes#For_Terminal_on_macOS

:set timeout ttimeoutlen=100 "see https://vi.stackexchange.com/questions/15633
let &t_SI.="\<Esc>[6 q"  " Insert mode: solid vertical bar
let &t_SR.="\<Esc>[1 q"  " Replace mode: blinking block
let &t_EI.="\<Esc>[2 q"  " Normal mode: solid block
let &t_te.="\<Esc>[0 q"  " Terminal end: default
let &t_ti.="\<Esc>[0 q"  " Terminal init: solid block

"Cursor settings:

"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar


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

" ===================================
" autocmd (file settings/defaults)
" ===================================

" Limit column width for all markdown files
" auto hard wrap markdown files to 80
au BufRead,BufNewFile *.md,*.txt,*.markdown setlocal textwidth=80

augroup vimrcEx
    " Clear all autocmds in the group
    autocmd!

    " change markdown options
    autocmd BufNewFile,BufReadPost *.md set filetype=markdown
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
" U instead of control + r to redo a change
nnoremap U <c-r>
" + instead of control + a to increase a number
noremap + <c-a>
" - instead of control + x to decrease a number
noremap - <c-x>
" 0 toggles between acting like ^ and 0 on second press
"nnoremap <expr> <silent> 0 col('.') == match(getline('.'),'\S')+0 ? '0' : '^'
"nnoremap 0 ^

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

" newer vim versions will sync clilpboard now
set clipboard=unnamed

" Keep the file tree predictable and make the split read like a thin divider
" instead of a reversed block. The box-drawing glyph renders more cleanly in
" terminal Vim than the default pipe.
let g:netrw_winsize = -40
set fillchars-=vert:\|
set fillchars+=vert:│
highlight VertSplit cterm=NONE gui=NONE ctermfg=240 ctermbg=NONE guifg=#6272A4 guibg=NONE
highlight WinSeparator cterm=NONE gui=NONE ctermfg=240 ctermbg=NONE guifg=#6272A4 guibg=NONE

" Toggle the left-hand file tree and keep edits in the main window.
nnoremap <silent> <leader>e :Lexplore<CR>

" pad current line with empty line above/below/around
"inoremap <silent> <leader>o <C-\><C-O>:call append(line('.')-1, '')<CR><Esc>
"nnoremap <silent> <leader>o :call append(line('.')-1, '')<CR><Esc>
"inoremap <silent> <leader>O <C-\><C-O>:call append('.', '')<CR><Esc>
"nnoremap <silent> <leader>O :call append('.', '')<CR><Esc>
"inoremap <silent> <leader><CR> <C-\><C-O>:call append(line('.')-1, '')<CR><C-\><C-O>:call append('.', '')<CR><Esc>
"nnoremap <silent> <leader><CR> :call append(line('.')-1, '')<CR>:call append('.', '')<CR><Esc>

"=========================
" FZF quick flie search
"=========================
" If installed using Homebrew
" set rtp+=/usr/local/opt/fzf
set rtp+=/opt/homebrew/opt/fzf  " Apple Silicon
" :Files inherits from the default fzf command.
let g:fzf_vim = {}
let g:fzf_vim.preview_window = ['right,60%', 'ctrl-/']
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>g :Rg<CR>


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

" Format markdown with prettier on :w (toggle with :MdFmtToggle).
let g:md_fmt_on_save = 1

function! PrettierMarkdown(...) abort
    if !g:md_fmt_on_save && !a:0 | return | endif
    if !executable('prettier')
        echohl ErrorMsg | echom 'prettier: command not found' | echohl None
        return
    endif

    let l:prose_wrap = a:0 ? a:1 : get(b:, 'md_prose_wrap', 'always')
    let l:filepath = expand('%:p')
    if empty(l:filepath)
        let l:filepath = 'stdin.md'
    endif

    let l:view = winsaveview()
    execute 'silent %!prettier --prose-wrap ' . shellescape(l:prose_wrap) .
        \ ' --stdin-filepath ' . shellescape(l:filepath)
    if v:shell_error
        undo
        echohl ErrorMsg | echom 'prettier: format failed' | echohl None
    endif
    call winrestview(l:view)
endfunction

function! MarkdownWrap(prose_wrap, textwidth) abort
    let b:md_prose_wrap = a:prose_wrap
    let &l:textwidth = a:textwidth
    call PrettierMarkdown(a:prose_wrap)
    echo 'Markdown hard wrap: ' . (a:textwidth ? 'ON' : 'OFF') . ' for this buffer'
endfunction

autocmd BufWritePre *.md,*.markdown call PrettierMarkdown()
command! MdFmtToggle let g:md_fmt_on_save = !g:md_fmt_on_save
    \ | echo 'Markdown format-on-save: ' . (g:md_fmt_on_save ? 'ON' : 'OFF')
command! MdUnwrap call MarkdownWrap('never', 0)
command! MdHardWrap call MarkdownWrap('always', 80)
command! MdSoftWrap setlocal wrap linebreak breakindent
command! MdNoSoftWrap setlocal nowrap nolinebreak nobreakindent

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
