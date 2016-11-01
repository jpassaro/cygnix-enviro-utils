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
Plugin 'kana/vim-textobj-user'
Plugin 'kana/vim-textobj-indent'
Plugin 'kana/vim-textobj-line'
Plugin 'b4winckler/vim-angry'
Plugin 'bkad/CamelCaseMotion'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

call camelcasemotion#CreateMotionMappings('<leader>')

" let python_highlight_numbers=1
" let python_highlight_exceptions=1
" let python_highlight_space_errors=1
" let python_no_builtin_highlight=1
syntax on

"define BadWhitespace before using in a match
highlight BadWhitespace ctermbg=red guibg=darkred
autocmd BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" shortcut for unfolding a fold.
" nnoremap <space> za
" Disabled so I can learn the keybindings

" never not!
set number

set backspace=start,indent,eol
set hidden

" display tabs everywhere, with width 8, and use spaces instead when entering
" new content
set list listchars=tab:⟩— tabstop=8 expandtab softtabstop=4 shiftwidth=4
" formerly the tabstop bits were in an autocmd, now they set by default.
" autocmd Filetype javascript,html,jinja,vim,python,gitcommit setlocal ...

" but bash is a special baby, for some reason 2-char indent works better
autocmd Filetype sh setlocal softtabstop=2 shiftwidth=2

au BufEnter /private/tmp/crontab.* setlocal backupcopy=yes

" from vimtutor
set hlsearch
set incsearch
" :noh, or \n, to temporarily stop highlighting
nnoremap <Leader>n :noh<CR>

" set a useful statusline
set ruler laststatus=2

"timestamp in ruler pulled from vim wikia
"window dimensions in ruler entirely my own (-:
set rulerformat=%47(%{strftime('%e\ %b\ %T\ %p')}\ %5l,%-6(%c%V%)\ %P%10((%{winwidth(0)}x%{winheight(0)})%)%)

" preferred length < 78...
autocmd Filetype python,vim setlocal textwidth=78
autocmd Filetype python,vim setlocal colorcolumn=+2
autocmd Filetype python setlocal fo-=t
autocmd Filetype python setlocal fo+=r

autocmd Filetype python,gitcommit,vim highlight ColorColumn ctermbg=235
" don't autocomment in vimscripts... however leave 'c' so that it can autowrap
" a very long comment like this one
autocmd Filetype vim setlocal fo-=ro

" mark 72nd column in git commit messages
autocmd Filetype gitcommit setlocal colorcolumn=+0

" create custom vim-surround setting for {% %} and {# #} blocks in jinja
" got the first one from SO i think, but lost the link. The others all me.
autocmd Filetype jinja
        \ let b:surround_{char2nr('^')} = "{% \1{% \1 %}\r{% end\1\r .*\r\1 %}"
autocmd Filetype jinja
        \ let b:surround_{char2nr('%')} = "{% \r %}"
autocmd Filetype jinja
        \ let b:surround_{char2nr('#')} = "{# \r #}"

" enact syntax folds to fight the incredible verbosity of these email templates
autocmd BufRead,BufNewFile app/templates/email/*.html
            \ setlocal foldmethod=syntax

" for debugging syntax settings, borrowed from vim wikia
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

autocmd BufRead,BufNewFile .log setf gitcommit
"                                      PONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba987654321
