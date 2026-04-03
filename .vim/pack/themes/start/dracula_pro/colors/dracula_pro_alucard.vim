runtime autoload/dracula_pro.vim

let g:dracula_pro#palette.comment   = ['#635D97', 60]
let g:dracula_pro#palette.selection = ['#CFCFDE', 188]
let g:dracula_pro#palette.subtle    = ['#DCDEEF', 189]

let g:dracula_pro#palette.bglighter = ['#FFFFFF', 15]
let g:dracula_pro#palette.bglight   = ['#F5F5F5', 15]
let g:dracula_pro#palette.bg        = ['#F5F5F5', 15]
let g:dracula_pro#palette.bgdark    = ['#E6E6E6', 254]
let g:dracula_pro#palette.bgdarker  = ['#B8B8B8', 249]

" This cterm value adjusted by hand. Conversion function gives 66, which is too
" blue compared to the grey. 242 (0x6C6C6C) is visually closer.
let g:dracula_pro#palette.fg        = ['#1F1F1F', 234]

let g:dracula_pro#palette.cyan      = ['#036A96', 24]
let g:dracula_pro#palette.green     = ['#14710A', 22]
let g:dracula_pro#palette.orange    = ['#A34D14', 130]
let g:dracula_pro#palette.pink      = ['#A3144D', 125]
let g:dracula_pro#palette.purple    = ['#644AC9', 62]
let g:dracula_pro#palette.red       = ['#CB3A2A', 166]
let g:dracula_pro#palette.yellow    = ['#846E15', 94]

" ANSI
" Note that these blacks and whites are swapped because this is a light
" colorscheme. Also, MacVim (not sure about GVim) always uses a black terminal
" background, which is unhelpful in this case.

" black (background)
let g:dracula_pro#palette.color_0  = g:dracula_pro#palette.bg[0]
" dark red
let g:dracula_pro#palette.color_1  = g:dracula_pro#palette.red[0]
" dark green
let g:dracula_pro#palette.color_2  = g:dracula_pro#palette.green[0]
" brown/yellow
let g:dracula_pro#palette.color_3  = g:dracula_pro#palette.yellow[0]
" dark blue
let g:dracula_pro#palette.color_4  = g:dracula_pro#palette.purple[0]
" dark magenta
let g:dracula_pro#palette.color_5  = g:dracula_pro#palette.pink[0]
" dark cyan
let g:dracula_pro#palette.color_6  = g:dracula_pro#palette.cyan[0]
" light grey/white (foreground)
let g:dracula_pro#palette.color_7  = g:dracula_pro#palette.fg[0]
" dark grey
let g:dracula_pro#palette.color_8  = g:dracula_pro#palette.comment[0]
" (bright) red
let g:dracula_pro#palette.color_9  = '#D74C3D'
" (bright) green
let g:dracula_pro#palette.color_10 = '#198D0C'
" (bright) yellow
let g:dracula_pro#palette.color_11 = '#9E841A'
" (bright) blue/purple
let g:dracula_pro#palette.color_12 = '#7862D0'
" (bright) magenta/pink
let g:dracula_pro#palette.color_13 = '#BF185A'
" bright cyan
let g:dracula_pro#palette.color_14 = '#047FB4'
" white (bright foreground)
let g:dracula_pro#palette.color_15 = '#2C2B31'

runtime colors/dracula_pro_base.vim

" Fix Pmenu. The BgDark is too close to the selection value.
highlight! link Pmenu      DraculaBgLighter
highlight! link PmenuSbar  DraculaBgLighter

let g:colors_name = 'dracula_pro_alucard'
