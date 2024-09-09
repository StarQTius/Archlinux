call plug#begin()
    Plug 'MunifTanjim/nui.nvim'
    Plug 'nvim-lua/plenary.nvim', {'tag': 'v0.1.3'}
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'lewis6991/gitsigns.nvim', {'tag': 'v0.6'}
    Plug 'willothy/flatten.nvim', {'tag': 'v0.5.1'}
    Plug 'StarQTius/onedark.nvim'
call plug#end()

let g:onedark_config = {
  \ 'style': 'deep',
  \ 'transparent': 'true',
  \ 'term_colors': 'false',
\ }
colorscheme onedark

lua require('gitsigns-config')
lua require('clangd-config')
lua require('flatten-config')

" Set tab properties
set tabstop=2
set shiftwidth=2
set expandtab

" Toggle the file tree and focus on it
map <A-t> :e .<cr>

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
map <A-1> :tabn 1<CR>
map <A-2> :tabn 2<CR>
map <A-3> :tabn 3<CR>
map <A-4> :tabn 4<CR>
map <A-5> :tabn 5<CR>
map <A-6> :tabn 6<CR>
map <A-7> :tabn 7<CR>
map <A-8> :tabn 8<CR>
map <A-9> :tabn 9<CR>
map <A-0> :tabn 10<CR>

" Allow to change tab using function keys with IC modes
map! <A-1> <ESC>:tabn 1<CR>
map! <A-2> <ESC>:tabn 2<CR>
map! <A-3> <ESC>:tabn 3<CR>
map! <A-4> <ESC>:tabn 4<CR>
map! <A-5> <ESC>:tabn 5<CR>
map! <A-6> <ESC>:tabn 6<CR>
map! <A-7> <ESC>:tabn 7<CR>
map! <A-8> <ESC>:tabn 8<CR>
map! <A-9> <ESC>:tabn 9<CR>
map! <A-0> <ESC>:tabn 10<CR>

" Allow to change tab using function keys with TERMINAL mode
tmap <A-1> <ESC>:tabn 1<CR>
tmap <A-2> <ESC>:tabn 2<CR>
tmap <A-3> <ESC>:tabn 3<CR>
tmap <A-4> <ESC>:tabn 4<CR>
tmap <A-5> <ESC>:tabn 5<CR>
tmap <A-6> <ESC>:tabn 6<CR>
tmap <A-7> <ESC>:tabn 7<CR>
tmap <A-8> <ESC>:tabn 8<CR>
tmap <A-9> <ESC>:tabn 9<CR>
tmap <A-0> <ESC>:tabn 10<CR>

" Do not substitute register content with replaced text when pasting
nnoremap p ""p

" Populate neovim path variable with directories tracked by git
let &path = system("
\ begin;
\ git ls-files --others --exclude-standard;
\   git ls-files;
\ end |
\ xargs dirname |
\ sort |
\ uniq |
\ sed -z 's:\\n:,:g'")
