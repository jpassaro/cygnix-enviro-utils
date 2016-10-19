" see https://realpython.com/blog/python/vim-and-python-a-match-made-in-heaven/
set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
"call vundle#begin('~/custom/bundle/location')

" required
Plugin 'gmarik/Vundle.vim'

" my plugins
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-scripts/mru.vim'
" Plugin 'scrooloose/syntastic'
Plugin 'jnurmine/Zenburn'
Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'isRuslan/vim-es6'
Plugin 'tpope/vim-fugitive'
Plugin 'mileszs/ack.vim'
Plugin 'tpope/vim-surround.git'
Plugin 'tpope/vim-abolish.git'
Plugin 'tpope/vim-repeat.git'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Nota Bene: remember to 

" let python_highlight_numbers=1
" let python_highlight_exceptions=1
" let python_highlight_space_errors=1
" let python_no_builtin_highlight=1
syntax on

"au BufNewFile,BufRead *.py
"    \ set tabstop=4
"    \ set softtabstop=4
"    \ set shiftwidth=4
"    \ set textwidth=79
"    \ set expandtab
"    \ set autoindent
"    \ set fileformat=unix


"define BadWhitespace before using in a match
highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" shortcut for unfolding a fold.
" nnoremap <space> za
" Disabled temporarily so I can learn the keybindings

" display tabs everywhere
set list lcs=tab:⟩—

" never not!
set number

set backspace=start,indent,eol
set hidden

autocmd Filetype javascript setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd Filetype html setlocal tabstop=8 softtabstop=4 shiftwidth=4 expandtab
autocmd Filetype jinja setlocal tabstop=8 softtabstop=4 shiftwidth=4 expandtab
autocmd Filetype vim setlocal tabstop=8 softtabstop=4 shiftwidth=4 expandtab
autocmd Filetype sh setlocal tabstop=8 softtabstop=2 shiftwidth=2 expandtab

au BufEnter /private/tmp/crontab.* setl backupcopy=yes

" from vimtutor
set hlsearch
set incsearch
" :noh, or \n, to temporarily stop highlighting
nnoremap <Leader>n :noh<CR>

" set a useful statusline
set ruler laststatus=2

"use timestamp in ruler / statusline, pulled from vim wikia
set rulerformat=%58(%{strftime('%a\ %b\ %e\ %T\ %p')}\ %5l,%-6(%c%V%)\ %P%)

" preferred length < 78...
autocmd Filetype python setlocal textwidth=78
autocmd Filetype python setlocal fo-=t
autocmd Filetype python setlocal fo+=r
autocmd Filetype python setlocal colorcolumn=+2

autocmd Filetype python,gitcommit highlight ColorColumn ctermbg=235
" don't autocomment in vimscripts... however leave 'c' so that it can autowrap
" a very long comment like this one
autocmd Filetype vim setlocal fo-=ro

" mark 72nd column in git commit messages
autocmd Filetype gitcommit setlocal colorcolumn=+0

" create custom vim-surround setting for {% %} blocks in jinja
" got this from SO i think, but lost the link
autocmd Filetype jinja let b:surround_{char2nr('%')} = "{% \1{% \1 %}\r{% end\1\r .*\r\1 %}"

" for debugging syntax settings, borrowed from vim wikia
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
