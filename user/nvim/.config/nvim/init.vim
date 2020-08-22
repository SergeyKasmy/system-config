"set nocompatible
"filetype plugin indent on
set nofoldenable
"set foldenable
"set foldmethod=marker
au FileType sh let g:sh_fold_enabled=5
au FileType sh let g:is_bash=1
au FileType sh set foldmethod=syntax
"syntax enable


" enable 24-bit color
set termguicolors
set exrc
set secure

" spell check English: [s, ]s, z=, zg, zw
set spell spelllang=en
set encoding=utf-8
set fileencoding=utf-8

let mapleader = "\<Space>"

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" exit out of insert mode with jk 
inoremap jk <ESC>

nnoremap <Leader>f :NERDTreeToggle<CR>
nnoremap <Leader>v :NERDTreeFind<CR>

nnoremap <Leader>s :set spell!<CR>

" plugins
call plug#begin()

Plug 'dag/vim-fish'
Plug 'vim-scripts/squirrel.vim'

" automatically close brackets
Plug 'Raimondi/delimitMate'

" surround, e.g. ds"
Plug 'tpope/vim-surround'

" add more targets, e.g. ci, ca,
Plug 'wellle/targets.vim'

" align text by character gl, gL, e.g. glip=
Plug 'tommcdo/vim-lion'

Plug 'scrooloose/nerdtree'
Plug 'ycm-core/YouCompleteMe'

call plug#end()

" o/O                   Start insert mode with [count] blank lines.
"                       The default behavior repeats the insertion [count]
"                       times, which is not so useful.
" https://stackoverflow.com/a/27820229/11198543
function! s:NewLineInsertExpr( isUndoCount, command )
    if ! v:count
        return a:command
    endif

    let l:reverse = { 'o': 'O', 'O' : 'o' }
    " First insert a temporary '$' marker at the next line (which is necessary
    " to keep the indent from the current line), then insert <count> empty lines
    " in between. Finally, go back to the previously inserted temporary '$' and
    " enter insert mode by substituting this character.
    " Note: <C-\><C-n> prevents a move back into insert mode when triggered via
    " |i_CTRL-O|.
    return (a:isUndoCount && v:count ? "\<C-\>\<C-n>" : '') .
    \   a:command . "$\<Esc>m`" .
    \   v:count . l:reverse[a:command] . "\<Esc>" .
    \   'g``"_s'
endfunction
nnoremap <silent> <expr> o <SID>NewLineInsertExpr(1, 'o')
nnoremap <silent> <expr> O <SID>NewLineInsertExpr(1, 'O')



au BufNewFile,BufRead *.nut setf squirrel
