call plug#begin()
    Plug 'MunifTanjim/nui.nvim'
    Plug 'nvim-lua/plenary.nvim', {'tag': 'v0.1.3'}
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'lewis6991/gitsigns.nvim', {'tag': 'v1.0.2'}
    Plug 'willothy/flatten.nvim', {'tag': 'v0.5.1'}
    Plug 'StarQTius/onedark.nvim'
    Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
call plug#end()

let s:make_background_transparent = get(g:, "make_background_transparent", "v:true")

let g:onedark_config = {
  \ 'style': 'cool',
  \ 'transparent': s:make_background_transparent,
  \ 'term_colors': v:false,
\ }

lua require('init')

colorscheme onedark

" Set tab properties
set tabstop=2
set shiftwidth=2
set expandtab

set splitright
set jumpoptions=stack

let g:netrw_banner = 0

command -nargs=? -complete=file Browse lua browse(<f-args>)
cnoreabbrev bw Browse

command -nargs=? -complete=file BrowseSplit vsplit | Browse <args>
cnoreabbrev bs BrowseSplit

command -nargs=? Quickfind lua quickfind(<f-args>)
cnoreabbrev qf Quickfind

command -nargs=? QuickfindSplit vsplit | Quickfind <args>
cnoreabbrev qs QuickfindSplit

command -nargs=? Deepfind lua deepfind(<f-args>)
cnoreabbrev df Deepfind

command -nargs=? DeepfindSplit vsplit | Deepfind <args>
cnoreabbrev ds DeepfindSplit

command -nargs=? -complete=file Shell lua shell(<f-args>)
cnoreabbrev sh Shell

command -nargs=? -complete=file ShellSplit vsplit | Shell <args>
cnoreabbrev ss ShellSplit

cnoreabbrev gs Gitsigns

command -nargs=? -complete=file Bclear vsplit | bufdo if stridx(expand("%"), <q-args>) == 0 | bdelete | vsplit | endif | quit
cnoreabbrev bc Bclear

" Move around between panes
map <A-Left> <C-w><Left>
map <A-Right> <C-w><Right>
map <A-Up> <C-w><Up>
map <A-Down> <C-w><Down>

" Move faster vertically
nnoremap <C-Up> 5<Up>
nnoremap <C-Down> 5<Down>

" I want to try web movements
map <C-Left> <NOP>
map <C-Right> <NOP>

tmap <Esc> <C-\><C-n>

" Truly clear the terminal
tmap <c-l> <C-\><C-n>:set scrollback=1 \| sleep 100m \| set scrollback=10000<cr>iclear<cr>

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

" Move betweem hunks
nmap <C-u> :Gitsigns prev_hunk<CR>
nmap <C-d> :Gitsigns next_hunk<CR>

" Do not substitute register content with replaced text when pasting
nnoremap p ""p

" Jump to a subject
nnoremap <CR> <C-]>

" Jump back
nnoremap <BS> <C-o>

" Color .map file as LUA source
autocmd BufRead,BufNewFile *.map set filetype=lua

" Hide status lines
set laststatus=0
hi! link StatusLine Normal
hi! link StatusLineNC Normal
set statusline=%{repeat('─',winwidth('.'))}

