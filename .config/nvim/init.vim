call plug#begin()
    Plug 'morhetz/gruvbox'
    Plug 'nvim-neo-tree/neo-tree.nvim', {'branch': 'v2.x'}
    Plug 'MunifTanjim/nui.nvim'
    Plug 'nvim-lua/plenary.nvim', {'tag': 'v0.1.3'}
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'lewis6991/gitsigns.nvim', {'tag': 'v0.6'}
    Plug 'willothy/flatten.nvim', {'tag': 'v0.5.1'}
call plug#end()

colorscheme gruvbox

lua require('gitsigns-config')
lua require('clangd-config')
lua require('flatten-config')

" Set tab properties
set tabstop=2
set shiftwidth=2
set expandtab

" Set the background transparent
hi Normal guibg=NONE ctermbg=NONE

" Toggle the file tree and focus on it
map <A-t> :NeoTreeFocusToggle<enter>

" Move around between panes
map <A-Left> <C-w><Left>
map <A-Right> <C-w><Right>
map <A-Up> <C-w><Up>
map <A-Down> <C-w><Down>

" Exit TERMINAL with ESC
tnoremap <Esc> <C-\><C-n>

" Truly clear the terminal
tmap <c-l> <Esc>:set scrollback=1 \| sleep 1m \| set scrollback=10000<cr>iclear<cr>

" Allow to change tab using function keys with NVO modes
map <A-&> :tabn 1<CR>
map <A-é> :tabn 2<CR>
map <A-"> :tabn 3<CR>
map <A-'> :tabn 4<CR>
map <A-(> :tabn 5<CR>
map <A--> :tabn 6<CR>
map <A-è> :tabn 7<CR>
map <A-_> :tabn 8<CR>
map <A-ç> :tabn 9<CR>
map <A-à> :tabn 10<CR>

" Allow to change tab using function keys with IC modes
map! <A-&> <ESC>:tabn 1<CR>
map! <A-é> <ESC>:tabn 2<CR>
map! <A-"> <ESC>:tabn 3<CR>
map! <A-'> <ESC>:tabn 4<CR>
map! <A-(> <ESC>:tabn 5<CR>
map! <A--> <ESC>:tabn 6<CR>
map! <A-è> <ESC>:tabn 7<CR>
map! <A-_> <ESC>:tabn 8<CR>
map! <A-ç> <ESC>:tabn 9<CR>
map! <A-à> <ESC>:tabn 10<CR>

" Allow to change tab using function keys with TERMINAL mode
tmap <A-&> <ESC>:tabn 1<CR>
tmap <A-é> <ESC>:tabn 2<CR>
tmap <A-"> <ESC>:tabn 3<CR>
tmap <A-'> <ESC>:tabn 4<CR>
tmap <A-(> <ESC>:tabn 5<CR>
tmap <A--> <ESC>:tabn 6<CR>
tmap <A-è> <ESC>:tabn 7<CR>
tmap <A-_> <ESC>:tabn 8<CR>
tmap <A-ç> <ESC>:tabn 9<CR>
tmap <A-à> <ESC>:tabn 10<CR>

" Do not substitute register content with replaced text when pasting
nnoremap p ""p

" Populate neovim path variable with directories tracked by git
let &path = system("begin; git ls-files --others --exclude-standard; git ls-files; end | xargs dirname | sort | uniq | sed -z 's:\\n:,:g'")
