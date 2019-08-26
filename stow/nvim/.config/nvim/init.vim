" enable 24-bit color
set termguicolors

let mapleader = "\<Space>"

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" exit out of insert mode with jk 
inoremap jk <ESC>

nnoremap <Leader>f :NERDTreeToggle<CR>
nnoremap <Leader>v :NERDTreeFind<CR>

" plugins
call plug#begin()

Plug 'dag/vim-fish'

" automatically close brackets
Plug 'Raimondi/delimitMate'

" add more targets, e.g. ci, ca,
Plug 'wellle/targets.vim'
Plug 'scrooloose/nerdtree'
Plug 'ycm-core/YouCompleteMe'

call plug#end()
